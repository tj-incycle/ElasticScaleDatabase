CREATE TABLE [__ShardManagement].[ShardMapsLocal] (
    [ShardMapId]      UNIQUEIDENTIFIER NOT NULL,
    [Name]            NVARCHAR (50)    NOT NULL,
    [MapType]         INT              NOT NULL,
    [KeyType]         INT              NOT NULL,
    [LastOperationId] UNIQUEIDENTIFIER DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    CONSTRAINT [pkShardMapsLocal_ShardMapId] PRIMARY KEY CLUSTERED ([ShardMapId] ASC)
);

