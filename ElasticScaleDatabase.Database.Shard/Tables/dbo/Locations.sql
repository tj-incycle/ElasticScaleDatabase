CREATE TABLE [dbo].[Locations]
(
    [Id] INT NOT NULL IDENTITY,
    [Name] VARCHAR(1000) NOT NULL, 
    [PhoneNumber] CHAR(10) NOT NULL, 
    [Address] VARCHAR(2000) NOT NULL, 
    [City] VARCHAR(100) NOT NULL, 
    [State] CHAR(2) NOT NULL, 
    [ZipCode] VARCHAR(9) NOT NULL, 
    CONSTRAINT [PK_Locations] PRIMARY KEY ([Id])
);