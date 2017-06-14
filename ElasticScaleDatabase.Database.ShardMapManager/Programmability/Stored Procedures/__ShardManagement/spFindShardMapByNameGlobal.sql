
create procedure __ShardManagement.spFindShardMapByNameGlobal
@input xml,
@result int output
as
begin
declare @gsmVersionMajorClient int,
	@gsmVersionMinorClient int,
			@name  nvarchar(50)

	select
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'),
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@name = x.value('(ShardMap/Name)[1]', ' nvarchar(50)')
	from 
		@input.nodes('/FindShardMapByNameGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @name is null)
		goto Error_MissingParameters;

	if (@gsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorGlobal())
		goto Error_GSMVersionMismatch;

	select
		1, ShardMapId, Name, ShardMapType, KeyType
	from
		__ShardManagement.ShardMapsGlobal
	where 
		Name = @name

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