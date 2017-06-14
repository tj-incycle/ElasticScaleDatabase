CREATE TABLE [__ShardManagement].[OperationsLogGlobal] (
    [OperationId]         UNIQUEIDENTIFIER NOT NULL,
    [OperationCode]       INT              NOT NULL,
    [Data]                XML              NOT NULL,
    [UndoStartState]      INT              DEFAULT ((100)) NOT NULL,
    [ShardVersionRemoves] UNIQUEIDENTIFIER NULL,
    [ShardVersionAdds]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [pkOperationsLogGlobal_OperationId] PRIMARY KEY CLUSTERED ([OperationId] ASC)
);

