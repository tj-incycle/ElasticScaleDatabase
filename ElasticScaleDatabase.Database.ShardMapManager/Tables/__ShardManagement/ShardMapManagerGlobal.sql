CREATE TABLE [__ShardManagement].[ShardMapManagerGlobal] (
    [StoreVersionMajor] INT NOT NULL,
    [StoreVersionMinor] INT NOT NULL,
    CONSTRAINT [pkShardMapManagerGlobal_StoreVersionMajor] PRIMARY KEY CLUSTERED ([StoreVersionMajor] ASC)
);

