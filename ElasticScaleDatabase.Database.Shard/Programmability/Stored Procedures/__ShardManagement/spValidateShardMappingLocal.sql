
create procedure __ShardManagement.spValidateShardMappingLocal
@input xml,
@result int output
as
begin
	declare @lsmVersionMajorClient int,
			@lsmVersionMinorClient int,
			@shardMapId uniqueidentifier,
			@mappingId uniqueidentifier

	select
		@lsmVersionMajorClient = x.value('(LsmVersion/MajorVersion)[1]', 'int'),
		@lsmVersionMinorClient = x.value('(LsmVersion/MinorVersion)[1]', 'int'),
		@shardMapId = x.value('(ShardMapId)[1]', 'uniqueidentifier'),
		@mappingId = x.value('(MappingId)[1]', 'uniqueidentifier')
	from
		@input.nodes('/ValidateShardMappingLocal') as t(x)

	if (@lsmVersionMajorClient is null or @lsmVersionMinorClient is null or @shardMapId is null or @mappingId is null)
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

	declare @m_status_current int

	select 
		@m_status_current = Status
	from
		__ShardManagement.ShardMappingsLocal
	where
		ShardMapId = @shardMapId and MappingId = @mappingId
			
	if (@m_status_current is null)
		goto Error_MappingDoesNotExist;

	if (@m_status_current <> 1)
		goto Error_MappingIsOffline;

	set @result = 1
	goto Exit_Procedure;

Error_ShardMapNotFound:
	set @result = 102
	goto Exit_Procedure;

Error_MappingDoesNotExist:
	set @result = 301
	goto Exit_Procedure;

Error_MappingIsOffline:
	set @result = 309
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