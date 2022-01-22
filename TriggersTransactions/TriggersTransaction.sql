USE Bank
GO

--1.Create Table Logs

CREATE TABLE Logs 
	(LogId INT PRIMARY KEY IDENTITY NOT NULL,
	AccountId INT REFERENCES Accounts(Id) NOT NULL,
	OldSum MONEY NOT NULL,
	NewSum MONEY NOT NULL)

CREATE TRIGGER tr_UpdateSum
ON Accounts FOR UPDATE
AS
	INSERT INTO  Logs (AccountId, OldSum, NewSum)
		(SELECT i.Id, d.Balance, I.Balance
		FROM inserted as I
		JOIN deleted as d ON
			i.Id = d.Id
		WHERE i.Balance != d.Balance)
GO

--2.Create Table Emails

CREATE TABLE  NotificationEmails
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	Recipient INT REFERENCES Accounts(Id) NOT NULL,
	[Subject] VARCHAR(50) NOT NULL,
	Body VARCHAR(80) NOT NULL)

CREATE OR ALTER TRIGGER tr_SendEmail
ON Logs FOR INSERT
AS
	DECLARE @recipient AS VARCHAR(4) = CAST((SELECT AccountId FROM inserted) AS VARCHAR(4));
	DECLARE @old VARCHAR(18) = (SELECT OldSum FROM inserted);
	DECLARE @new VARCHAR(18) = (SELECT NewSum FROM inserted);
	DECLARE @date VARCHAR(100) = convert(varchar(30), getdate(), 100);


	INSERT INTO NotificationEmails
		VALUES
		(@recipient,
		'Balance change for account: ' + @recipient,
		'On ' + @date + ' your balance was changed from ' + @old + ' to ' + @new + '.')

GO

--3. Deposit money

CREATE OR ALTER PROCEDURE usp_DepositMoney (@AccountId INT, @MoneyAmount MONEY)
AS
	BEGIN TRANSACTION
		IF (@MoneyAmount < 0)
			BEGIN
				ROLLBACK;
				THROW 50005, 'Money amount cannot be negative', 1;
			END

		IF (SELECT COUNT(*) FROM (SELECT Id FROM Accounts WHERE Id = @AccountId) AS t) = 0
			BEGIN
				ROLLBACK;
				THROW 50005, 'Invalid AccountId', 1;
			END


		UPDATE Accounts
		SET Balance += @MoneyAmount
		WHERE Id = @AccountId

		COMMIT
GO

EXEC usp_DepositMoney 1,10

--4.Withdraw Money

CREATE OR ALTER PROCEDURE usp_WithdrawMoney (@AccountId INT, @MoneyAmount MONEY)
AS
	BEGIN TRANSACTION
		IF (@MoneyAmount < 0)
			BEGIN
				ROLLBACK;
				THROW 50005, 'Money amount cannot be negative', 1;
			END

		IF (SELECT COUNT(*) FROM (SELECT Id FROM Accounts WHERE Id = @AccountId) AS t) = 0
			BEGIN
				ROLLBACK;
				THROW 50005, 'Invalid AccountId', 1;
			END


		UPDATE Accounts
		SET Balance -= @MoneyAmount
		WHERE Id = @AccountId
			   
	COMMIT
GO

EXEC usp_WithdrawMoney 5, 25

--5.Money Transfer

CREATE OR ALTER PROC usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount MONEY)
AS
	BEGIN TRANSACTION
		IF (@Amount > 0)
			BEGIN
				EXEC usp_WithdrawMoney @SenderId, @Amount
				EXEC usp_DepositMoney @ReceiverId, @Amount
			END

	COMMIT
GO

EXEC usp_TransferMoney 5, 1, 500

--

USE Diablo
GO 

--6.Trigger
--6.1
CREATE TRIGGER tr_RestrictInsertingItems
ON UserGameItems INSTEAD OF INSERT
AS
	INSERT INTO UserGameItems
		SELECT i.Id, ug.Id
		FROM inserted
		JOIN Items AS i ON
			ItemId = i.Id 
		JOIN UsersGames AS ug ON
			UserGameId = ug.Id		
		WHERE i.MinLevel >= ug.[Level]
GO
 
--6.2

UPDATE UsersGames
SET Cash += 50000
FROM UsersGames AS ug
JOIN Games AS g ON
	ug.GameId = g.Id
JOIN Users AS u ON
	ug.UserId = u.Id
WHERE g.[Name] = 'Bali'
	AND u.Username IN
	('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')


--6.3

