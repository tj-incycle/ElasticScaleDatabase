CREATE TABLE [dbo].[OrderLineItems]
(
    [Id] INT NOT NULL IDENTITY,
    [ProductId] INT NOT NULL,
    [UnitPrice] MONEY NOT NULL, 
    [Quantity] INT NOT NULL, 
    [Total] AS ([UnitPrice] * [Quantity])
    CONSTRAINT [PK_OrderLineItems] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_OrderLineItems_Products] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Products] ([Id])
)