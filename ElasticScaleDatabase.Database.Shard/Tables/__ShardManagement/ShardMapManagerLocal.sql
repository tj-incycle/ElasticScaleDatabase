CREATE TABLE [__ShardManagement].[ShardMapManagerLocal] (
    [StoreVersionMajor] INT NOT NULL,
    [StoreVersionMinor] INT NOT NULL,
    CONSTRAINT [pkShardMapManagerLocal_StoreVersionMajor] PRIMARY KEY CLUSTERED ([StoreVersionMajor] ASC)
);

