CREATE TABLE [dbo].[Users]
(
    [Id] INT NOT NULL IDENTITY,
    [FirstName] VARCHAR(50) NOT NULL, 
    [LastName] VARCHAR(50) NOT NULL, 
    [EmailAddress] VARCHAR(250) NOT NULL, 
    [PasswordHash] VARCHAR(4000) NOT NULL, 
    CONSTRAINT [PK_Users] PRIMARY KEY ([Id])
)