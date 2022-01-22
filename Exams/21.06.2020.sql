CREATE DATABASE TripService

GO

USE TripService

GO

---------
--1. Design

CREATE TABLE Cities
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(20) NOT NULL,
	CountryCode CHAR(2) NOT NULL)

CREATE TABLE Hotels
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(30) NOT NULL,
	CityId INT FOREIGN KEY REFERENCES Cities(Id)  NOT NULL,
	EmployeeCount INT NOT NULL,
	BaseRate DECIMAL(15, 2))

CREATE TABLE Rooms
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	Price DECIMAL(15, 2) NOT NULL,
	[Type] VARCHAR(20) NOT NULL,
	Beds INT NOT NULL,
	HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL)


CREATE TABLE Trips
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL,
	BookDate DATE  NOT NULL,
	ArrivalDate DATe NOT NULL,
	ReturnDate DATE NOT NULL,
	CancelDate DATE,
	CONSTRAINT CK_BookArrival CHECK(BookDate < ArrivalDate),
	CONSTRAINT CK_ArrivalReturn CHECK(ArrivalDate < ReturnDate))


CREATE TABLE Accounts
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName VARCHAR(50) NOT NULL,
	MiddleName VARCHAR(20),
	LastName VARCHAR(50) NOT NULL,
	CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
	BirthDate DATE NOT NULL,
	Email VARCHAR(100) NOT NULL UNIQUE)

CREATE TABLE AccountsTrips
	(AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL,
	TripId INT FOREIGN KEY REFERENCES Trips(Id) NOT NULL,
	Luggage INT CHECK(Luggage >= 0) NOT NULL,
	CONSTRAINT PK_AccountsTrips PRIMARY KEY(AccountId, TripId))

--2 INSERT

