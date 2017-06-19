
create procedure __ShardManagement.spAddShardLocal
@input xml,
@result int output
as
begin
	declare @lsmVersionMajorClient int, 
			@lsmVersionMinorClient int,
			@operationId uniqueidentifier,
			@undo int,
			@shardMapId uniqueidentifier,
			@shardId uniqueidentifier,
			@name nvarchar(50),
			@sm_kind int,
			@sm_keykind int,
			@shardVersion uniqueidentifier,
			@protocol int,
			@serverName nvarchar(128),
			@port int,
			@databaseName nvarchar(128),
			@shardStatus  int,
			@errorMessage nvarchar(max),
			@errorNumber int,
			@errorSeverity int,
			@errorState int,
			@errorLine int,
			@errorProcedure nvarchar(128)
	select 
		@lsmVersionMajorClient = x.value('(LsmVersion/MajorVersion)[1]', 'int'), 
		@lsmVersionMinorClient = x.value('(LsmVersion/MinorVersion)[1]', 'int'),
		@operationId = x.value('(@OperationId)[1]', 'uniqueidentifier'),
		@undo = x.value('(@Undo)[1]', 'int'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier'),
		@name = x.value('(ShardMap/Name)[1]', 'nvarchar(50)'),
		@sm_kind = x.value('(ShardMap/Kind)[1]', 'int'),
		@sm_keykind = x.value('(ShardMap/KeyKind)[1]', 'int'),
		@shardId = x.value('(Shard/Id)[1]', 'uniqueidentifier'),
		@shardVersion = x.value('(Shard/Version)[1]', 'uniqueidentifier'),
		@protocol = x.value('(Shard/Location/Protocol)[1]', 'int'),
		@serverName = x.value('(Shard/Location/ServerName)[1]', 'nvarchar(128)'),
		@port = x.value('(Shard/Location/Port)[1]', 'int'),
		@databaseName = x.value('(Shard/Location/DatabaseName)[1]', 'nvarchar(128)'),
		@shardStatus = x.value('(Shard/Status)[1]', 'int')
	from 
		@input.nodes('/AddShardLocal') as t(x)

	if (@lsmVersionMajorClient is null or @lsmVersionMinorClient is null or @shardMapId is null or @operationId is null or @name is null or @sm_kind is null or @sm_keykind is null or 
		@shardId is null or @shardVersion is null or @protocol is null or @serverName is null or 
		@port is null or @databaseName is null or @shardStatus is null)
		goto Error_MissingParameters;

	if (@lsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorLocal())
		goto Error_LSMVersionMismatch;

	if exists (
		select 
			ShardMapId
		from
			__ShardManagement.ShardMapsLocal
		where
			ShardMapId = @shardMapId and LastOperationId = @operationId)
		goto Success_Exit;

	begin try
		insert into 
			__ShardManagement.ShardMapsLocal 
			(ShardMapId, Name, MapType, KeyType, LastOperationId)
		values 
			(@shardMapId, @name, @sm_kind, @sm_keykind, @operationId)
	end try
	begin catch
	if (@undo != 1)
	begin
		set @errorMessage = error_message();
		set @errorNumber = error_number();
		set @errorSeverity = error_severity();
		set @errorState = error_state();
		set @errorLine = error_line();
		set @errorProcedure  = isnull(error_procedure(), '-');					
			select @errorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + @errorMessage
			raiserror (@errorMessage, @errorSeverity, 1, @errorNumber, @errorSeverity, @errorState, @errorProcedure, @errorLine);
			rollback transaction; -- To avoid extra error message in response.
			goto Error_UnexpectedError;
	end
	end catch

	begin try
		insert into 
			__ShardManagement.ShardsLocal(
			ShardId, 
			Version, 
			ShardMapId, 
			Protocol, 
			ServerName, 
			Port, 
			DatabaseName, 
			Status,
			LastOperationId)
		values (
			@shardId, 
			@shardVersion, 
			@shardMapId,
			@protocol, 
			@serverName, 
			@port, 
			@databaseName, 
			@shardStatus,
			@operationId)
	end try
	begin catch
	if (@undo != 1)
	begin
		set @errorMessage = error_message();
		set @errorNumber = error_number();
		set @errorSeverity = error_severity();
		set @errorState = error_state();
		set @errorLine = error_line();
		set @errorProcedure  = isnull(error_procedure(), '-');
					
			select @errorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + @errorMessage
			raiserror (@errorMessage, @errorSeverity, 1, @errorNumber, @errorSeverity, @errorState, @errorProcedure, @errorLine);
			rollback transaction; -- To avoid extra error message in response.
			goto Error_UnexpectedError;
	end
	end catch 

	goto Success_Exit;

Error_MissingParameters:
	set @result = 50
	exec __ShardManagement.spGetStoreVersionLocalHelper
	goto Exit_Procedure;

Error_LSMVersionMismatch:
	set @result = 51
	exec __ShardManagement.spGetStoreVersionLocalHelper
	goto Exit_Procedure;

Error_UnexpectedError:
	set @result = 53
	goto Exit_Procedure;

Success_Exit:
	set @result = 1
	goto Exit_Procedure;
	
Exit_Procedure:
end