CREATE OR ALTER PROC usp_BuyItems (@Username nvarchar(50))
AS
BEGIN
    DECLARE @UserId int =
        (SELECT id
         FROM Users
         WHERE Username = @Username);

    DECLARE @GameId int=
        (SELECT id
         FROM Games
         WHERE Name = 'Bali');

    DECLARE @UserGameId int=
        (SELECT Id
         FROM UsersGames
         WHERE UserId = @UserId
           AND GameId = @GameId);

    DECLARE @UserGameLevel int=
            (SELECT Level FROM UsersGames WHERE Id = @UserGameId);


			-----------

    DECLARE @IdCounter int = 251;

    WHILE @IdCounter <= 539
        BEGIN
            DECLARE @ItemId int = @IdCounter;

            DECLARE @ItemPrice money=
                    (SELECT Price FROM Items WHERE Id = @ItemId)

            DECLARE @ItemLevel int=
                    (SELECT MinLevel FROM Items WHERE Id = @ItemId);

            DECLARE @UserGameCash money=
                    (SELECT Cash FROM UsersGames WHERE id = @UserGameId);

            IF (@UserGameCash >= @ItemPrice AND @UserGameLevel >= @ItemLevel)
                BEGIN
                    UPDATE UsersGames
                    SET Cash-=@ItemPrice
						WHERE Id = @UserGameId
                    INSERT INTO UserGameItems
						VALUES (@ItemId, @UserGameId)
                END

            SET @IdCounter += 1;


            IF (@IdCounter = 300)
                BEGIN
                    SET @IdCounter = 501;
                END
        END
END
GO

EXEC usp_BuyItems 'baleremuda'
EXEC usp_BuyItems 'loosenoise'
EXEC usp_BuyItems 'inguinalself'
EXEC usp_BuyItems 'buildingdeltoid'
EXEC usp_BuyItems 'monoxidecos'


--6.4

SELECT u.Username, g.[Name], ug.Cash, i.[Name] AS [Item Name]
FROM Users AS u
JOIN UsersGames AS ug ON
	u.Id = ug.UserId
JOIN Games AS g ON
	ug.GameId = g.Id
JOIN UserGameItems AS ugi ON
	ug.Id = ugi.UserGameId
JOIN Items AS i ON
	ugi.ItemId = i.Id
WHERE g.[Name] = 'Bali'
ORDER BY Username, [Item Name]





--8.Employees with Three Projects

USE SoftUni

CREATE OR ALTER PROCEDURE usp_AssignProject(@employeeId INT, @projectID INT)
AS
	BEGIN TRANSACTION
	 
	DECLARE @projectsCount INT = (SELECT COUNT(*)  FROM EmployeesProjects WHERE EmployeeID = @employeeId);

	IF (@projectsCount >= 3)
	BEGIN
		ROLLBACK;
		THROW 500008, 'The employee has too many projects!', 1
	END

	INSERT INTO EmployeesProjects
	VALUES (@employeeId, @projectID)

	COMMIT
GO


EXEC usp_AssignProject 71, 32
EXEC usp_AssignProject 1, 40

--9.Delete Employees

CREATE TABLE Deleted_Employees
	(EmployeeId INT PRIMARY KEY NOT NULL,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	MiddleName VARCHAR(50) NULL,
	JobTitle VARCHAR(50) NOT NULL,
	DepartmentId INT REFERENCES Departments(DepartmentId) NOT NULL,
	Salary MONEY NOT NULL)


CREATE OR ALTER TRIGGER tr_Store_Info_About_Deleted_Employees 
ON Employees
FOR DELETE
AS
	DECLARE @employeeId INT = (SELECT EmployeeId FROM deleted);
	DECLARE @firstName VARCHAR(50) = (SELECT FirstName FROM deleted);
	DECLARE @lastName VARCHAR(50) = (SELECT LastName FROM deleted);
	DECLARE @middleName VARCHAR(50) = (SELECT MiddleName FROM deleted);
	DECLARE @jobTitle VARCHAR(50) = (SELECT JobTitle FROM deleted);
	DECLARE @departmentID INT = (SELECT DepartmentID FROM deleted);
	DECLARE @salary MONEY = (SELECT Salary FROM deleted);

	INSERT INTO Deleted_Employees
	VALUES
		(@employeeId, @firstName, @lastName, @middleName, @jobTitle, @departmentID, @salary)
GO


DELETE FROM EmployeesProjects
WHERE EmployeeID = 5

DELETE FROM Employees
WHERE EmployeeID = 5

SELECT * FROM Deleted_Employees
