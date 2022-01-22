CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
AS 
	SELECT [FirstName], [LastName]
	FROM [Employees]
	WHERE [Salary] > 35000


EXEC usp_GetEmployeesSalaryAbove35000

-------

CREATE OR ALTER PROCEDURE usp_GetEmployeesSalaryAboveNumber @number DECIMAL(18,4)
AS
	SELECT [FirstName], [LastName]
	FROM [Employees]
	WHERE [Salary] >= @number
GO

EXEC usp_GetEmployeesSalaryAboveNumber 48100

-------

CREATE OR ALTER PROCEDURE  usp_GetTownsStartingWith @string NVARCHAR(MAX)
AS
	SELECT [Name] AS [Town]
	FROM Towns
	WHERE [Name] LIKE @string + '%'
GO

EXEC usp_GetTownsStartingWith 'B'

------

CREATE OR ALTER PROC usp_GetEmployeesFromTown @Name NVARCHAR(MAX)
AS
	SELECT E.[FirstName],E.[LastName]
	FROM Employees AS E
	JOIN Addresses AS A ON E.AddressID = A.AddressID
	JOIN Towns AS T ON A.TownID=T.TownID
	WHERE T.Name = @Name
GO

EXEC usp_GetEmployeesFromTown 'Sofia'

---------

CREATE FUNCTION  ufn_GetSalaryLevel (@salary DECIMAL(18,4))
RETURNS NVARCHAR(7)
AS
BEGIN
	DECLARE @SalaryLevel NVARCHAR(7)

	SET @SalaryLevel=
		CASE
		WHEN @salary < 30000 THEN 'Low'
		WHEN @salary BETWEEN 30000 AND 50000 THEN 'Average'
		ELSE 'High'
	END

	RETURN @SalaryLevel
END


SELECT [Salary], (dbo.ufn_GetSalaryLevel([Salary])) AS [Salary Level]
FROM Employees

--------

CREATE OR ALTER PROCEDURE  usp_EmployeesBySalaryLevel @salaryLevel NVARCHAR(10)
AS
	SELECT [FirstName], [LastName]
	FROM Employees
	WHERE dbo.ufn_GetSalaryLevel([Salary]) = @salaryLevel
GO

EXEC usp_EmployeesBySalaryLevel 'High'

-------

CREATE OR ALTER FUNCTION ufn_IsWordComprised (@setOfLetters NVARCHAR(MAX), @word NVARCHAR(MAX))
RETURNS BIT
AS
BEGIN	
	DECLARE @index INT = 1 
	
	WHILE(@index <= LEN(@word))
		BEGIN
			IF CHARINDEX(SUBSTRING(@word, @index, 1), @setOfLetters) = 0
				BEGIN
					RETURN 0
				END

			SET @index += 1
		END

	RETURN 1
END


SELECT [dbo].[ufn_IsWordComprised]('oistmiahf', 'Sofia')
SELECT [dbo].[ufn_IsWordComprised]('oistmiahf', 'halves')
SELECT [dbo].[ufn_IsWordComprised]('bobr', 'Rob')
SELECT [dbo].[ufn_IsWordComprised]('pppp', 'Guy')

-------

CREATE OR ALTER PROCEDURE usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS
BEGIN
	DELETE 
	FROM EmployeesProjects
	WHERE EmployeeID IN
		(SELECT EmployeeID
		FROM Employees
		WHERE DepartmentID = @departmentId)

	
	UPDATE Employees
	SET ManagerID = NULL
	WHERE ManagerID IN
		(SELECT EmployeeID
		FROM Employees
		WHERE DepartmentID = @departmentId)


	ALTER TABLE Departments
		ALTER COLUMN ManagerID INT NULL;

	UPDATE Departments
	SET ManagerID = NULL
	WHERE ManagerID IN 
		(SELECT EmployeeID
		FROM Employees
		WHERE DepartmentID = @departmentId)

	DELETE 
	FROM Employees
	WHERE DepartmentID = @departmentId

	DELETE
	FROM Departments
	WHERE DepartmentID = @departmentId

	SELECT COUNT(*)
	FROM Employees
	WHERE DepartmentID = @departmentId
