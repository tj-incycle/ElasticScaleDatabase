
create procedure __ShardManagement.spBulkOperationShardMappingsLocal
@input xml,
@result int output
as
begin
	declare @lsmVersionMajorClient int,
			@lsmVersionMinorClient int,
			@operationId uniqueidentifier,
			@operationCode int,
			@undo int,
			@stepsCount int,
			@shardMapId uniqueidentifier,
			@sm_kind int,
			@shardId uniqueidentifier,
			@shardVersion uniqueidentifier

	select 
		@lsmVersionMajorClient = x.value('(LsmVersion/MajorVersion)[1]', 'int'),
		@lsmVersionMinorClient = x.value('(LsmVersion/MinorVersion)[1]', 'int'),
		@operationId = x.value('(@OperationId)[1]', 'uniqueidentifier'),
		@undo = x.value('(@Undo)[1]', 'int'),
		@stepsCount = x.value('(@StepsCount)[1]', 'int'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier'),
		@shardId = x.value('(Shard/Id)[1]', 'uniqueidentifier'),
		@shardVersion = x.value('(Shard/Version)[1]', 'uniqueidentifier')
	from 
		@input.nodes('/BulkOperationShardMappingsLocal') as t(x)

	if (@lsmVersionMajorClient is null or @lsmVersionMinorClient is null or @operationId is null or @stepsCount is null or @shardMapId is null or @shardId is null or @shardVersion is null)
		goto Error_MissingParameters;

	if (@lsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorLocal())
		goto Error_LSMVersionMismatch;

	if exists (
		select 
			ShardId
		from
			__ShardManagement.ShardsLocal
		where
			ShardMapId = @shardMapId and ShardId = @shardId and Version = @shardVersion and LastOperationId = @operationId)
		goto Success_Exit;

	update __ShardManagement.ShardsLocal
	set
		Version = @shardVersion,
		LastOperationId = @operationId
	where
		ShardMapId = @shardMapId and ShardId = @shardId

	declare	@currentStep xml,
			@stepIndex int = 1,
			@stepType int,
			@stepMappingId uniqueidentifier

	while (@stepIndex <= @stepsCount)
	begin
		select 
			@currentStep = x.query('(./Step[@Id = sql:variable("@stepIndex")])[1]') 
		from 
			@input.nodes('/BulkOperationShardMappingsLocal/Steps') as t(x)

		select
			@stepType = x.value('(@Kind)[1]', 'int'),
			@stepMappingId = x.value('(Mapping/Id)[1]', 'uniqueidentifier')
		from
			@currentStep.nodes('./Step') as t(x)
	
		if (@stepType is null or @stepMappingId is null)
			goto Error_MissingParameters;

		if (@stepType = 1)
		begin
			delete
				__ShardManagement.ShardMappingsLocal
			where
				ShardMapId = @shardMapId and MappingId = @stepMappingId
		end
		else
		if (@stepType = 3)
		begin
			declare @stepMinValue varbinary(128),
					@stepMaxValue varbinary(128),
					@stepMappingStatus int

			select 
				@stepMinValue = convert(varbinary(128), x.value('(Mapping/MinValue)[1]', 'varchar(258)'), 1),
				@stepMaxValue = convert(varbinary(128), x.value('(Mapping/MaxValue[@Null="0"])[1]', 'varchar(258)'), 1),
				@stepMappingStatus = x.value('(Mapping/Status)[1]', 'int')
			from
				@currentStep.nodes('./Step') as t(x)

			if (@stepMinValue is null or @stepMappingStatus is null)
				goto Error_MissingParameters;

			begin try
				insert into
					__ShardManagement.ShardMappingsLocal
					(MappingId, 
					 ShardId, 
					 ShardMapId, 
					 MinValue, 
					 MaxValue, 
					 Status,
					 LastOperationId)
				values
					(@stepMappingId, 
					 @shardId, 
					 @shardMapId, 
					 @stepMinValue, 
					 @stepMaxValue, 
					 @stepMappingStatus,
					 @operationId)
			end try
			begin catch
			if (@undo != 1)
			begin
				declare @errorMessage nvarchar(max) = error_message(),
					@errorNumber int = error_number(),
					@errorSeverity int = error_severity(),
					@errorState int = error_state(),
					@errorLine int = error_line(),
					@errorProcedure nvarchar(128) = isnull(error_procedure(), '-');
					
					select @errorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + @errorMessage
					raiserror (@errorMessage, @errorSeverity, 1, @errorNumber, @errorSeverity, @errorState, @errorProcedure, @errorLine);
					rollback transaction; -- To avoid extra error message in response.
					goto Error_UnexpectedError;
			end
			end catch

			set @stepMinValue = null
			set @stepMaxValue = null
			set @stepMappingStatus = null

		end

		set @stepType = null
		set @stepMappingId = null

		set @stepIndex = @stepIndex + 1
	end

	goto Success_Exit;

Error_MissingParameters:
	set @result = 50
	exec __ShardManagement.spGetStoreVersionLocalHelper
	goto Exit_Procedure;

Error_LSMVersionMismatch:
	set @result = 51
	exec __ShardManagement.spGetStoreVersionLocalHelper
	goto Exit_Procedure;

Error_UnexpectedError:
	set @result = 53
	goto Exit_Procedure;

Success_Exit:
	set @result = 1
	goto Exit_Procedure;
	
Exit_Procedure:
end