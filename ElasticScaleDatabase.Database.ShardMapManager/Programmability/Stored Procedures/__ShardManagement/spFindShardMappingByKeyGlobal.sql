
create procedure __ShardManagement.spFindShardMappingByKeyGlobal
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int,
			@gsmVersionMinorClient int,
			@shardMapId uniqueidentifier,
			@keyValue varbinary(128)

	select
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'), 
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier'),
		@keyValue = convert(varbinary(128), x.value('(Key/Value)[1]', 'varchar(258)'), 1)
	from
		@input.nodes('/FindShardMappingByKeyGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @shardMapId is null or @keyValue is null)
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
		
	declare @currentMappingId uniqueidentifier,
			@currentShardId uniqueidentifier,
			@currentMinValue varbinary(128),
			@currentMaxValue varbinary(128),
			@currentStatus int,
			@currentLockOwnerId uniqueidentifier

	if (@shardMapType = 1)
	begin	
		select
			@currentMappingId = MappingId,
			@currentShardId = ShardId,
			@currentMinValue = MinValue,
			@currentMaxValue = MaxValue,
			@currentStatus = Status,
			@currentLockOwnerId = LockOwnerId
		from
			__ShardManagement.ShardMappingsGlobal
		where
			ShardMapId = @shardMapId and 
			Readable = 1 and
			MinValue = @keyValue
	end
	else
	begin
		select 
			@currentMappingId = MappingId,
			@currentShardId = ShardId,
			@currentMinValue = MinValue,
			@currentMaxValue = MaxValue,
			@currentStatus = Status,
			@currentLockOwnerId = LockOwnerId
		from 
			__ShardManagement.ShardMappingsGlobal
		where
			ShardMapId = @shardMapId and 
			Readable = 1 and
			MinValue <= @keyValue and (MaxValue is null or MaxValue > @keyValue)
	end

	if (@@rowcount = 0)
		goto Error_KeyNotFound;

	select 
		3, @currentMappingId as MappingId, ShardMapId, @currentMinValue, @currentMaxValue, @currentStatus, @currentLockOwnerId, -- fields for SqlMapping
		ShardId, Version, ShardMapId, Protocol, ServerName, Port, DatabaseName, Status -- fields for SqlShard, ShardMapId is repeated here
	from 
		__ShardManagement.ShardsGlobal
	where
		ShardId = @currentShardId and
		ShardMapId = @shardMapId
	
	if (@@rowcount = 0)
		goto Error_KeyNotFound;

	set @result = 1
	goto Exit_Procedure;

Error_ShardMapNotFound:
	set @result = 102
	goto Exit_Procedure;

Error_KeyNotFound:
	set @result = 304
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