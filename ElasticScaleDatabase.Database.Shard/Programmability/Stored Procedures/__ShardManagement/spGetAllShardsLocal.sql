
create procedure __ShardManagement.spGetAllShardsLocal
@input xml,
@result int output
as
begin
	declare @lsmVersionMajorClient int,
			@lsmVersionMinorClient int

	select 
		@lsmVersionMajorClient = x.value('(LsmVersion/MajorVersion)[1]', 'int'),
		@lsmVersionMinorClient = x.value('(LsmVersion/MinorVersion)[1]', 'int')
	from 
		@input.nodes('/GetAllShardsLocal') as t(x)

	if (@lsmVersionMajorClient is null or @lsmVersionMinorClient is null)
		goto Error_MissingParameters;

	if (@lsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorLocal())
		goto Error_LSMVersionMismatch;

	select 
		1, ShardMapId, Name, MapType, KeyType
	from 
		__ShardManagement.ShardMapsLocal

	select 
		2, ShardId, Version, ShardMapId, Protocol, ServerName, Port, DatabaseName, Status 
	from
		__ShardManagement.ShardsLocal

	goto Success_Exit;

Error_MissingParameters:
	set @result = 50
	exec __ShardManagement.spGetStoreVersionLocalHelper
	goto Exit_Procedure;

Error_LSMVersionMismatch:
	set @result = 51
	exec __ShardManagement.spGetStoreVersionLocalHelper
	goto Exit_Procedure;

Success_Exit:
	set @result = 1
	goto Exit_Procedure;

Exit_Procedure:
end