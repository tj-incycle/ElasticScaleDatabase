
create procedure __ShardManagement.spAttachShardGlobal
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int, 
			@gsmVersionMinorClient int,
			@shardMapId uniqueidentifier,
			@name nvarchar(50),
			@mapType int,
			@keyType int,
			@shardId uniqueidentifier,
			@shardVersion uniqueidentifier,
			@protocol int,
			@serverName nvarchar(128),
			@port int,
			@databaseName nvarchar(128),
			@shardStatus int

	select
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'), 
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier'),
		@name = x.value('(ShardMap/Name)[1]', 'nvarchar(50)'),
		@mapType = x.value('(ShardMap/Kind)[1]', 'int'),
		@keyType = x.value('(ShardMap/KeyKind)[1]', 'int'),

		@shardId = x.value('(Shard/Id)[1]', 'uniqueidentifier'),
		@shardVersion = x.value('(Shard/Version)[1]', 'uniqueidentifier'),
		@protocol = x.value('(Shard/Location/Protocol)[1]', 'int'),
		@serverName = x.value('(Shard/Location/ServerName)[1]', 'nvarchar(128)'),
		@port = x.value('(Shard/Location/Port)[1]', 'int'),
		@databaseName = x.value('(Shard/Location/DatabaseName)[1]', 'nvarchar(128)'),
		@shardStatus = x.value('(Shard/Status)[1]', 'int')
	from
		@input.nodes('/AttachShardGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @shardMapId is null or @name is null or @mapType is null or @keyType is null or
		@shardId is null or @shardVersion is null or @protocol is null or @serverName is null or 
		@port is null or @databaseName is null or @shardStatus is null)
		goto Error_MissingParameters;

	if (@gsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorGlobal())
		goto Error_GSMVersionMismatch;

	if exists (
	select 
		ShardMapId
	from
		__ShardManagement.ShardMapsGlobal 
	where
		(ShardMapId = @shardMapId and Name <> @name) or (ShardMapId <> @shardMapId and Name = @name))
		goto Error_ShardMapAlreadyExists;

	begin try
		insert into 
			__ShardManagement.ShardMapsGlobal 
			(ShardMapId, Name, ShardMapType, KeyType)
		values 
			(@shardMapId, @name, @mapType, @keyType) 
	end try
	begin catch
		if (error_number() <> 2627)
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

	begin try
		insert into 
			__ShardManagement.ShardsGlobal (
			ShardId, 
			Readable, 
			Version, 
			ShardMapId, 
			OperationId, 
			Protocol, 
			ServerName, 
			Port, 
			DatabaseName, 
			Status)
		values (
			@shardId, 
			1, 
			@shardVersion, 
			@shardMapId, 
			null, 
			@protocol, 
			@serverName, 
			@port, 
			@databaseName, 
			@shardStatus) 
	end try
	begin catch
		if (error_number() = 2627)
			goto Error_ShardLocationAlreadyExists;
		else
		begin
			set @errorMessage = error_message()
			set	@errorNumber = error_number()
			set @errorSeverity = error_severity()
			set @errorState = error_state()
			set @errorLine = error_line()
			set @errorProcedure = isnull(error_procedure(), '-')

			select @errorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + @errorMessage;
			
			raiserror (@errorMessage, @errorSeverity, 2, @errorNumber, @errorSeverity, @errorState, @errorProcedure, @errorLine);
			
			rollback transaction; -- To avoid extra error message in response.
			goto Error_UnexpectedError;
		end
	end catch
	
	set @result = 1
	goto Exit_Procedure;

Error_ShardMapAlreadyExists:
	set @result = 101
	goto Exit_Procedure;

Error_ShardLocationAlreadyExists:
	set @result = 205
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