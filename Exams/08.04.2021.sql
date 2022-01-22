--Section 1- DDL

CREATE DATABASE [Service]
USE [Service]

CREATE TABLE [Users] (
	Id INT IDENTITY PRIMARY KEY NOT NULL,
	[Username] NVARCHAR(30) UNIQUE NOT NULL,
	[Password] NVARCHAR(50) NOT NULL,
	[Name] NVARCHAR(50) NULL,
	[Birthdate] DATETIME NULL,
	[Age] INT CHECK([Age] BETWEEN 14 AND 110),
	[Email] NVARCHAR(50) NOT NULL)

CREATE TABLE [Departments](
	Id INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL)

CREATE TABLE [Employees](
	Id INT IDENTITY PRIMARY KEY NOT NULL,
	[FirstName] NVARCHAR(25) NULL,
	[LastName] NVARCHAR(25) NULL,
	[Birthdate] DATETIME NULL,
	[Age] INT CHECK([Age] BETWEEN 18 AND 110),
	[DepartmentId] INT FOREIGN KEY REFERENCES Departments(Id))

CREATE TABLE [Categories](
	Id INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	[DepartmentId] INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL)

CREATE TABLE [Status](
	Id INT IDENTITY PRIMARY KEY NOT NULL,
	[Label] NVARCHAR(30) NOT NULL)

CREATE TABLE [Reports](
	Id INT IDENTITY PRIMARY KEY NOT NULL,
	[CategoryId] INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	[StatusId] INT FOREIGN KEY REFERENCES [Status](Id) NOT NULL,
	[OpenDate] DATETIME NOT NULL,
	[CloseDate] DATETIME NULL,
	[Description] NVARCHAR(200) NOT NULL,
	[UserId] INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
	[EmployeeId] INT FOREIGN KEY REFERENCES Employees(Id) NULL)

--------

--2. INSERT

INSERT INTO Employees(FirstName, LastName, Birthdate, DepartmentId)
VALUES
	('Marlo', 'O''Malley', '1958-09-21', 1),
	('Niki', 'Stanaghan', '1969-11-26',	4),
	('Ayrton', 'Senna',	'1960-03-21',	9),
	('Ronnie', 'Peterson','1944-02-14',	9),
	('Giovanna', 'Amati', '1959-07-20',	5)
	
INSERT INTO Reports (CategoryId, StatusId, OpenDate, CloseDate, [Description], UserId, EmployeeId)
VALUES
	(1,	1, '2017-04-13', NULL, 'Stuck Road on Str.133', 6, 2),
	(6,	3, '2015-09-05', '2015-12-06', 'Charity trail running', 3, 5),
	(14, 2,	'2015-09-07', NULL,	'Falling bricks on Str.58',	5, 2),
	(4,	3,	'2017-07-03', '2017-07-06',	'Cut off streetlight on Str.11', 1,	1)

-------

--3. UPDATE

UPDATE Reports
SET CloseDate=GETDATE()
WHERE CloseDate IS NULL

-----

--4. DELETE

DELETE FROM Reports
WHERE StatusId=4

-----
--5.Unassigned reports

SELECT [Description], FORMAT(OpenDate, 'dd-MM-yyyy')
FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate, [Description]

----6. Reports and categories

SELECT r.[Description], c.[Name] AS CategoryName
FROM Reports AS r
--WHERE CategoryId IS NOT NULL
JOIN Categories AS c ON
r.CategoryId = c.Id
ORDER BY r.[Description], c.[Name]

---7. Most reported category

SELECT TOP(5) c.[Name] AS CategoryName, COUNT(r.CategoryId) AS ReportsNumber
FROM Reports AS r 
JOIN Categories AS c ON
	r.CategoryId = c.Id
GROUP BY CategoryId, Name
ORDER BY ReportsNumber DESC, CategoryName ASC


---8. Birthday Report
SELECT u.Username, c.[Name] AS CategoryName 
FROM Reports AS r
JOIN Users AS u ON
	r.UserId = u.Id
JOIN Categories AS c ON
	r.CategoryId = c.Id
WHERE DATEPART(DAY, r.OpenDate ) = DATEPART(DAY, u.Birthdate)
	AND DATEPART(MONTH,  r.OpenDate ) = DATEPART(MONTH, u.Birthdate)
ORDER BY Username, CategoryName

--9. Users per Employee
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS FullName, COUNT(u.Id) AS UsersCount
	FROM Reports AS r
	RIGHT JOIN Employees AS e ON
		r.EmployeeId = e.Id
    LEFT JOIN Users AS u ON
		r.UserId = u.Id
	GROUP BY e.Id, e.FirstName, e.LastName
	ORDER BY UsersCount DESC, FullName

--10. Full info

SELECT 
	CASE
		WHEN e.FirstName IS NULL THEN 'None'
		ELSE CONCAT(e.FirstName, ' ', e.LastName)
		END AS Employee,
	ISNULL(d.[Name], 'None') AS Department,
	ISNULL(c.[Name], 'None') AS CategoryName,
	ISNULL(r.[Description], 'None') AS [Description],
	ISNULL(FORMAT(r.OpenDate, 'dd.MM.yyyy'), 'None') AS OpenDate,
	ISNULL(s.[Label], 'None') AS [Status],
	ISNULL(u.[Name], 'None') AS [User]
FROM Reports AS r
LEFT JOIN Employees AS e ON
	r.EmployeeId = E.Id
LEFT JOIN Departments AS d ON
	e.DepartmentId = d.Id
LEFT JOIN Categories AS c ON
	r.CategoryId = c.Id
LEFT JOIN [Status] AS s ON
	r.StatusId = s.Id
LEFT JOIN Users AS u ON
	r.UserId = u.Id
ORDER BY e.FirstName DESC,
	e.LastName DESC, 
	d.[Name] ASC,
	c.[Name] ASC,
	r.[Description] ASC,
	OpenDate ASC, 
	[Status] ASC, 
	[User] ASC 	

---10. Hours to compete

CREATE OR ALTER FUNCTION udf_HoursToComplete (@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
AS
BEGIN
	DECLARE @result INT

	IF @StartDate IS NULL OR @EndDate IS NULL
		SET @result =  1;
	ELSE 
		SET @result =  DATEDIFF(hh, @StartDate, @EndDate);

	RETURN @result
END

SELECT [dbo].[udf_HoursToComplete] ((GETDATE()-1), NULL)
SELECT [dbo].[udf_HoursToComplete] ((GETDATE()-1), GETDATE())

---12. Assign employee

CREATE OR ALTER PROC usp_AssignEmployeeToReport (@EmployeeId INT, @ReportId INT)
AS
	 DECLARE @employeedDept INT
	 DECLARE @reportDept INT

	SET  @employeedDept = 
		(SELECT DepartmentId
		FROM Employees
		WHERE Id = @EmployeeId)

	SET @reportDept = 
		(SELECT c.DepartmentId
		FROM Categories AS c
		JOIN Reports AS r
		ON r.CategoryId = c.Id
		WHERE R.Id = @ReportId)

	IF @employeedDept != @reportDept
		BEGIN
			RAISERROR('Employee doesn''t belong to the appropriate department!', 16, 1)
		END

	ELSE
		BEGIN
			UPDATE Reports
			SET EmployeeId = @EmployeeId
			WHERE Id = @ReportId
		END
GO

EXEC usp_AssignEmployeeToReport 30, 1
EXEC usp_AssignEmployeeToReport 17, 2

