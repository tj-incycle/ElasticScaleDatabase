
create procedure __ShardManagement.spBulkOperationShardMappingsGlobalEnd
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int,
			@gsmVersionMinorClient int,
			@operationId uniqueidentifier,
			@operationCode int,
			@undo int,
			@stepsCount int,
			@shardMapId uniqueidentifier

	select
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'), 
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@operationId = x.value('(@OperationId)[1]', 'uniqueidentifier'),
		@operationCode = x.value('(@OperationCode)[1]', 'int'),
		@undo = x.value('(@Undo)[1]', 'int'),
		@stepsCount = x.value('(@StepsCount)[1]', 'int'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier')
	from
		@input.nodes('/BulkOperationShardMappingsGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @operationId is null or @operationCode is null or @undo is null or
		@stepsCount is null or @shardMapId is null)
		goto Error_MissingParameters;

	if (@gsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorGlobal())
		goto Error_GSMVersionMismatch;

	if not exists (
		select 
			ShardMapId 
		from 
			__ShardManagement.ShardMapsGlobal with (updlock)
		where
			ShardMapId = @shardMapId)
		goto Error_ShardMapNotFound;

	declare @shardIdForRemoves uniqueidentifier,
			@shardVersionForRemoves uniqueidentifier,
			@shardIdForAdds uniqueidentifier,
			@shardVersionForAdds uniqueidentifier

	select 
		@shardIdForRemoves = x.value('(Removes/Shard/Id)[1]', 'uniqueidentifier'),
		@shardIdForAdds = x.value('(Adds/Shard/Id)[1]', 'uniqueidentifier'),
		@shardVersionForRemoves = x.value('(Removes/Shard/Version)[1]', 'uniqueidentifier'),
		@shardVersionForAdds = x.value('(Adds/Shard/Version)[1]', 'uniqueidentifier')
	from 
		@input.nodes('/BulkOperationShardMappingsGlobal') as t(x)

	if (@shardIdForRemoves is null or @shardIdForAdds is null or @shardVersionForRemoves is null or @shardVersionForAdds is null)
		goto Error_MissingParameters;

	if (@undo = 1)
	begin
		update 
			__ShardManagement.ShardsGlobal
		set
			OperationId = null
		where
			ShardMapId = @shardMapId and ShardId = @shardIdForRemoves

		if (@shardIdForRemoves <> @shardIdForAdds)
		begin
			update 
				__ShardManagement.ShardsGlobal
			set
				OperationId = null
			where
				ShardMapId = @shardMapId and ShardId = @shardIdForAdds
		end
	end
	else
	begin
		update 
			__ShardManagement.ShardsGlobal
		set
			Version = @shardVersionForRemoves,
			OperationId = null
		where
			ShardMapId = @shardMapId and ShardId = @shardIdForRemoves

		if (@shardIdForRemoves <> @shardIdForAdds)
		begin
		update 
			__ShardManagement.ShardsGlobal
		set
			Version = @shardVersionForAdds,
			OperationId = null
		where
			ShardMapId = @shardMapId and ShardId = @shardIdForAdds
		end
	end

	declare @currentStep xml,
			@stepIndex int = 1,
			@stepType int,
			@stepMappingId uniqueidentifier
	
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
			if (@undo = 1)
			begin
				update 
					__ShardManagement.ShardMappingsGlobal
				set
					OperationId = null
				where
					ShardMapId = @shardMapId and MappingId = @stepMappingId
			end
			else
			begin
				delete from 
					__ShardManagement.ShardMappingsGlobal
				where
					ShardMapId = @shardMapId and MappingId = @stepMappingId
			end
		end
		else
		if (@stepType = 2)
		begin
			declare @newMappingId uniqueidentifier,
					@newMappingStatus int

			if (@undo = 1)
			begin
				update 
					__ShardManagement.ShardMappingsGlobal
				set
					OperationId = null
				where
					ShardMapId = @shardMapId and MappingId = @stepMappingId
			end
			else
			begin
				select
					@newMappingId = x.value('(Update/Mapping/Id)[1]', 'uniqueidentifier'),
					@newMappingStatus = x.value('(Update/Mapping/Status)[1]', 'int')
				from
					@currentStep.nodes('./Step') as t(x)

				update 
					__ShardManagement.ShardMappingsGlobal
				set
					MappingId = @newMappingId,
					ShardId = @shardIdForAdds,
					Status = @newMappingStatus,
					OperationId = null
				where
					ShardMapId = @shardMapId and MappingId = @stepMappingId
			end

			set @newMappingId = null
			set @newMappingStatus = null
		end
		else
		if (@stepType = 3)
		begin
			if (@undo = 1)
			begin
				delete from 
					__ShardManagement.ShardMappingsGlobal
				where
					ShardMapId = @shardMapId and MappingId = @stepMappingId
			end
			else
			begin
				update 
					__ShardManagement.ShardMappingsGlobal
				set
					Readable = 1,
					OperationId = null
				where
					ShardMapId = @shardMapId and MappingId = @stepMappingId
			end
		end

		set @stepMappingId = null

		set @stepIndex = @stepIndex + 1
	end

	delete from 
		__ShardManagement.OperationsLogGlobal
	where
		OperationId = @operationId

	set @result = 1
	goto Exit_Procedure;

Error_ShardMapNotFound:
	set @result = 102
	goto Exit_Procedure;

Error_MissingParameters:
	set @result = 50
	exec __ShardManagement.spGetStoreVersionGlobalHelper
	goto Exit_Procedure;

Error_GSMVersionMismatch:
	set @result = 51
	exec __ShardManagement.spGetStoreVersionGlobalHelper
	goto Exit_Procedure;

Exit_Procedure:
end