
create procedure __ShardManagement.spAddShardMapGlobal
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int,
			@gsmVersionMinorClient int,
			@shardMapId uniqueidentifier,
			@name nvarchar(50),
			@mapType int,
			@keyType int

	select 
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'),
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier'),
		@name = x.value('(ShardMap/Name)[1]', 'nvarchar(50)'),
		@mapType = x.value('(ShardMap/Kind)[1]', 'int'),
		@keyType = x.value('(ShardMap/KeyKind)[1]', 'int')
	from 
		@input.nodes('/AddShardMapGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @shardMapId is null or @name is null or @mapType is null or @keyType is null)
		goto Error_MissingParameters;

	if (@gsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorGlobal())
		goto Error_GSMVersionMismatch;
		
	begin try
		insert into 
			__ShardManagement.ShardMapsGlobal 
			(ShardMapId, Name, ShardMapType, KeyType)
		values 
			(@shardMapId, @name, @mapType, @keyType) 
	end try
	begin catch
		if (error_number() = 2627)
			goto Error_ShardMapAlreadyExists;
		else
		begin
			declare @errorMessage nvarchar(max) = error_message(),
					@errorNumber int = error_number(),
					@errorSeverity int = error_severity(),
					@errorState int = error_state(),
					@errorLine int = error_line(),
					@errorProcedure nvarchar(128) = isnull(error_procedure(), '-');

			select @errorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + @errorMessage;
			
			raiserror (@errorMessage, @errorSeverity, 1, @errorNumber, @errorSeverity, @errorState, @errorProcedure, @errorLine);
			
			rollback transaction; -- To avoid extra error message in response.
			goto Error_UnexpectedError;
		end
	end catch
		
	set @result = 1
	goto Exit_Procedure;
		
Error_ShardMapAlreadyExists:
	set @result = 101
	goto Exit_Procedure;

Error_MissingParameters:
	set @result = 50
	exec __ShardManagement.spGetStoreVersionGlobalHelper
	goto Exit_Procedure;

Error_GSMVersionMismatch:
	set @result = 51
	exec __ShardManagement.spGetStoreVersionGlobalHelper
	goto Exit_Procedure;

Error_UnexpectedError:
	set @result = 53
	goto Exit_Procedure;

Exit_Procedure:
end