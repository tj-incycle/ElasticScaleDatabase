CREATE TABLE [dbo].[Orders]
(
    [Id] INT NOT NULL IDENTITY,
    [LocationId] INT NOT NULL, 
    [OrderedDateTime] DATETIME NOT NULL, 
    [OrderedByUserId] INT NOT NULL, 
    CONSTRAINT [PK_Orders] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Orders_Users] FOREIGN KEY ([OrderedByUserId]) REFERENCES [dbo].[Users] ([Id])
)
