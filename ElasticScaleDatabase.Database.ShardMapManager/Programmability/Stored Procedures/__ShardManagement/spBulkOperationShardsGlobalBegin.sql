
create procedure __ShardManagement.spBulkOperationShardsGlobalBegin
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
		@input.nodes('/BulkOperationShardsGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @operationId is null or @operationCode is null or 
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
			null,
			null)
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

	declare @currentStep xml,
			@stepIndex int = 1,
			@stepType int,
			@stepShardId uniqueidentifier,
			@stepShardVersion uniqueidentifier,
			@currentShardVersion uniqueidentifier,
			@currentShardOperationId uniqueidentifier

	declare	@stepProtocol int,
			@stepServerName nvarchar(128),
			@stepPort int,
			@stepDatabaseName nvarchar(128),
			@stepShardStatus int

	while (@stepIndex <= @stepsCount)
	begin
		select 
			@currentStep = x.query('(./Step[@Id = sql:variable("@stepIndex")])[1]') 
		from
			@input.nodes('/BulkOperationShardsGlobal/Steps') as t(x)

		select 
			@stepType = x.value('(@Kind)[1]', 'int'),
			@stepShardId = x.value('(Shard/Id)[1]', 'uniqueidentifier'),
			@stepShardVersion = x.value('(Shard/Version)[1]', 'uniqueidentifier')
		from 
			@currentStep.nodes('./Step') as t(x)

		if (@stepType is null or @stepShardId is null or @stepShardVersion is null)
			goto Error_MissingParameters;

		if (@stepType = 1 or @stepType = 2)
		begin

			select
				@currentShardVersion = Version,
				@currentShardOperationId = OperationId
			from
				__ShardManagement.ShardsGlobal with (updlock)
			where
				ShardMapId = @shardMapId and ShardId = @stepShardId and Readable = 1

			if (@currentShardOperationId = @operationId)
				goto Success_Exit;

			if (@currentShardOperationId is not null)
				goto Error_ShardPendingOperation;

			if (@currentShardVersion is null)
				goto Error_ShardDoesNotExist;

			if (@currentShardVersion <> @stepShardVersion)
				goto Error_ShardVersionMismatch;

			if (@stepType = 1)
			begin
			if exists (
				select 
					ShardId 
				from 
					__ShardManagement.ShardMappingsGlobal 
				where 
					ShardMapId = @shardMapId and ShardId = @stepShardId)
				goto Error_ShardHasMappings;
			end

			update 
				__ShardManagement.ShardsGlobal
			set
				OperationId = @operationId
			where
				ShardMapId = @shardMapId and ShardId = @stepShardId
		end
		else
		if (@stepType = 3)
		begin

			select
				@stepProtocol = x.value('(Shard/Location/Protocol)[1]', 'int'),
				@stepServerName = x.value('(Shard/Location/ServerName)[1]', 'nvarchar(128)'),
				@stepPort = x.value('(Shard/Location/Port)[1]', 'int'),
				@stepDatabaseName = x.value('(Shard/Location/DatabaseName)[1]', 'nvarchar(128)'),
				@stepShardStatus = x.value('(Shard/Status)[1]', 'int')
			from
				@currentStep.nodes('./Step') as t(x)

			if (@stepProtocol is null or @stepServerName is null or @stepPort is null or @stepDatabaseName is null or @stepShardStatus is null)
				goto Error_MissingParameters;

			select 
				@currentShardVersion = Version,
				@currentShardOperationId = OperationId
			from
				__ShardManagement.ShardsGlobal with (updlock)
			where
				ShardMapId = @shardMapId and ShardId = @stepShardId

			if (@currentShardOperationId = @operationId)
				goto Success_Exit;

			if (@currentShardOperationId is not null)
				goto Error_ShardPendingOperation;
	
			if (@currentShardVersion is not null)
				goto Error_ShardAlreadyExists;

			set @currentShardVersion = null
			set @currentShardOperationId = null

			select 
				@currentShardVersion = Version, 
				@currentShardOperationId = OperationId
			from  
				__ShardManagement.ShardsGlobal 
			where
				ShardMapId = @shardMapId and
				Protocol = @stepProtocol and 
				ServerName = @stepServerName and
				Port = @stepPort and
				DatabaseName = @stepDatabaseName

			if (@currentShardOperationId is not null)
				goto Error_ShardPendingOperation;

			if (@currentShardVersion is not null)
				goto Error_ShardLocationAlreadyExists;

			begin try
				insert into 
					__ShardManagement.ShardsGlobal(
					ShardId, 
					Readable, 
					Version, 
					ShardMapId, 
					OperationId, 
					Protocol, 
					ServerName, 
					Port, 
					DatabaseName, 
					Status)
				values (
					@stepShardId, 
					0,
					@stepShardVersion, 
					@shardMapId,
					@operationId, 
					@stepProtocol, 
					@stepServerName, 
					@stepPort, 
					@stepDatabaseName, 
					@stepShardStatus) 
			end try
			begin catch
				if (error_number() = 2627)
					goto Error_ShardLocationAlreadyExists;
				else
				begin
					set @errorMessage = error_message()
					set	@errorNumber = error_number()
					set @errorSeverity = error_severity()
					set @errorState = error_state()
					set @errorLine = error_line()
					set @errorProcedure = isnull(error_procedure(), '-')

					select @errorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + @errorMessage;
			
					raiserror (@errorMessage, @errorSeverity, 2, @errorNumber, @errorSeverity, @errorState, @errorProcedure, @errorLine);
			
					rollback transaction; -- To avoid extra error message in response.
					goto Error_UnexpectedError;
				end
			end catch

			set @stepProtocol = null
			set @stepServerName = null
			set @stepPort = null
			set @stepDatabaseName = null
			set @stepShardStatus = null
		end

		set @stepType = null
		set @stepShardId = null
		set @stepShardVersion = null
		set @currentShardVersion = null
		set @currentShardOperationId = null

		set @stepIndex = @stepIndex + 1
	end

	goto Success_Exit;

Error_ShardMapNotFound:
	set @result = 102
	goto Exit_Procedure;

Error_ShardAlreadyExists:
	set @result = 201
	goto Exit_Procedure;

Error_ShardDoesNotExist:
	set @result = 202
	goto Exit_Procedure;

Error_ShardHasMappings:
	set @result = 203
	goto Exit_Procedure;

Error_ShardVersionMismatch:
	set @result = 204
	goto Exit_Procedure;

Error_ShardLocationAlreadyExists:
	set @result = 205
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