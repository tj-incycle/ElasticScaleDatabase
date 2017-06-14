CREATE TABLE [__ShardManagement].[ShardedDatabaseSchemaInfosGlobal] (
    [Name]       NVARCHAR (128) NOT NULL,
    [SchemaInfo] XML            NOT NULL,
    CONSTRAINT [pkShardedDatabaseSchemaInfosGlobal_Name] PRIMARY KEY CLUSTERED ([Name] ASC)
);