INSERT INTO Accounts (FirstName, MiddleName, LastName, CityId, BirthDate, Email)
VALUES
	('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
	('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
	('Ivan', 'Petrovich', 'Pavlov',	59,	'1849-09-26', 'i_pavlov@softuni.bg'),
	('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips (RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate)
VALUES
	(101, '2015-04-12',	'2015-04-14', '2015-04-20',	'2015-02-02'),
	(102, '2015-07-07', '2015-07-15', '2015-07-22',	'2015-04-29'),
	(103, '2013-07-17',	'2013-07-23', '2013-07-24',	NULL),
	(104, '2012-03-17',	'2012-03-31', '2012-04-01',	'2012-01-10'),
	(109, '2017-08-07',	'2017-08-28', '2017-08-29',	NULL)

--3 Update

UPDATE Rooms
SET Price *= 1.14
WHERE HotelId IN (5, 7, 9)

--4 Delete

DELETE FROM AccountsTrips
WHERE AccountId = 47

--5 EEE-mails

SELECT  FirstName,
		LastName,
		FORMAT(Birthdate, 'MM-dd-yyyy') AS Birthdate, 
		c.[Name] AS Hometown,
		a.Email
FROM Accounts AS a
JOIN Cities AS c ON
	a.CityId = c.Id
WHERE a.Email LIKE 'e%'
ORDER BY c.[Name]

--6 City statistics

SELECT c.[Name] AS City, COUNT(h.Id) AS Hotels
FROM Cities AS c
JOIN Hotels AS h ON
	c.Id = h.CityId
GROUP BY c.[Name]
ORDER BY Hotels DESC, City ASC

--7 Longest and shortest trips

SELECT 
	a.Id AS AccountId, 
	CONCAT(a.FirstName, ' ', a.LastName) AS FullName,
	MAX(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS LongestTrip,
	MIN(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS ShortestTrip
FROM Trips AS t
JOIN AccountsTrips AS ac_tr ON
	t.Id = ac_tr.TripId
JOIN Accounts AS a ON
	ac_tr.AccountId = a.Id
WHERE t.CancelDate IS NULL
	AND a.MiddleName IS NULL
GROUP BY a.Id, A.FirstName, A.LastName
ORDER BY LongestTrip DESC, ShortestTrip ASC

--8 Metropolis

SELECT	c.Id,
		c.[Name] AS City,
		c.CountryCode AS Country,
		COUNT(a.Id) AS Accounts
FROM Cities AS c
JOIN Accounts AS a ON
	c.Id = a.CityId
GROUP BY c.Id, c.[Name], c.CountryCode
ORDER BY Accounts DESC

--9 Romantic gateways

SELECT 
		a.Id,
		a.Email,
		ct.[Name],
		COUNT(t.Id) AS Trips
FROM Accounts AS a
JOIN AccountsTrips AS at ON
	a.Id = [at].AccountId
JOIN Trips AS t ON
	[at].TripId = t.Id
JOIN Rooms AS r ON
	t.RoomId = r.Id
JOIN Hotels AS h ON
	r.HotelId = h.Id
JOIN Cities AS ct ON
	h.CityId = ct.Id
WHERE a.CityId = h.CityId
GROUP BY a.Id, a.Email, ct.[Name]
ORDER BY Trips DESC, Id ASC

--10 GDPR Violation

SELECT  t.Id,
		CONCAT_WS(' ', FirstName, MiddleName, LastName) AS FullName,
		c.[Name] AS [From],
		c2.[Name] AS [To],
		IIF(t.CancelDate IS NOT NULL, 'Canceled',
				CONCAT(DATEDIFF(day, t.ArrivalDate, t.ReturnDate), ' days')) AS Duration
FROM Trips AS t
JOIN AccountsTrips AS [at] ON
	t.Id = [at].TripId
JOIN Accounts AS a ON
	[at].AccountId = a.Id
JOIN Cities AS c ON
	a.CityId = c.Id
JOIN Rooms AS r ON
	t.RoomId = r.Id
JOIN Hotels AS h ON
	r.HotelId = h.Id
JOIN Cities AS c2 ON
	h.CityId = c2.Id
ORDER BY FullName, t.Id

--11 Available room

CREATE OR ALTER FUNCTION  udf_GetAvailableRoom (@HotelId int, @Date DATE, @People int)
RETURNS VARCHAR(200)
AS
BEGIN

	DECLARE @roomId INT = (SELECT TOP(1) r.Id
							FROM Rooms AS r  
							LEFT JOIN Trips AS t ON
								r.Id = t.RoomId
							WHERE r.HotelId = @HotelId
							AND ((@Date NOT BETWEEN t.ArrivalDate AND t.ReturnDate
									AND t.CancelDate IS NOT NULL) OR
								t.ArrivalDate IS NULL OR t.ReturnDate IS NULL OR t.CancelDate IS NULL) --????
							AND r.Beds >= @People
							ORDER BY r.Price DESC);

	IF (@roomId IS NULL) RETURN 'No rooms available';


	DECLARE @baseRate DECIMAL(5,2)  = (SELECT BaseRate FROM Hotels WHERE Id = @HotelId);
	DECLARE @roomPrice DECIMAL(18, 2) = (SELECT Price FROM Rooms WHERE Id = @roomId);
	DECLARE @roomType VARCHAR(20) = (SELECT [Type] FROM Rooms WHERE Id = @roomId);
	DECLARE @beds INT = (SELECT Beds FROM Rooms WHERE Id = @roomId);

	DECLARE @totalPrice DECIMAL(18, 2) = (@baseRate + @roomPrice) * @People;

	RETURN ('Room ' + CAST(@roomId AS varchar(3)) + ': ' + @roomType +
			' (' + CAST(@beds AS varchar(3)) + ' beds)'+ ' - $' + CAST(@totalPrice AS varchar(20)))
END

--12. Switch room

CREATE OR ALTER PROCEDURE usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
	
	declare @hotId int = (SELECT r.HotelId
			FROM Trips AS t
			JOIN Rooms AS r ON
				t.RoomId = r.Id
			WHERE t.Id = @TripId) 

	declare @targethotId int = (SELECT r.HotelId
			from Rooms AS r 		
			where r.Id = @TargetRoomId )

	if @targethotId <> @hotId
	throw 50001, 'Target room is in another hotel!', 1

	------

	declare @accounts int = (select count(A.Id)
						from Accounts as a
						join AccountsTrips as [at] on
						a.Id = [at].AccountId
						where [at].TripId = @TripId)

	declare @beds int = (select Beds
					from Rooms 
					where Id = @TargetRoomId)

	if @beds < @accounts
	throw 50002, 'Not enough beds in target room!', 1

	----

	update Trips
	set RoomId = @TargetRoomId

GO
 
   ----

EXEC usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10

EXEC usp_SwitchRoom 10, 7

EXEC usp_SwitchRoom 10, 8


	




