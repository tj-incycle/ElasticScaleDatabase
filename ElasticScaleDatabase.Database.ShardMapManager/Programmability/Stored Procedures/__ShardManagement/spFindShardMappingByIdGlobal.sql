
create procedure __ShardManagement.spFindShardMappingByIdGlobal
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int,
			@gsmVersionMinorClient int,
			@shardMapId uniqueidentifier,
			@mappingId uniqueidentifier

	select
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'), 
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier'),
		@mappingId = x.value('(Mapping/Id)[1]', 'uniqueidentifier')
	from
		@input.nodes('/FindShardMappingByIdGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @shardMapId is null or @mappingId is null)
		goto Error_MissingParameters;

	if (@gsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorGlobal())
		goto Error_GSMVersionMismatch;

	declare @shardMapType int

	select 
		@shardMapType = ShardMapType
	from
		__ShardManagement.ShardMapsGlobal
	where
		ShardMapId = @shardMapId

	if (@shardMapType is null)
		goto Error_ShardMapNotFound;
		
	declare @currentShardId uniqueidentifier,
			@currentMinValue varbinary(128),
			@currentMaxValue varbinary(128),
			@currentStatus int,
			@currentLockOwnerId uniqueidentifier

	select
		@currentMinValue = MinValue
	from
		__ShardManagement.ShardMappingsGlobal
	where
		ShardMapId = @shardMapId and 
		Readable = 1 and
		MappingId = @mappingId

	if (@@rowcount = 0)
		goto Error_MappingDoesNotExist;

	select
		@currentShardId = ShardId,
		@currentMaxValue = MaxValue,
		@currentStatus = Status,
		@currentLockOwnerId = LockOwnerId
	from
		__ShardManagement.ShardMappingsGlobal
	where
		ShardMapId = @shardMapId and 
		MinValue = @currentMinValue

	if (@@rowcount = 0)
		goto Error_MappingDoesNotExist;

	select
		3, @mappingId as MappingId, ShardMapId, @currentMinValue, @currentMaxValue, @currentStatus, @currentLockOwnerId, -- fields for SqlMapping
		ShardId, Version, ShardMapId, Protocol, ServerName, Port, DatabaseName, Status -- fields for SqlShard, ShardMapId is repeated here
	from
		__ShardManagement.ShardsGlobal
	where
		ShardId = @currentShardId and
		ShardMapId = @shardMapId

	if (@@rowcount = 0)
		goto Error_MappingDoesNotExist;

	set @result = 1
	goto Exit_Procedure;

Error_ShardMapNotFound:
	set @result = 102
	goto Exit_Procedure;

Error_MappingDoesNotExist:
	set @result = 301
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