END

GO

EXEC usp_DeleteEmployeesFromDepartment 1

-----

USE Bank

CREATE OR ALTER PROC usp_GetHoldersFullName
AS
	SELECT (CONCAT(AH.[FirstName],' ', AH.[LastName])) AS [Full Name]
	FROM AccountHolders AS AH   
GO

EXEC usp_GetHoldersFullName

--------

CREATE OR ALTER PROC usp_GetHoldersWithBalanceHigherThan (@amount DECIMAL(18,4))
AS
	SELECT [FirstName], [LastName]
	FROM
		(SELECT AH.[FIRSTNAME],AH.[LASTNAME], SUM(ACC.BALANCE) AS [TOTAL SUM]
		FROM AccountHolders AS AH
		JOIN Accounts AS ACC
		ON AH.Id=ACC.AccountHolderId
		GROUP BY AH.Id ,AH. FirstName, AH.LastName) AS TMP
	WHERE [TOTAL SUM] > @amount
	ORDER BY [FirstName], [LastName]
GO

EXEC usp_GetHoldersWithBalanceHigherThan 10000

---------

CREATE OR ALTER FUNCTION ufn_CalculateFutureValue 
			(@sum DECIMAL(18,4), @interest_rate FLOAT, @num_of_years INT)
RETURNS DECIMAL(18,4)
AS
BEGIN
	RETURN (@sum * (POWER((1 + @interest_rate), @num_of_years)))
END

SELECT [dbo].[ufn_CalculateFutureValue](1000, 0.1, 5)

----------

CREATE OR ALTER PROC usp_CalculateFutureValueForAccount 
			(@accountID INT, @interest_rate FLOAT)
AS
	SELECT  ah.[Id] AS [Account Id],
		ah.[FirstName] AS [First Name],
		ah.[LastName] AS [Last Name],
		acc.[Balance] AS [Current Balance],
		(SELECT [dbo].[ufn_CalculateFutureValue]	
				(acc.[Balance], @interest_rate, 5))	
						AS [Balance in % years]
	FROM AccountHolders AS ah
	JOIN Accounts AS acc ON ah.Id = acc.AccountHolderId
	WHERE acc.Id = @accountID
GO

EXEC usp_CalculateFutureValueForAccount  1, 0.1
----
USE Diablo



CREATE OR ALTER FUNCTION ufn_CashInUsersGames(@gameName NVARCHAR(MAX))
RETURNS TABLE 
AS
RETURN	SELECT SUM(Cash) AS SumCash
	FROM
		(SELECT *
			FROM
				(SELECT ROW_NUMBER() OVER (PARTITION BY GameId ORDER BY Cash DESC) AS Row_Num, GameId, GameName, Cash
				FROM 
					(SELECT g.Id AS GameId, g.[Name] AS GameName, ug.Cash
						FROM [dbo].[UsersGames] AS ug
						JOIN Games AS g ON
						ug.GameId = g.Id
					  ) AS TMP1
				) AS TMP2
			WHERE Row_Num % 2 != 0) AS TMP3
	GROUP BY GameName
	HAVING GameName = @gameName

SELECT * FROM  dbo.ufn_CashInUsersGames('LOVE IN A MIST')

------ 
--CONCISE VERSION OF PREVIOUS ASSIGNMENT


CREATE OR ALTER FUNCTION ufn_CashInUsersGames (@gameName NVARCHAR(MAX))
RETURNS TABLE 
AS
RETURN	SELECT SUM(Cash) AS SumCash
	FROM
		(SELECT ROW_NUMBER() OVER (ORDER BY ug.Cash DESC) AS RowNum, Cash
				FROM 
				    [UsersGames] AS ug
					JOIN Games AS g ON
					ug.GameId = g.Id
					WHERE g.[Name] = @gameName
					) AS tmp
				WHERE RowNum % 2 != 0

SELECT * FROM  dbo.ufn_CashInUsersGames('LOVE IN A MIST')