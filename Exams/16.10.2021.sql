CREATE DATABASE CigarShop
GO

USE CigarShop
GO

--1. DDL

CREATE TABLE Sizes
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Length] INT CHECK([Length] BETWEEN 10 AND 25) NOT NULL ,
	RingRange DECIMAL(18, 2) CHECK(RingRange BETWEEN 1.5 AND 7.5) NOT NULL)

CREATE TABLE Tastes
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	TasteType NVARCHAR(20) NOT NULL,
	TasteStrength NVARCHAR(15) NOT NULL,
	ImageURL NVARCHAR(100) NOT NULL)

CREATE TABLE Brands
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	BrandName NVARCHAR(30) UNIQUE NOT NULL,
	BrandDescription NVARCHAR(MAX) NULL)

CREATE TABLE Cigars
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	CigarName NVARCHAR(80) NOT NULL,
	BrandId INT REFERENCES Brands(Id) NOT NULL,
	TastId INT REFERENCES Tastes(Id) NOT NULL,
	SizeId INT REFERENCES Sizes(Id) NOT NULL,
	PriceForSingleCigar MONEY NOT NULL,  --MONEY??
	ImageURL NVARCHAR(100) NOT NULL)

CREATE TABLE Addresses
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	Town NVARCHAR(30) NOT NULL,
	Country NVARCHAR(30) NOT NULL,
	Streat NVARCHAR(100) NOT NULL, 
	ZIP NVARCHAR(20) NOT NULL)

CREATE TABLE Clients
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Email NVARCHAR(50) NOT NULL,
	AddressId INT REFERENCES Addresses(Id) NOT NULL)

CREATE TABLE ClientsCigars
	(ClientId INT REFERENCES Clients(Id) NOT NULL,
	CigarId INT REFERENCES Cigars(Id) NOT NULL,
	CONSTRAINT PK_ClientsCigars PRIMARY KEY(ClientId, CigarId))

--2 INSERT

INSERT INTO Cigars
VALUES
	('COHIBA ROBUSTO',	9,	1,	5,	15.50,	'cohiba-robusto-stick_18.jpg'),
	('COHIBA SIGLO I',	9,	1,	10,	410.00,	'cohiba-siglo-i-stick_12.jpg'),
	('HOYO DE MONTERREY LE HOYO DU MAIRE',	14,	5,	11,	7.50,	'hoyo-du-maire-stick_17.jpg'),
	('HOYO DE MONTERREY LE HOYO DE SAN JUAN',	14,	4,	15,	32.00,	'hoyo-de-san-juan-stick_20.jpg'),
	('TRINIDAD COLONIALES',	2,	3,	8,	85.21,	'trinidad-coloniales-stick_30.jpg')

INSERT INTO Addresses
VALUES
	('Sofia',	'Bulgaria',	'18 Bul. Vasil levski',	1000),
	('Athens',	'Greece',	'4342 McDonald Avenue',	10435),
	('Zagreb',	'Croatia',	'4333 Lauren Drive',	10000)


--3 UPDATE

UPDATE Cigars
SET PriceForSingleCigar *= 1.2
WHERE TastId = (SELECT Id FROM Tastes WHERE TasteType = 'Spicy')

UPDATE Brands 
SET BrandDescription = 'New description'
WHERE BrandDescription IS NULL

--4 DELETE

DELETE FROM Clients
WHERE AddressId IN (SELECT ID FROM Addresses WHERE Country LIKE 'C%')

DELETE FROM Addresses
WHERE Country LIKE 'C%'

--5. Cigars by Price

SELECT CigarName, PriceForSingleCigar, ImageURL 
FROM Cigars
ORDER BY PriceForSingleCigar, CigarName


--6 Cigars by taste

SELECT c.Id, c.CigarName, c.PriceForSingleCigar, t.TasteType, t.TasteStrength
FROM Cigars AS c
JOIN Tastes AS t ON
	c.TastId = t.Id
WHERE t.TasteType IN('Earthy', 'Woody')
ORDER BY c.PriceForSingleCigar DESC

--7 Clients without cigars

SELECT cl.Id,
	CONCAT(cl.FirstName, ' ', cl.LastName) AS ClientName,
	cl.Email		
FROM Clients AS cl
LEFT JOIN ClientsCigars AS cc ON
	cl.Id = cc.ClientId
WHERE cc.ClientId IS NULL
ORDER BY ClientName





--8 First 5 cigars 

SELECT TOP(5) c.CigarName, c.PriceForSingleCigar, c.ImageURL
FROM Cigars AS c
JOIN Sizes AS s ON
	c.SizeId = s.Id
WHERE s.[Length] > 12 AND (c.CigarName LIKE '%ci%'
	OR c.PriceForSingleCigar > 50) AND s.RingRange > 2.55
ORDER BY CigarName, PriceForSingleCigar DESC


--9. Clients with ZIP codes

SELECT CONCAT(cl.FirstName, ' ', cl.LastName) AS FullName,
	a.Country,
	a.ZIP,
	CONCAT('$', MAX(cg.PriceForSingleCigar)) AS CigarPrice
FROM Clients AS cl
JOIN [Addresses] AS a ON
	cl.AddressId = a.Id
JOIN ClientsCigars AS cc ON
	cl.Id  = cc.ClientId
JOIN Cigars AS cg ON
	cc.CigarId = cg.Id
WHERE a.ZIP NOT LIKE '%[^0-9]%'
GROUP BY cl.FirstName, cl.LastName, a.Country, a.ZIP
ORDER BY FullName 






--10. Cigars by Size

SELECT c.LastName,
	AVG(s.[Length]) AS CigarLength,
	CEILING(AVG(s.RingRange)) AS CigarRingRange
FROM Clients AS c
JOIN ClientsCigars AS cc ON
	c.Id = cc.ClientId
JOIN Cigars AS cg ON
	cc.CigarId = cg.Id
JOIN Sizes AS s ON
	cg.SizeId = s.Id
GROUP BY c.LastName
ORDER BY CigarLength DESC


--11. Client with Cigars

CREATE OR ALTER FUNCTION  udf_ClientWithCigars(@name NVARCHAR(30))
RETURNS INT
AS
BEGIN	
		DECLARE @count INT = (SELECT COUNT(cg.ID)
				FROM Clients AS c
				JOIN ClientsCigars AS cc ON
					c.Id = cc.ClientId
				JOIN Cigars AS cg ON
					cc.CigarId = cg.Id
				WHERE c.FirstName = @name);

		RETURN @count			   		 	  	  
END

SELECT dbo.udf_ClientWithCigars('Betty')




--12.Search for Cigar with Specific Taste

CREATE OR ALTER PROC usp_SearchByTaste(@taste NVARCHAR(20))
AS
	SELECT c.CigarName,
		CONCAT('$',c.PriceForSingleCigar) AS Price,
		t.TasteType,
		b.BrandName,
		CONCAT(s.Length, ' cm') AS CigarLength,
		CONCAT(s.RingRange, ' cm') AS CigarRingRange
	FROM Tastes AS t
	JOIN Cigars AS c ON
		t.Id = c.TastId
	JOIN Brands AS b ON
		c.BrandId = b.Id
	JOIN Sizes AS s ON
		c.SizeId = s.Id
	WHERE t.TasteType = @taste
	ORDER BY CigarLength, CigarRingRange DESC
GO

EXEC usp_SearchByTaste 'Woody'
