
USE SoftUni


SELECT [FirstName], [LastName]
		FROM Employees
		WHERE [FirstName] LIKE 'Sa%'



SELECT [FirstName], [LastName]
		FROM Employees
		WHERE [LastName] LIKE '%ei%'


SELECT [FirstName] FROM Employees
	WHERE [DepartmentID] IN (3,10)
	AND [HireDate] BETWEEN '1995-01-01' AND '2005-12-31'


SELECT [FirstName], [LastName]
	FROM Employees
	WHERE [JobTitle] NOT LIKE '%engineer%'


SELECT [Name] FROM Towns
	WHERE LEN([Name]) IN (5,6)
	ORDER BY [Name] 


SELECT [TownId], [Name] FROM Towns
	WHERE [Name] LIKE '[MKBE]%'
	ORDER BY [Name]


SELECT [TownId], [Name] FROM Towns
	WHERE [Name] LIKE '[^RBD]%'
	ORDER BY [Name]


CREATE VIEW [V_EmployeesHiredAfter2000] AS
	SELECT [FirstName], [LastName] FROM Employees
	WHERE [HireDate] > '2000-12-31'


SELECT [FirstName], [LastName] FROM Employees
	WHERE LEN([LastName])=5


SELECT [EmployeeID],[FirstName],[LastName],[Salary],
	DENSE_RANK() OVER (
		PARTITION BY [Salary]
		ORDER BY [EmployeeID])
		AS [Rank]
	FROM Employees
	WHERE [Salary] BETWEEN 10000 AND 50000
	ORDER BY [Salary] DESC
	
	

SELECT * FROM
	(SELECT [EmployeeID],[FirstName],[LastName],[Salary],
		DENSE_RANK() OVER (
		PARTITION BY [Salary]
		ORDER BY [EmployeeID])
			AS [Rank]
	FROM Employees
	WHERE [Salary] BETWEEN 10000 AND 50000) AS TMP
WHERE [Rank]=2
ORDER BY [Salary] DESC

-----

USE Geography

SELECT [CountryName] AS [Country Name],
	   [IsoCode] AS [ISO Code]
	FROM Countries
	WHERE [CountryName] LIKE '%A%A%A%'
	ORDER BY [IsoCode]


SELECT [PeakName],
	   [RiverName],
	   LOWER(PeakName + (SUBSTRING(RiverName, 2, 50))) AS [Mix]
FROM Peaks, Rivers
WHERE RIGHT(PeakName,1) = LEFT(RiverName,1)
ORDER BY [Mix]

----

USE Diablo

SELECT TOP(50) [Name], FORMAT([Start],'yyyy-MM-dd') AS [Start]
FROM Games
WHERE YEAR([Start]) BETWEEN '2011' AND '2012'
ORDER BY [Start], [Name]



SELECT [Username],
	    SUBSTRING([Email], CHARINDEX('@',Email) + 1, 50) AS [Email Provider]   
FROM Users
ORDER BY [Email Provider], [Username]




SELECT [Username], [IpAddress] 
FROM Users
WHERE [IpAddress] LIKE '___.1%.%.___'
ORDER BY [Username]



-----------


SELECT [Name],
	CASE
		WHEN  [Hour] BETWEEN 0 AND 11 THEN 'Morning'
		WHEN [Hour] BETWEEN 12 AND 17 THEN 'Afternoon'
		WHEN [Hour] BETWEEN 18 AND 23 THEN 'Evening'
	END	AS [Part of the Day],

	CASE
		WHEN  [Duration] <=3 THEN 'Extra Short'
		WHEN [Duration] BETWEEN 4 AND 6 THEN 'Short'
		WHEN [Duration] >6 THEN 'Long'
		ELSE 'Extra Long'
	END	AS [Duration]

FROM 
    (SELECT [Name],
			DATEPART(HOUR,[Start]) AS [Hour],
			[Duration]
		FROM Games ) AS TMP

ORDER BY [Name], [Duration], [Part of the Day]

----------



CREATE DATABASE Built_in_functions
USE Built_in_functions

CREATE TABLE Orders(
	ID INT Primary key IDENTITY NOT NULL,
	ProductName VARCHAR(50) NOT NULL,
	OrderDate DATETIME NOT NULL)

INSERT INTO Orders(ProductName,OrderDate)	
	VALUES
		('Butter', '2016-09-19 00:00:00.000'),
		('Milk', '2016-09-30 00:00:00.000'),
		('Cheese', '2016-09-04 00:00:00.000'),
		('Bread', '2015-12-20 00:00:00.000'),
		('Tomatoes', '2015-12-30 00:00:00.000')


SELECT [ProductName],	
	   [OrderDate],
	   DATEADD(day, 3, [OrderDate]) AS [Pay Due],
	   DATEADD(month, 1, [OrderDate]) AS [Delivey Due]
FROM Orders
		

------

CREATE TABLE People(
	Id INT PRIMARY KEY IDENTITY  NOT NULL,
	[Name] VARCHAR(50) NOT NULL,
	[BirthDate] DATETIME NOT NULL)
		
INSERT INTO People([Name],[BirthDate])
	VALUES
		('Viktor', '2000-12-07 00:00:00.000'),
		('Steven', '1992-09-10 00:00:00.000'),
		('Stephen', '1910-09-19 00:00:00.000'),
		('John', '2010-01-06 00:00:00.000')

SELECT [Name],
	   DATEDIFF(year, [BirthDate], GETDATE()) AS [Age in Years],
	   DATEDIFF(month, [BirthDate], GETDATE()) AS [Age in Months],
	   DATEDIFF(day, [BirthDate], GETDATE()) AS [Age in Days],
	   DATEDIFF(minute, [BirthDate], GETDATE()) AS [Age in Minutes]
FROM People