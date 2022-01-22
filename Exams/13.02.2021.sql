CREATE DATABASE Bitbucket
GO

USE Bitbucket
GO

---
--1. Design

CREATE TABLE Users
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	Username VARCHAR(30) NOT NULL,
	[Password] VARCHAR(30) NOT NULL,
	Email VARCHAR(50) NOT NULL)

CREATE TABLE Repositories
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(50) NOT NULL)

CREATE TABLE RepositoriesContributors
	(RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
	ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
	CONSTRAINT PK_RepositoriesContributors PRIMARY KEY(RepositoryId, ContributorId))

CREATE TABLE Issues
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	Title VARCHAR(255) NOT NULL,
	IssueStatus CHAR(6) NOT NULL,
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
	AssigneeId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL)

CREATE TABLE Commits
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Message] VARCHAR(255) NOT NULL,
	IssueId INT FOREIGN KEY REFERENCES Issues(Id),
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
	ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL)

CREATE TABLE Files
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(100) NOT NULL,
	[Size] DECIMAL(18, 2) NOT NULL,
	ParentId INT FOREIGN KEY REFERENCES Files(Id),
	CommitId INT FOREIGN KEY REFERENCES Commits(Id) NOT NULL)
	

--2 Insert

INSERT INTO Files([Name], [Size], ParentId,	CommitId)
VALUES
	('Trade.idk', 2598.0, 1, 1),
	('menu.net', 9238.31, 2, 2),
	('Administrate.soshy', 1246.93, 3, 3),
	('Controller.php', 7353.15,	4, 4),
	('Find.java', 9957.86, 5, 5),
	('Controller.json', 14034.87, 3, 6),
	('Operate.xix',	7662.92, 7,	7)

INSERT INTO Issues (Title,	IssueStatus, RepositoryId, AssigneeId)
VALUES
	('Critical Problem with HomeController.cs file', 'open', 1,	4),
	('Typo fix in Judge.html', 'open', 4, 3),
	('Implement documentation for UsersService.cs',	'closed', 8, 2),
	('Unreachable code in Index.cs', 'open', 9,	8)

--3 Update

UPDATE Issues
SET IssueStatus = 'closed'
WHERE AssigneeId = 6

-- 4 Delete

DELETE FROM RepositoriesContributors
WHERE RepositoryId = (SELECT Repositories.Id 
					FROM Repositories
					WHERE [Name] = 'Softuni-Teamwork')

DELETE FROM Issues
WHERE RepositoryId = (SELECT Repositories.Id 
					FROM Repositories
					WHERE [Name] = 'Softuni-Teamwork')

--5. Commits

SELECT Id, [Message], RepositoryId, ContributorId
FROM Commits
ORDER BY Id, [Message], RepositoryId, ContributorId

--6 Front-End

SELECT Id, [Name], [Size]
FROM Files
WHERE [Size] > 1000 AND [Name] LIKE '%html%'
ORDER BY [Size] DESC, Id ASC, [Name] ASC 

--7 Issue assignment

SELECT 
	i.Id, 
	CONCAT(u.Username,' : ', i.Title) AS IssueAssignee
FROM Issues AS i
JOIN Users AS u ON
	i.AssigneeId = u.Id
ORDER BY i.Id DESC, IssueAssignee ASC

--8 Single files

SELECT f2.Id, f2.[Name], CONCAT(f2.[Size], 'KB') AS [Size]
FROM Files AS f1
RIGHT JOIN Files AS f2 ON
	f1.ParentId = f2.Id
WHERE f1.ParentId IS NULL
ORDER BY Id, [Name], [Size] DESC

--9. Commits in repositories

SELECT TOP(5) r.Id, r.[Name], COUNT(c.Id) AS Commits
FROM Repositories AS r
JOIN Commits AS c ON
	r.Id = c.RepositoryId
JOIN RepositoriesContributors AS rc ON
	r.Id = rc.RepositoryId
GROUP BY r.Id, r.[Name]
ORDER BY Commits DESC, r.Id ASC, r.[Name] ASC 

-- 10 Average size

SELECT u.Username, AVG(f.[Size]) AS [Size]
FROM Users AS u
JOIN Commits AS c ON
	u.Id = c.ContributorId
JOIN Files AS f ON
	c.Id = f.CommitId
GROUP BY u.Username
ORDER BY [Size] DESC, Username ASC

-- 11 All user commits 

CREATE FUNCTION udf_AllUserCommits (@username VARCHAR(30))
RETURNS INT
AS
BEGIN
	RETURN	
		(SELECT COUNT(*)
		FROM Users AS u
		JOIN Commits AS c ON
			u.Id = c.ContributorId
		WHERE u.Username= @username)	
END


SELECT dbo.udf_AllUserCommits('UnderSinduxrein')

-- 12. Search for files

CREATE OR ALTER PROCEDURE usp_SearchForFiles (@fileExtension VARCHAR(10))
AS
	SELECT 
		Id, 
		[Name],
		CONCAT([Size], 'KB') AS [Size]	
	FROM Files
	WHERE Name LIKE ('%' + @fileExtension)
	ORDER BY Id, [Name], [Size] DESC
GO

EXEC usp_SearchForFiles 'txt'