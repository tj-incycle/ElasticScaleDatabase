CREATE TABLE [__ShardManagement].[ShardMappingsLocal] (
    [MappingId]       UNIQUEIDENTIFIER NOT NULL,
    [ShardId]         UNIQUEIDENTIFIER NOT NULL,
    [ShardMapId]      UNIQUEIDENTIFIER NOT NULL,
    [MinValue]        VARBINARY (128)  NOT NULL,
    [MaxValue]        VARBINARY (128)  NULL,
    [Status]          INT              NOT NULL,
    [LockOwnerId]     UNIQUEIDENTIFIER DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    [LastOperationId] UNIQUEIDENTIFIER DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    CONSTRAINT [pkShardMappingsLocal_MappingId] PRIMARY KEY CLUSTERED ([MappingId] ASC),
    CONSTRAINT [fkShardMappingsLocal_ShardId] FOREIGN KEY ([ShardId]) REFERENCES [__ShardManagement].[ShardsLocal] ([ShardId]),
    CONSTRAINT [fkShardMappingsLocal_ShardMapId] FOREIGN KEY ([ShardMapId]) REFERENCES [__ShardManagement].[ShardMapsLocal] ([ShardMapId]),
    CONSTRAINT [ucShardMappingsLocal_ShardMapId_MinValue] UNIQUE NONCLUSTERED ([ShardMapId] ASC, [MinValue] ASC)
);

