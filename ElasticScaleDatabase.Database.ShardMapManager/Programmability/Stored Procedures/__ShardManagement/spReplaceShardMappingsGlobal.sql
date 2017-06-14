
create procedure __ShardManagement.spReplaceShardMappingsGlobal
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int, 
			@gsmVersionMinorClient int,
			@removeStepsCount int,
			@addStepsCount int,
			@shardMapId uniqueidentifier
	
	select
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'), 
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@removeStepsCount = x.value('(@RemoveStepsCount)[1]', 'int'),
		@addStepsCount = x.value('(@AddStepsCount)[1]', 'int'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier')
	from
		@input.nodes('ReplaceShardMappingsGlobal') as t(x)
	
	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @removeStepsCount is null or @addStepsCount is null or @shardMapId is null)
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

	declare	@stepShardId uniqueidentifier,
			@stepMappingId uniqueidentifier

	if (@removeStepsCount > 0)
	begin
		select 
			@stepShardId = x.value('(Shard/Id)[1]', 'uniqueidentifier')
		from 
			@input.nodes('ReplaceShardMappingsGlobal/RemoveSteps') as t(x)

		if (@stepShardId is null)
			goto Error_MissingParameters;
	
		declare @currentRemoveStep xml,
				@removeStepIndex int = 1

		while (@removeStepIndex <= @removeStepsCount)
		begin
			select 
				@currentRemoveStep = x.query('(./Step[@Id = sql:variable("@removeStepIndex")])[1]') 
			from
				@input.nodes('ReplaceShardMappingsGlobal/RemoveSteps') as t(x)

			select 
				@stepMappingId = x.value('(Mapping/Id)[1]', 'uniqueidentifier')
			from
				@currentRemoveStep.nodes('./Step') as t(x)

			if (@stepMappingId is null)
				goto Error_MissingParameters;

			delete from 
				__ShardManagement.ShardMappingsGlobal
			where
				ShardMapId = @shardMapId and MappingId = @stepMappingId and ShardId = @stepShardId

			set @stepMappingId = null

			set @removeStepIndex = @removeStepIndex + 1
		end

		set @stepShardId = null
	end

	if (@addStepsCount > 0)
	begin
		select 
			@stepShardId = x.value('(Shard/Id)[1]', 'uniqueidentifier')
		from 
			@input.nodes('ReplaceShardMappingsGlobal/AddSteps') as t(x)

		if (@stepShardId is null)
			goto Error_MissingParameters;

		declare @currentAddStep xml,
				@addStepIndex int = 1,
				@stepMinValue varbinary(128),
				@stepMaxValue varbinary(128),
				@stepStatus int
		
		while (@addStepIndex <= @addStepsCount)
		begin
			select 
				@currentAddStep = x.query('(./Step[@Id = sql:variable("@addStepIndex")])[1]') 
			from
				@input.nodes('ReplaceShardMappingsGlobal/AddSteps') as t(x)
		
			select
				@stepMappingId = x.value('(Mapping/Id)[1]', 'uniqueidentifier'),
				@stepMinValue = convert(varbinary(128), x.value('(Mapping/MinValue)[1]', 'varchar(258)'), 1),
				@stepMaxValue = convert(varbinary(128), x.value('(Mapping/MaxValue[@Null="0"])[1]', 'varchar(258)'), 1),
				@stepStatus = x.value('(Mapping/Status)[1]', 'int')
			from
				@currentAddStep.nodes('./Step') as t(x)
	
			if (@stepMappingId is null or @stepMinValue is null or @stepStatus is null)
				goto Error_MissingParameters;

			insert into
				__ShardManagement.ShardMappingsGlobal(
				MappingId, 
				Readable,
				ShardId, 
				ShardMapId, 
				OperationId, 
				MinValue, 
				MaxValue, 
				Status)
			values (
				@stepMappingId, 
				1,
				@stepShardId, 
				@shardMapId, 
				null, 
				@stepMinValue, 
				@stepMaxValue, 
				@stepStatus)

			set @stepMappingId = null
			set @stepMinValue = null
			set @stepMaxValue = null
			set @stepStatus = null

			set @addStepIndex = @addStepIndex + 1
		end
	end

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