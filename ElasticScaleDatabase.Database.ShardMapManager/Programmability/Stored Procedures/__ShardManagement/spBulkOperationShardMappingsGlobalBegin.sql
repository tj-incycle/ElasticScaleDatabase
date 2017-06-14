
create procedure __ShardManagement.spBulkOperationShardMappingsGlobalBegin
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int,
			@gsmVersionMinorClient int,
			@operationId uniqueidentifier,
			@operationCode int,
			@stepsCount int,
			@shardMapId uniqueidentifier

	select
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'), 
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@operationId = x.value('(@OperationId)[1]', 'uniqueidentifier'),
		@operationCode = x.value('(@OperationCode)[1]', 'int'),
		@stepsCount = x.value('(@StepsCount)[1]', 'int'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier')
	from
		@input.nodes('/BulkOperationShardMappingsGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @operationId is null or @operationCode is null or 
		@stepsCount is null or @shardMapId is null)
		goto Error_MissingParameters;

	if (@gsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorGlobal())
		goto Error_GSMVersionMismatch;

	declare @shardMapType int

	select 
		@shardMapType = ShardMapType
	from
		__ShardManagement.ShardMapsGlobal with (updlock)
	where
		ShardMapId = @shardMapId

	if (@shardMapType is null)
		goto Error_ShardMapNotFound;

	declare @shardIdForRemoves uniqueidentifier,
			@originalShardVersionForRemoves uniqueidentifier,
			@shardIdForAdds uniqueidentifier,
			@originalShardVersionForAdds uniqueidentifier,
			@currentShardOperationId uniqueidentifier

	select 
		@shardIdForRemoves = x.value('(Removes/Shard/Id)[1]', 'uniqueidentifier'),
		@shardIdForAdds = x.value('(Adds/Shard/Id)[1]', 'uniqueidentifier')
	from 
		@input.nodes('/BulkOperationShardMappingsGlobal') as t(x)

	if (@shardIdForRemoves is null or @shardIdForAdds is null)
		goto Error_MissingParameters;

	select
		@originalShardVersionForRemoves = Version,
		@currentShardOperationId = OperationId
	from
		__ShardManagement.ShardsGlobal with (updlock)
	where
		ShardMapId = @shardMapId and ShardId = @shardIdForRemoves and Readable = 1
	
	if (@currentShardOperationId = @operationId)
		goto Success_Exit;

	if (@currentShardOperationId is not null)
		goto Error_ShardPendingOperation;

	if (@originalShardVersionForRemoves is null)
		goto Error_ShardDoesNotExist;

	update __ShardManagement.ShardsGlobal
	set
		OperationId = @operationId
	where
		ShardMapId = @shardMapId and ShardId = @shardIdForRemoves

	set @currentShardOperationId = null;

	if (@shardIdForRemoves <> @shardIdForAdds)
	begin
		select
			@originalShardVersionForAdds = Version,
			@currentShardOperationId = OperationId
		from
			__ShardManagement.ShardsGlobal with (updlock)
		where
			ShardMapId = @shardMapId and ShardId = @shardIdForAdds and Readable = 1
	
		if (@currentShardOperationId = @operationId)
			goto Success_Exit;

		if (@currentShardOperationId is not null)
			goto Error_ShardPendingOperation;

		if (@originalShardVersionForAdds is null)
			goto Error_ShardDoesNotExist;

		update __ShardManagement.ShardsGlobal
		set
			OperationId = @operationId
		where
			ShardMapId = @shardMapId and ShardId = @shardIdForAdds
	end
	else
	begin
		set @originalShardVersionForAdds = @originalShardVersionForRemoves
	end
	
	begin try
		insert into __ShardManagement.OperationsLogGlobal(
			OperationId,
			OperationCode,
			Data,
			ShardVersionRemoves,
			ShardVersionAdds)
		values (
			@operationId,
			@operationCode,
			@input,
			@originalShardVersionForRemoves,
			@originalShardVersionForAdds)
	end try
	begin catch
		if (error_number() <> 2627)
		begin
			declare @errorMessage nvarchar(max) = error_message(),
					@errorNumber int = error_number(),
					@errorSeverity int = error_severity(),
					@errorState int = error_state(),
					@errorLine int = error_line(),
					@errorProcedure nvarchar(128) = isnull(error_procedure(), '-');

			select @errorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + @errorMessage;
			
			raiserror (@errorMessage, @errorSeverity, 1, @errorNumber, @errorSeverity, @errorState, @errorProcedure, @errorLine);
			
			rollback transaction; -- To avoid extra error message in response.
			goto Error_UnexpectedError;
		end
	end catch

	declare	@currentStep xml,
			@stepIndex int = 1,
			@stepType int,
			@stepMappingId uniqueidentifier,
			@stepLockOwnerId uniqueidentifier

	declare	@currentLockOwnerId uniqueidentifier,
			@currentStatus int

	declare @stepStatus int,
			@stepShouldValidate bit,
			@stepMinValue varbinary(128),
			@stepMaxValue varbinary(128),
			@mappingIdFromValidate uniqueidentifier

	while (@stepIndex <= @stepsCount)
	begin
		select 
			@currentStep = x.query('(./Step[@Id = sql:variable("@stepIndex")])[1]') 
		from 
			@input.nodes('/BulkOperationShardMappingsGlobal/Steps') as t(x)

		select
			@stepType = x.value('(@Kind)[1]', 'int'),
			@stepMappingId = x.value('(Mapping/Id)[1]', 'uniqueidentifier')
		from
			@currentStep.nodes('./Step') as t(x)
	
		if (@stepType is null or @stepMappingId is null)
			goto Error_MissingParameters;

		if (@stepType = 1)
		begin

			select 
				@stepLockOwnerId = x.value('(Lock/Id)[1]', 'uniqueidentifier')
			from 
				@currentStep.nodes('./Step') as t(x)

			if (@stepLockOwnerId is null)
				goto Error_MissingParameters;

			select 
				@currentLockOwnerId = LockOwnerId,
				@currentStatus = Status
			from
				__ShardManagement.ShardMappingsGlobal with (updlock)
			where
				ShardMapId = @shardMapId and MappingId = @stepMappingId and Readable = 1

			if (@currentLockOwnerId is null)	
				goto Error_MappingDoesNotExist;

			if (@currentLockOwnerId <> @stepLockOwnerId)
				goto Error_MappingLockOwnerIdMismatch;

			if ((@currentStatus & 1) <> 0 and 
				(@operationCode = 5 or 
					@operationCode = 9 or 
					@operationCode = 13))
				goto Error_MappingIsNotOffline;

			update 
				__ShardManagement.ShardMappingsGlobal
			set
				OperationId = @operationId
			where
				ShardMapId = @shardMapId and MappingId = @stepMappingId

			set @currentLockOwnerId = null
			set @currentStatus = null
		end
		else
		if (@stepType = 2)
		begin

			select 
				@stepLockOwnerId = x.value('(Lock/Id)[1]', 'uniqueidentifier'),
				@stepStatus = x.value('(Update/Mapping/Status)[1]', 'int')
			from 
				@currentStep.nodes('./Step') as t(x)

			if (@stepLockOwnerId is null or @stepStatus is null)
				goto Error_MissingParameters;

			select
				@currentLockOwnerId = LockOwnerId,
				@currentStatus = Status
			from
				__ShardManagement.ShardMappingsGlobal with (updlock)
			where
				ShardMapId = @shardMapId and MappingId = @stepMappingId and Readable = 1

			if (@currentLockOwnerId is null)	
				goto Error_MappingDoesNotExist;

			if (@currentLockOwnerId <> @stepLockOwnerId)
				goto Error_MappingLockOwnerIdMismatch;

			if ((@currentStatus & 1) = 1 and (@stepStatus & 1) = 1 and @shardIdForRemoves <> @shardIdForAdds)
				goto Error_MappingIsNotOffline;

			update 
				__ShardManagement.ShardMappingsGlobal
			set
				OperationId = @operationId
			where
				ShardMapId = @shardMapId and MappingId = @stepMappingId

			set @currentLockOwnerId = null
			set @currentStatus = null

			set @stepStatus = null
		end
		else
		if (@stepType = 3)
		begin
			select 
				@stepShouldValidate = x.value('(@Validate)[1]', 'bit'),
				@stepMappingId = x.value('(Mapping/Id)[1]', 'uniqueidentifier'),
				@stepMinValue = convert(varbinary(128), x.value('(Mapping/MinValue)[1]', 'varchar(258)'), 1),
				@stepMaxValue = convert(varbinary(128), x.value('(Mapping/MaxValue[@Null="0"])[1]', 'varchar(258)'), 1),
				@stepStatus = x.value('(Mapping/Status)[1]', 'int'),
				@stepLockOwnerId = x.value('(Mapping/LockOwnerId)[1]', 'uniqueidentifier')
			from
				@currentStep.nodes('./Step') as t(x)

			if (@stepShouldValidate is null or @stepMappingId is null or @stepMinValue is null or @stepStatus is null or @stepLockOwnerId is null)
				goto Error_MissingParameters;

			if (@stepShouldValidate = 1)
			begin
				if (@shardMapType = 1)
				begin
					select 
						@mappingIdFromValidate = MappingId,
						@currentShardOperationId = OperationId
					from
					__ShardManagement.ShardMappingsGlobal
					where
						ShardMapId = @shardMapId and
						MinValue = @stepMinValue

					if (@mappingIdFromValidate is not null)
					begin
						if (@currentShardOperationId is null or @currentShardOperationId = @operationId)
							goto Error_PointAlreadyMapped;
						else
							goto Error_ShardPendingOperation;
					end
				end
				else
				begin
					select 
						@mappingIdFromValidate = MappingId,
						@currentShardOperationId = OperationId
					from
						__ShardManagement.ShardMappingsGlobal
					where
						ShardMapId = @shardMapId and
						(MaxValue is null or MaxValue > @stepMinValue) and 
						(@stepMaxValue is null or MinValue < @stepMaxValue)

					if (@mappingIdFromValidate is not null)
					begin
						if (@currentShardOperationId is null or @currentShardOperationId = @operationId)
							goto Error_RangeAlreadyMapped;
						else
							goto Error_ShardPendingOperation;
					end
				end
			end

			insert into
				__ShardManagement.ShardMappingsGlobal(
				MappingId, 
				Readable,
				ShardId, 
				ShardMapId, 
				OperationId, 
				MinValue, 
				MaxValue, 
				Status,
				LockOwnerId)
			values (
				@stepMappingId, 
				0,
				@shardIdForAdds, 
				@shardMapId, 
				@operationId, 
				@stepMinValue, 
				@stepMaxValue, 
				@stepStatus,
				@stepLockOwnerId)

			set @stepStatus = null

			set @stepShouldValidate = null
			set @stepMinValue = null
			set @stepMaxValue = null
			set @mappingIdFromValidate = null
		end

		set @stepType = null
		set @stepMappingId = null
		set @stepLockOwnerId = null

		set @stepIndex = @stepIndex + 1
	end

	goto Success_Exit;

Error_ShardMapNotFound:
	set @result = 102
	goto Exit_Procedure;

Error_ShardDoesNotExist:
	set @result = 202
	goto Exit_Procedure;

Error_MappingDoesNotExist:
	set @result = 301
	goto Exit_Procedure;

Error_RangeAlreadyMapped:
	set @result = 302
	goto Exit_Procedure;

Error_PointAlreadyMapped:
	set @result = 303
	goto Exit_Procedure;

Error_MappingLockOwnerIdMismatch:
	set @result = 307
	goto Exit_Procedure;

Error_MappingIsNotOffline:
	set @result = 306
	goto Exit_Procedure;

Error_MissingParameters:
	set @result = 50
	exec __ShardManagement.spGetStoreVersionGlobalHelper
	goto Exit_Procedure;

Error_GSMVersionMismatch:
	set @result = 51
	exec __ShardManagement.spGetStoreVersionGlobalHelper
	goto Exit_Procedure;

Error_ShardPendingOperation:
	set @result = 52
	exec __ShardManagement.spGetOperationLogEntryGlobalHelper @currentShardOperationId
	goto Exit_Procedure;

Error_UnexpectedError:
	set @result = 53
	goto Exit_Procedure;

Success_Exit:
	set @result = 1
	goto Exit_Procedure;

Exit_Procedure:
end