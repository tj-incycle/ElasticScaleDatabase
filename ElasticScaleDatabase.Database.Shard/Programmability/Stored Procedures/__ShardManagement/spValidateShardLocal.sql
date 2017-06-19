
create procedure __ShardManagement.spValidateShardLocal
@input xml,
@result int output
as
begin
	declare @lsmVersionMajorClient int,
			@lsmVersionMinorClient int,
			@shardMapId uniqueidentifier,
			@shardId uniqueidentifier,
			@shardVersion uniqueidentifier
	select 
		@lsmVersionMajorClient = x.value('(LsmVersion/MajorVersion)[1]', 'int'), 
		@lsmVersionMinorClient = x.value('(LsmVersion/MinorVersion)[1]', 'int'),
		@shardMapId = x.value('(ShardMapId)[1]', 'uniqueidentifier'),
		@shardId = x.value('(ShardId)[1]', 'uniqueidentifier'),
		@shardVersion = x.value('(ShardVersion)[1]', 'uniqueidentifier')
	from 
		@input.nodes('/ValidateShardLocal') as t(x)

	if (@lsmVersionMajorClient is null or @lsmVersionMinorClient is null or @shardMapId is null or @shardId is null or @shardVersion is null)
		goto Error_MissingParameters;

	if (@lsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorLocal())
		goto Error_LSMVersionMismatch;

	declare @currentShardMapId uniqueidentifier
	
	select 
		@currentShardMapId = ShardMapId 
	from 
		__ShardManagement.ShardMapsLocal
	where 
		ShardMapId = @shardMapId

	if (@currentShardMapId is null)
		goto Error_ShardMapNotFound;

	declare @currentShardVersion uniqueidentifier

	select 
		@currentShardVersion = Version 
	from 
		__ShardManagement.ShardsLocal
	where 
		ShardMapId = @shardMapId and ShardId = @shardId

	if (@currentShardVersion is null)
		goto Error_ShardDoesNotExist;

	if (@currentShardVersion <> @shardVersion)
		goto Error_ShardVersionMismatch;

	set @result = 1
	goto Exit_Procedure;

Error_ShardMapNotFound:
	set @result = 102
	goto Exit_Procedure;

Error_ShardDoesNotExist:
	set @result = 202
	goto Exit_Procedure;

Error_ShardVersionMismatch:
	set @result = 204
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