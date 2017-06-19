CREATE TABLE [dbo].[Products]
(
    [Id] INT NOT NULL IDENTITY,
    [Identifier] VARCHAR(1000) NOT NULL, 
    [Name] VARCHAR(1000) NOT NULL, 
    [ListPrice] MONEY NOT NULL, 
    [SalePrice] MONEY NOT NULL, 
    [Markup] AS (([SalePrice] - [ListPrice]) / [ListPrice]), 
    [Taxable] BIT NOT NULL, 
    CONSTRAINT [PK_Products] PRIMARY KEY ([Id])
)