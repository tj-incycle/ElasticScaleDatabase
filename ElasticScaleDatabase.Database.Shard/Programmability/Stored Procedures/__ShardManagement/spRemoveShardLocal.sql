
create procedure __ShardManagement.spRemoveShardLocal
@input xml,
@result int output
as
begin
	declare @lsmVersionMajorClient int, 
			@lsmVersionMinorClient int,
			@operationId uniqueidentifier,
			@shardMapId uniqueidentifier,
			@shardId uniqueidentifier

	select 
		@lsmVersionMajorClient = x.value('(LsmVersion/MajorVersion)[1]', 'int'),
		@lsmVersionMinorClient = x.value('(LsmVersion/MinorVersion)[1]', 'int'),
		@operationId = x.value('(@OperationId)[1]', 'uniqueidentifier'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier'),
		@shardId = x.value('(Shard/Id)[1]', 'uniqueidentifier')
	from 
		@input.nodes('/RemoveShardLocal') as t(x)

	if (@lsmVersionMajorClient is null or @lsmVersionMinorClient is null or @operationId is null or @shardMapId is null or @shardId is null)
		goto Error_MissingParameters;

	if (@lsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorLocal())
		goto Error_LSMVersionMismatch;

	delete from
		__ShardManagement.ShardsLocal 
	where
		ShardMapId = @shardMapId and ShardId = @shardId

	delete from
		__ShardManagement.ShardMapsLocal 
	where
		ShardMapId = @shardMapId

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

Exit_Procedure:
end