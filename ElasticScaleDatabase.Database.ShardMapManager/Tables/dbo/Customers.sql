CREATE TABLE [dbo].[Customers]
(
    [Id] INT NOT NULL IDENTITY,
    [Name] VARCHAR(1000),
    [GlobalId] UNIQUEIDENTIFIER NOT NULL, 
    CONSTRAINT [PK_Customers] PRIMARY KEY ([Id])
)