
create procedure __ShardManagement.spRemoveShardMapGlobal
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int,
			@gsmVersionMinorClient int,
			@shardMapId uniqueidentifier

	select 
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'),
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@shardMapId = x.value('(ShardMap/Id)[1]', ' uniqueidentifier')
	from 
		@input.nodes('/RemoveShardMapGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @shardMapId is null)
		goto Error_MissingParameters;

	if (@gsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorGlobal())
		goto Error_GSMVersionMismatch;

	declare @currentShardMapId uniqueidentifier

	select 
		@currentShardMapId = ShardMapId
	from
		__ShardManagement.ShardMapsGlobal with (updlock)
	where
		ShardMapId = @shardMapId

	if (@currentShardMapId is null)
		goto Error_ShardMapNotFound;

	if exists (
		select 
			ShardId 
		from 
			__ShardManagement.ShardsGlobal 
		where 
			ShardMapId = @shardMapId)
		goto Error_ShardMapHasShards;

	delete from 
		__ShardManagement.ShardMapsGlobal 
	where 
		ShardMapId = @shardMapId 

	set @result = 1
	goto Exit_Procedure;

Error_ShardMapNotFound:
	set @result = 102
	goto Exit_Procedure;

Error_ShardMapHasShards:
	set @result = 103
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