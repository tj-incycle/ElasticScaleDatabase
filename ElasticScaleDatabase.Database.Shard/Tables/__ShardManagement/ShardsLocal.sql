CREATE TABLE [__ShardManagement].[ShardsLocal] (
    [ShardId]         UNIQUEIDENTIFIER NOT NULL,
    [Version]         UNIQUEIDENTIFIER NOT NULL,
    [ShardMapId]      UNIQUEIDENTIFIER NOT NULL,
    [Protocol]        INT              NOT NULL,
    [ServerName]      NVARCHAR (128)   NOT NULL,
    [Port]            INT              NOT NULL,
    [DatabaseName]    NVARCHAR (128)   NOT NULL,
    [Status]          INT              NOT NULL,
    [LastOperationId] UNIQUEIDENTIFIER DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    CONSTRAINT [pkShardsLocal_ShardId] PRIMARY KEY CLUSTERED ([ShardId] ASC),
    CONSTRAINT [fkShardsLocal_ShardMapId] FOREIGN KEY ([ShardMapId]) REFERENCES [__ShardManagement].[ShardMapsLocal] ([ShardMapId]),
    CONSTRAINT [ucShardsLocal_ShardMapId_Location] UNIQUE NONCLUSTERED ([ShardMapId] ASC, [Protocol] ASC, [ServerName] ASC, [DatabaseName] ASC, [Port] ASC)
);

