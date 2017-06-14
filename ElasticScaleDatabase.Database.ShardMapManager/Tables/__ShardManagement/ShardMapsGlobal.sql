CREATE TABLE [__ShardManagement].[ShardMapsGlobal] (
    [ShardMapId]   UNIQUEIDENTIFIER NOT NULL,
    [Name]         NVARCHAR (50)    NOT NULL,
    [ShardMapType] INT              NOT NULL,
    [KeyType]      INT              NOT NULL,
    CONSTRAINT [pkShardMapsGlobal_ShardMapId] PRIMARY KEY CLUSTERED ([ShardMapId] ASC),
    CONSTRAINT [ucShardMapsGlobal_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);

