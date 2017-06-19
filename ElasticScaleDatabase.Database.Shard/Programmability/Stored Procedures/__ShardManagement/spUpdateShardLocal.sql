

create procedure __ShardManagement.spUpdateShardLocal
@input xml,
@result int output
as
begin
	declare @lsmVersionMajorClient int, 
			@lsmVersionMinorClient int,
			@operationId uniqueidentifier,
			@shardMapId uniqueidentifier,
			@shardId uniqueidentifier,
			@shardVersion uniqueidentifier,
			@protocol int,
			@serverName nvarchar(128),
			@port int,
			@databaseName nvarchar(128),
			@shardStatus int

	select 
		@lsmVersionMajorClient = x.value('(LsmVersion/MajorVersion)[1]', 'int'),
		@lsmVersionMinorClient = x.value('(LsmVersion/MinorVersion)[1]', 'int'),
		@operationId = x.value('(@OperationId)[1]', 'uniqueidentifier'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier'),
		@shardId = x.value('(Shard/Id)[1]', 'uniqueidentifier'),
		@shardVersion = x.value('(Shard/Version)[1]', 'uniqueidentifier'),
		@protocol = x.value('(Shard/Location/Protocol)[1]', 'int'),
		@serverName = x.value('(Shard/Location/ServerName)[1]', 'nvarchar(128)'),
		@port = x.value('(Shard/Location/Port)[1]', 'int'),
		@databaseName = x.value('(Shard/Location/DatabaseName)[1]', 'nvarchar(128)'),
		@shardStatus = x.value('(Shard/Status)[1]', 'int')
	from 
		@input.nodes('/UpdateShardLocal') as t(x)

	if (@lsmVersionMajorClient is null or @lsmVersionMinorClient is null or @operationId is null or 
		@shardMapId is null or @shardId is null or @shardVersion is null or @shardStatus is null or
		@protocol is null or @serverName is null or @port is null or @databaseName is null)
		goto Error_MissingParameters;

	if (@lsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorLocal())
		goto Error_LSMVersionMismatch;

	update 
		__ShardManagement.ShardsLocal
	set
		Version = @shardVersion,
		Status = @shardStatus,
		Protocol = @protocol,
		ServerName = @serverName,
		Port = @port,
		DatabaseName = @databaseName,
		LastOperationId = @operationId
	where
		ShardMapId = @shardMapId and ShardId = @shardId

	if (@@rowcount = 0)
		goto Error_ShardDoesNotExist;

	set @result = 1
	goto Exit_Procedure;

Error_MissingParameters:
	set @result = 50
	exec __ShardManagement.spGetStoreVersionLocalHelper
	goto Exit_Procedure;

Error_LSMVersionMismatch:
	set @result = 51
	exec __ShardManagement.spGetStoreVersionLocalHelper
	goto Exit_Procedure;

Error_ShardDoesNotExist:
	set @result = 202
	goto Exit_Procedure;

Exit_Procedure:
end