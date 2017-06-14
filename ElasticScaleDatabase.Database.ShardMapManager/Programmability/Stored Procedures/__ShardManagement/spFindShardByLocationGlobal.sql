
create procedure __ShardManagement.spFindShardByLocationGlobal
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int,
			@gsmVersionMinorClient int,
			@shardMapId uniqueidentifier,
			@protocol int,
			@serverName nvarchar(128),
			@port int,
			@databaseName nvarchar(128)

	select 
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'),
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier'),
		@protocol = x.value('(Location/Protocol)[1]', 'int'),
		@serverName = x.value('(Location/ServerName)[1]', 'nvarchar(128)'),
		@port = x.value('(Location/Port)[1]', 'int'),
		@databaseName = x.value('(Location/DatabaseName)[1]', 'nvarchar(128)')
	from
		@input.nodes('/FindShardByLocationGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @shardMapId is null or 
		@protocol is null or @serverName is null or @port is null or @databaseName is null)
		goto Error_MissingParameters;

	if (@gsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorGlobal())
		goto Error_GSMVersionMismatch;

	if not exists (
	select 
		ShardMapId 
	from
		__ShardManagement.ShardMapsGlobal
	where
		ShardMapId = @shardMapId)
		goto Error_ShardMapNotFound;

	select 
		2, ShardId, Version, ShardMapId, Protocol, ServerName, Port, DatabaseName, Status
	from 
		__ShardManagement.ShardsGlobal 
	where
		ShardMapId = @shardMapId and
		Protocol = @protocol and ServerName = @serverName and Port = @port and DatabaseName = @databaseName and 
		Readable = 1

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