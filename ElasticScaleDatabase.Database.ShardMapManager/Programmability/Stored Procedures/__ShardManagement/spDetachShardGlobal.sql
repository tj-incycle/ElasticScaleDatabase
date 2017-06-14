
create procedure __ShardManagement.spDetachShardGlobal
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int, 
			@gsmVersionMinorClient int,
			@protocol int,
			@serverName nvarchar(128),
			@port int,
			@databaseName nvarchar(128),
			@name nvarchar(50)
	
	select
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'), 
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@protocol = x.value('(Location/Protocol)[1]', 'int'),
		@serverName = x.value('(Location/ServerName)[1]', 'nvarchar(128)'),
		@port = x.value('(Location/Port)[1]', 'int'),
		@databaseName = x.value('(Location/DatabaseName)[1]', 'nvarchar(128)'),
		@name = x.value('(Shardmap[@Null="0"]/Name)[1]', 'nvarchar(50)')
	from
		@input.nodes('/DetachShardGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @protocol is null or @serverName is null or @port is null or @databaseName is null)
		goto Error_MissingParameters;

	if (@gsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorGlobal())
		goto Error_GSMVersionMismatch;

	declare @tvShardsToDetach table (ShardMapId uniqueidentifier, ShardId uniqueidentifier)

	insert into 
		@tvShardsToDetach
	select 
		tShardMaps.ShardMapId, tShards.ShardId
	from
		__ShardManagement.ShardMapsGlobal tShardMaps 
		join
		__ShardManagement.ShardsGlobal tShards
		on 
			tShards.ShardMapId = tShardMaps.ShardMapId and 
			tShards.Protocol = @protocol and
			tShards.ServerName = @serverName and 
			tShards.Port = @port and
			tShards.DatabaseName = @databaseName
	where
		@name is null or tShardMaps.Name = @name

	delete 
		tShardMappings 
	from
		__ShardManagement.ShardMappingsGlobal tShardMappings 
		join
		@tvShardsToDetach tShardsToDetach
		on 
		tShardsToDetach.ShardMapId = tShardMappings.ShardMapId and tShardsToDetach.ShardId = tShardMappings.ShardId

	delete 
		tShards
	from
		__ShardManagement.ShardsGlobal tShards 
		join
		@tvShardsToDetach tShardsToDetach
		on 
		tShardsToDetach.ShardMapId = tShards.ShardMapId and tShardsToDetach.ShardId = tShards.ShardId

	set @result = 1
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