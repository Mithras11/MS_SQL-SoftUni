CREATE DATABASE ColonialJourney 
GO

USE ColonialJourney 
GO

------

--1 DDL

CREATE TABLE Planets
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(30) NOT NULL)

CREATE TABLE Spaceports
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	PlanetId INT REFERENCES Planets(Id) NOT NULL)

CREATE TABLE Spaceships
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	Manufacturer NVARCHAR(30) NOT NULL,
	LightSpeedRate INT DEFAULT(0))

CREATE TABLE Colonists
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(20) NOT NULL,
	LastName NVARCHAR(20) NOT NULL,
	Ucn NVARCHAR(10) UNIQUE NOT NULL,
	BirthDate DATE NOT NULL)

CREATE TABLE Journeys
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	JourneyStart DATETIME NOT NULL,
	JourneyEnd DATETIME NOT NULL,
	Purpose NVARCHAR(11) NOT NULL 
		CHECK(Purpose IN ('Medical', 'Technical', 'Educational', 'Military')),
	DestinationSpaceportId INT REFERENCES Spaceports(Id) NOT NULL,
	SpaceshipId INT REFERENCES Spaceships(Id) NOT NULL)

CREATE TABLE TravelCards
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	CardNumber NCHAR(10) UNIQUE NOT NULL,
	JobDuringJourney NVARCHAR(8) NULL
		CHECK(JobDuringJourney IN ( 'Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
	ColonistId INT REFERENCES Colonists(Id) NOT NULL,
	JourneyId INT REFERENCES Journeys(Id) NOT NULL)

--2. INSERT

INSERT INTO Planets([Name])
VALUES	
	('Mars'),
	('Earth'),
	('Jupiter'),
	('Saturn')

INSERT INTO Spaceships([Name], Manufacturer, LightSpeedRate)
VALUES
	('Golf', 'VW', 3),
	('WakaWaka', 'Wakanda',	4),
	('Falcon9', 'SpaceX', 1),
	('Bed', 'Vidolov', 6)

--3. UPDATE

UPDATE Spaceships
SET LightSpeedRate += 1
WHERE Id BETWEEN 8 AND 12


--4. DELETE

DELETE FROM TravelCards
WHERE JourneyId BETWEEN 1 AND 3

DELETE FROM Journeys
WHERE Id BETWEEN 1 AND 3



--5. Select All Military Journeys

SELECT Id,
		FORMAT(JourneyStart, 'dd/MM/yyyy') AS JourneyStart, 
		FORMAT(JourneyEnd, 'dd/MM/yyyy') AS JourneyEnd
FROM Journeys 
WHERE Purpose = 'Military'
ORDER BY JourneyStart


--6. Select all pilots

SELECT  c.Id,
		CONCAT(c.FirstName, ' ', c.LastName) AS FullName
FROM Colonists AS c
JOIN TravelCards AS t ON
	c.Id = t.ColonistId
WHERE t.JobDuringJourney = 'Pilot'
ORDER BY c.Id



--7. Count colonists

SELECT COUNT(c.id) as [COUNT]
FROM Colonists AS c
JOIN TravelCards AS t ON
	c.Id = t.ColonistId
JOIN Journeys AS j ON
	t.JourneyId = j.Id
WHERE j.Purpose = 'Technical'
	

--8 Select Spaceships With Pilots

SELECT s.[Name], s.Manufacturer
FROM Spaceships AS s
JOIN Journeys AS j ON
	s.Id = j.SpaceshipId
JOIN TravelCards AS t ON
	j.Id = t.JourneyId
JOIN Colonists AS c ON
	t.ColonistId = c.Id
WHERE t.JobDuringJourney = 'Pilot' AND (DATEDIFF(YEAR, c.BirthDate, '2019-01-01')) < 30
GROUP BY s.[Name], S.Manufacturer
ORDER BY s.[Name]








--9. Planets And Journeys

SELECT  p.[Name] AS PlanetName,
		COUNT(j.Id) AS JourneyCount
FROM Planets AS p
JOIN Spaceports AS s ON
	p.Id = s.PlanetId
JOIN Journeys AS j ON
	s.Id = j.DestinationSpaceportId
GROUP BY p.[Name]
ORDER BY JourneyCount DESC, PlanetName ASC

--10 Select Second Oldest Important Colonist

SELECT * FROM
(SELECT  t.JobDuringJourney, 
		c.FirstName + ' ' + c.LastName AS FullName,
		DENSE_RANK() OVER (PARTITION BY t.JobDuringJourney ORDER BY C.BirthDate) AS [Rank]
FROM Colonists AS c
JOIN TravelCards AS t ON
	c.Id = t.ColonistId) AS T
WHERE [Rank] = 2


--11 Get colonists count

CREATE FUNCTION dbo.udf_GetColonistsCount (@PlanetName VARCHAR (30))
RETURNS INT 
AS 
BEGIN
		DECLARE @COUNT INT = (SELECT COUNT(tc.ColonistId) FROM
								TravelCards AS tc 
								JOIN Journeys AS j ON
									tc.JourneyId = j.Id
								JOIN Spaceports AS sp ON
									j.DestinationSpaceportId = sp.Id
								JOIN Planets AS p ON
									sp.PlanetId = p.Id
								WHERE p.[Name] = @PlanetName)

		RETURN @COUNT
END


SELECT dbo.udf_GetColonistsCount('Otroyphus')


--12 Change Journey Purpose

CREATE OR ALTER PROC usp_ChangeJourneyPurpose (@JourneyId INT, @NewPurpose NVARCHAR(11))
AS	
		
		declare @existingId int =(select top(1) id
								from Journeys
								where Id = @journeyId)

		if @existingId is null
			throw 50001, 'The journey does not exist!', 1

		
		declare @existingPurpose nvarchar(20) = (select top(1) purpose	
												from Journeys
												where id = @journeyId)

		if @existingPurpose = @NewPurpose
			throw 50002, 'You cannot change the purpose!', 1

		update Journeys
		set Purpose = @NewPurpose
		where Id = @journeyId

GO

EXEC usp_ChangeJourneyPurpose 4, 'Technical'
EXEC usp_ChangeJourneyPurpose 2, 'Educational'
EXEC usp_ChangeJourneyPurpose 196, 'Technical'