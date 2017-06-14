
create procedure __ShardManagement.spFindShardingSchemaInfoByNameGlobal
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int,
			@gsmVersionMinorClient int,
			@name nvarchar(128)

	select
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'), 
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@name = x.value('(SchemaInfo/Name)[1]', 'nvarchar(128)')
	from 
		@input.nodes('/FindShardingSchemaInfoGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @name is null)
		goto Error_MissingParameters;

	if (@gsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorGlobal())
		goto Error_GSMVersionMismatch;

	select
		7, Name, SchemaInfo
	from 
		__ShardManagement.ShardedDatabaseSchemaInfosGlobal
	where
		Name = @name

	if (@@rowcount = 0)
		goto Error_SchemaInfoNameDoesNotExist;

	set @result = 1
	goto Exit_Procedure;

Error_SchemaInfoNameDoesNotExist:
	set @result = 401
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