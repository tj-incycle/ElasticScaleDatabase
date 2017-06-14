
create procedure __ShardManagement.spGetAllDistinctShardLocationsGlobal
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int,
			@gsmVersionMinorClient int

	select 
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'),
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int')
	from 
		@input.nodes('/GetAllDistinctShardLocationsGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null)
		goto Error_MissingParameters;

	if (@gsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorGlobal())
		goto Error_GSMVersionMismatch;

	select distinct 
		4, Protocol, ServerName, Port, DatabaseName 
	from 
		__ShardManagement.ShardsGlobal
	where
		Readable = 1

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