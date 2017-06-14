
create procedure __ShardManagement.spGetOperationLogEntryGlobalHelper
@operationId uniqueidentifier
as
begin
	select
		6, OperationId, OperationCode, Data, UndoStartState, ShardVersionRemoves, ShardVersionAdds
	from
		__ShardManagement.OperationsLogGlobal
	where
		OperationId = @operationId
end