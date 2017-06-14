CREATE TABLE [__ShardManagement].[ShardsGlobal] (
    [ShardId]      UNIQUEIDENTIFIER NOT NULL,
    [Readable]     BIT              NOT NULL,
    [Version]      UNIQUEIDENTIFIER NOT NULL,
    [ShardMapId]   UNIQUEIDENTIFIER NOT NULL,
    [OperationId]  UNIQUEIDENTIFIER NULL,
    [Protocol]     INT              NOT NULL,
    [ServerName]   NVARCHAR (128)   NOT NULL,
    [Port]         INT              NOT NULL,
    [DatabaseName] NVARCHAR (128)   NOT NULL,
    [Status]       INT              NOT NULL,
    CONSTRAINT [pkShardsGlobal_ShardId] PRIMARY KEY CLUSTERED ([ShardId] ASC),
    CONSTRAINT [fkShardsGlobal_ShardMapId] FOREIGN KEY ([ShardMapId]) REFERENCES [__ShardManagement].[ShardMapsGlobal] ([ShardMapId]),
    CONSTRAINT [ucShardsGlobal_Location] UNIQUE NONCLUSTERED ([ShardMapId] ASC, [Protocol] ASC, [ServerName] ASC, [DatabaseName] ASC, [Port] ASC)
);

