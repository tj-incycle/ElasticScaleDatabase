
create procedure __ShardManagement.spBulkOperationShardsGlobalEnd
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int, 
			@gsmVersionMinorClient int,
			@operationId uniqueidentifier,
			@operationCode int,
			@undo bit,
			@stepsCount int,
			@shardMapId uniqueidentifier

	select
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'), 
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@operationId = x.value('(@OperationId)[1]', 'uniqueidentifier'),
		@operationCode = x.value('(@OperationCode)[1]', 'int'),
		@undo = x.value('(@Undo)[1]', 'bit'),
		@stepsCount = x.value('(@StepsCount)[1]', 'int'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier')
	from
		@input.nodes('/BulkOperationShardsGlobal') as t(x)

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

	declare @currentStep xml,
			@stepIndex int = 1,
			@stepType int,
			@stepShardId uniqueidentifier
	
	while (@stepIndex <= @stepsCount)
	begin
		select 
			@currentStep = x.query('(./Step[@Id = sql:variable("@stepIndex")])[1]') 
		from
			@input.nodes('/BulkOperationShardsGlobal/Steps') as t(x)

		select 
			@stepType = x.value('(@Kind)[1]', 'int'),
			@stepShardId = x.value('(Shard/Id)[1]', 'uniqueidentifier')
		from 
			@currentStep.nodes('./Step') as t(x)

		if (@stepType is null or @stepShardId is null)
			goto Error_MissingParameters;

		if (@stepType = 1)
		begin
			if (@undo = 1)
			begin
				update 
					__ShardManagement.ShardsGlobal
				set
					OperationId = null
				where
					ShardMapId = @shardMapId and ShardId = @stepShardId and OperationId = @operationId 
			end
			else
			begin
				delete from 
					__ShardManagement.ShardsGlobal
				where
					ShardMapId = @shardMapId and ShardId = @stepShardId and OperationId = @operationId
			end
		end
		else
		if (@stepType = 2)
		begin
			declare @newShardVersion uniqueidentifier,
					@newStatus int

			if (@undo = 1)
			begin
				update 
					__ShardManagement.ShardsGlobal
				set
					OperationId = null
				where
					ShardMapId = @shardMapId and ShardId = @stepShardId and OperationId = @operationId 
			end
			else
			begin
				select 
					@newShardVersion = x.value('(Update/Shard/Version)[1]', 'uniqueidentifier'),
					@newStatus = x.value('(Update/Shard/Status)[1]', 'int')
				from 
					@currentStep.nodes('./Step') as t(x)

				update 
					__ShardManagement.ShardsGlobal
				set
					Version = @newShardVersion,
					Status = @newStatus,
					OperationId = null
				where
					ShardMapId = @shardMapId and ShardId = @stepShardId and OperationId = @operationId 
			end

			set @newShardVersion = null
			set @newStatus = null
		end
		else
		if (@stepType = 3)
		begin
			if (@undo = 1)
			begin
				delete from 
					__ShardManagement.ShardsGlobal
				where
					ShardMapId = @shardMapId and ShardId = @stepShardId and OperationId = @operationId
			end
			else
			begin
				update 
					__ShardManagement.ShardsGlobal
				set
					Readable = 1,
					OperationId = null
				where
					ShardMapId = @shardMapId and ShardId = @stepShardId and OperationId = @operationId 
			end
		end

		set @stepShardId = null

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