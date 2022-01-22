CREATE DATABASE Bakery
GO
USE Bakery 
GO
----

--1. Design

CREATE TABLE Countries
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50) UNIQUE)

CREATE TABLE Customers
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(25),
	LastName NVARCHAR(25),
	Gender CHAR(1) CHECK(Gender IN ('M', 'F')),
	Age INT,
	PhoneNumber CHAR(10),
	CountryId INT FOREIGN KEY REFERENCES Countries(Id))

CREATE TABLE Products
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(25) UNIQUE,
	[Description] NVARCHAR(250),
	Recipe NVARCHAR(MAX),
	Price DECIMAL(18,2) CHECK(Price >= 0))

CREATE TABLE Feedbacks
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Description] NVARCHAR(255),
	Rate DECIMAL(4,2) CHECK(Rate BETWEEN 0 AND 10),
	ProductId INT FOREIGN KEY REFERENCES Products(Id),
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id))

CREATE TABLE Distributors
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(25) UNIQUE,
	AddressText NVARCHAR(30),
	Summary NVARCHAR(200),
	CountryId INT FOREIGN KEY REFERENCES Countries(Id))

CREATE TABLE Ingredients
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(30),
	[Description] NVARCHAR(200),
	OriginCountryId INT FOREIGN KEY REFERENCES Countries(Id),
	DistributorId INT FOREIGN KEY REFERENCES Distributors(Id))

CREATE TABLE ProductsIngredients
	(ProductId INT FOREIGN KEY REFERENCES Products(Id),
	IngredientId INT FOREIGN KEY REFERENCES Ingredients(Id),
	CONSTRAINT PK_ProductsIngredients PRIMARY KEY(ProductId, IngredientId))

--2. Insert

INSERT INTO Distributors ([Name], CountryId, AddressText, Summary)
VALUES
	('Deloitte & Touche', 2, '6 Arch St #9757', 'Customizable neutral traveling'),
	('Congress Title', 13, '58 Hancock St', 'Customer loyalty'),
	('Kitchen People', 1, '3 E 31st St #77','Triple-buffered stable delivery'),
	('General Color Co Inc', 21, '6185 Bohn St #72', 'Focus group'),
	('Beck Corporation', 23, '21 E 64th Ave', 'Quality-focused 4th generation hardware')

INSERT INTO Customers (FirstName, LastName,	Age, Gender, PhoneNumber, CountryId)
VALUES
	('Francoise', 'Rautenstrauch', 15, 'M',	'0195698399', 5),
	('Kendra',	'Loud',	22,	'F', '0063631526', 11),
	('Lourdes',	'Bauswell',	50, 'M', '0139037043', 8),
	('Hannah',	'Edmison', 18, 'F', '0043343686', 1),
	('Tom',	'Loeza', 31, 'M', '0144876096',	23),
	('Queenie',	'Kramarczyk', 30, 'F', '0064215793', 29),
	('Hiu',	'Portaro', 25, 'M',	'0068277755', 16),
	('Josefa', 'Opitz',	43,	'F', '0197887645', 17)

--3. Update

UPDATE Ingredients 
SET DistributorId = 35
WHERE [Name] IN ('Bay Leaf', 'Paprika', 'Poppy')

UPDATE Ingredients
SET OriginCountryId = 14
WHERE OriginCountryId = 8

--4. Delete

DELETE FROM Feedbacks
WHERE CustomerId = 14 OR
	ProductId = 5

--5. Products by price

SELECT [Name], Price, [Description]
FROM Products
ORDER BY Price DESC, [Name] ASC

--6. Negative feedback

SELECT f.ProductId, f.Rate, f.[Description], f.CustomerId, c.Age, c.Gender
FROM Feedbacks AS f
JOIN Customers AS c ON
	f.CustomerId = c.Id
WHERE f.Rate < 5.0
ORDER BY f.ProductId DESC, f.Rate

--7. Customers without feedback

SELECT 
	CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
	c.PhoneNumber,
	c.Gender
FROM Customers AS c
LEFT JOIN Feedbacks AS f ON
	c.Id = f.CustomerId
WHERE f.CustomerId IS NULL
ORDER BY c.Id 

--8. Customers by criteria

SELECT c.FirstName, c.Age, c.PhoneNumber
FROM Customers AS c
JOIN Countries AS cnt ON
	c.CountryId = cnt.Id
WHERE (c.Age >= 21 AND c.FirstName LIKE '%an%') OR
	(c.PhoneNumber LIKE '%38' AND cnt.[Name] != 'Greece')
ORDER BY c.FirstName, c.Age DESC

--9. Middle range distributors