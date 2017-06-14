CREATE TABLE [__ShardManagement].[ShardMappingsGlobal] (
    [MappingId]   UNIQUEIDENTIFIER NOT NULL,
    [Readable]    BIT              NOT NULL,
    [ShardId]     UNIQUEIDENTIFIER NOT NULL,
    [ShardMapId]  UNIQUEIDENTIFIER NOT NULL,
    [OperationId] UNIQUEIDENTIFIER NULL,
    [MinValue]    VARBINARY (128)  NOT NULL,
    [MaxValue]    VARBINARY (128)  NULL,
    [Status]      INT              NOT NULL,
    [LockOwnerId] UNIQUEIDENTIFIER DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    CONSTRAINT [pkShardMappingsGlobal_ShardMapId_MinValue_Readable] PRIMARY KEY CLUSTERED ([ShardMapId] ASC, [MinValue] ASC, [Readable] ASC),
    CONSTRAINT [fkShardMappingsGlobal_ShardId] FOREIGN KEY ([ShardId]) REFERENCES [__ShardManagement].[ShardsGlobal] ([ShardId]),
    CONSTRAINT [fkShardMappingsGlobal_ShardMapId] FOREIGN KEY ([ShardMapId]) REFERENCES [__ShardManagement].[ShardMapsGlobal] ([ShardMapId]),
    CONSTRAINT [ucShardMappingsGlobal_MappingId] UNIQUE NONCLUSTERED ([MappingId] ASC)
);

