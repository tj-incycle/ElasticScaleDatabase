
create procedure __ShardManagement.spFindAndUpdateOperationLogEntryByIdGlobal
@input xml,
@result int output
as
begin
	declare @gsmVersionMajorClient int,
			@gsmVersionMinorClient int,
			@operationId uniqueidentifier,
			@undoStartState int

	select
		@gsmVersionMajorClient = x.value('(GsmVersion/MajorVersion)[1]', 'int'),
		@gsmVersionMinorClient = x.value('(GsmVersion/MinorVersion)[1]', 'int'),
		@operationId = x.value('(@OperationId)[1]', 'uniqueidentifier'),
		@undoStartState = x.value('(@UndoStartState)[1]', 'int')
	from
		@input.nodes('/FindAndUpdateOperationLogEntryByIdGlobal') as t(x)

	if (@gsmVersionMajorClient is null or @gsmVersionMinorClient is null or @operationId is null or @undoStartState is null)
		goto Error_MissingParameters;

	if (@gsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorGlobal())
		goto Error_GSMVersionMismatch;

	update 
		__ShardManagement.OperationsLogGlobal
	set
		UndoStartState = @undoStartState
	where
		OperationId = @operationId

	set @result = 1
	exec __ShardManagement.spGetOperationLogEntryGlobalHelper @operationId
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