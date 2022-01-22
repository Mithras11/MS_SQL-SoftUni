--1 DDL

CREATE DATABASE Airport


CREATE TABLE Planes
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(30) NOT NULL,
	Seats INT NOT NULL,
	[Range] INT NOT NULL)

CREATE TABLE Flights
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	DepartureTime DATETIME NULL,
	ArrivalTime DATETIME NULL,
	Origin NVARCHAR(50) NOT NULL,
	Destination NVARCHAR(50) NOT NULL,
	PlaneId INT REFERENCES Planes(Id) NOT NULL)

CREATE TABLE Passengers
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Age INT NOT NULL,
	[Address] NVARCHAR(30) NOT NULL,
	PassportId NVARCHAR(11) NOT NULL)

CREATE TABLE LuggageTypes
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Type] NVARCHAR(30) NOT NULL)

CREATE TABLE Luggages
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	LuggageTypeId INT REFERENCES LuggageTypes(Id) NOT NULL,
	PassengerId INT REFERENCES Passengers(Id) NOT NULL)

CREATE TABLE Tickets
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	PassengerId INT REFERENCES Passengers(Id) NOT NULL,
	FlightId INT REFERENCES Flights(Id) NOT NULL,
	LuggageId INT REFERENCES Luggages(Id) NOT NULL,
	Price DECIMAL(18, 2) NOT NULL)


--2. INSERT

INSERT INTO Planes
VALUES
	('Airbus 336', 112, 5132),
	('Airbus 330', 432, 5325),
	('Boeing 369', 231, 2355),
	('Stelt 297',  254, 2143),
	('Boeing 338', 165, 5111),
	('Airbus 558', 387, 1342),
	('Boeing 128', 345, 5541)

INSERT INTO LuggageTypes
VALUES
	('Crossbody Bag'),
	('School Backpack'),
	('Shoulder Bag')

--3 UPDATE

DECLARE @flightId INT = (SELECT id FROM Flights WHERE Destination = 'Carlsbad')

UPDATE Tickets 
SET Price *= 1.13
WHERE FlightId = @flightId


--4. DELETE


DECLARE @flightId2 INT = (SELECT id FROM Flights WHERE Destination = 'Ayn Halagim')

DELETE FROM Tickets
WHERE FlightId = @flightId2

DELETE FROM Flights
WHERE Destination = 'Ayn Halagim'

--5. The "Tr" Planes

SELECT *
FROM Planes
WHERE [Name] LIKE '%TR%'
ORDER BY Id, [Name], Seats, [Range]

--6. Flight profit

SELECT FlightId, SUM(Price) AS Price
FROM Tickets 
GROUP BY FlightId
ORDER BY Price DESC, FlightId ASC

--7. Passenger Trips

SELECT  CONCAT(p.FirstName, ' ', p.LastName) AS [Full Name],
		f.Origin, f.Destination
FROM Passengers AS p
JOIN Tickets AS t ON
	p.Id = t.PassengerId
JOIN Flights AS f ON
	t.FlightId = f.Id
ORDER BY [Full Name], Origin, Destination



--8. Non Adventures People

SELECT p.FirstName, p.LastName, p.Age
FROM Passengers AS p
LEFT JOIN Tickets AS t ON
	p.Id = t.PassengerId
WHERE t.PassengerId IS NULL
ORDER BY  p.Age DESC, p.FirstName, p.LastName


--9. Full info

SELECT  CONCAT(ps.FirstName, ' ', ps.LastName) AS [Full Name],
		p.[Name] AS [Plane Name],
		CONCAT(f.Origin, ' - ', f.Destination) AS Trip,
		lt.[Type] AS [Luggage Type]
FROM Passengers AS ps
JOIN Tickets AS t ON
	ps.Id = t.PassengerId
JOIN Flights AS f ON
	t.FlightId = f.Id
JOIN Planes AS p ON
	f.PlaneId = p.Id
JOIN Luggages AS l ON
	t.LuggageId = l.Id
JOIN LuggageTypes AS lt ON
	l.LuggageTypeId = lt.Id
ORDER BY [Full Name], [Plane Name], f.Origin, f.Destination, [Luggage Type]


	

--10. PSP

SELECT p.[Name],p.Seats, ISNULL(COUNT(t.PassengerId), 0) AS PassengerCount
FROM Planes AS p
LEFT JOIN Flights AS f ON
	p.Id = f.PlaneId
LEFT JOIN Tickets AS t ON
	f.Id = t.FlightId
GROUP BY p.[Name], p.Seats
ORDER BY PassengerCount DESC, p.[Name], p.Seats



--11 Vacation

CREATE OR ALTER FUNCTION udf_CalculateTickets(@origin NVARCHAR(50), @destination NVARCHAR(50), @peopleCount INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
		IF (@peopleCount <= 0)
			RETURN 'Invalid people count!';
		
		

		DECLARE @FLIGHTID INT = (SELECT ID FROM Flights
								WHERE ORIGIN = @ORIGIN
								AND Destination = @DESTINATION);

		IF (@FLIGHTID IS NULL)
		 	RETURN 'Invalid flight!';


			
		DECLARE @TICKETPRICE DECIMAL(18, 2) = (SELECT PRICE FROM Tickets 
											  WHERE FLIGHTID = @FLIGHTID);

		DECLARE @TOTALPRICE DECIMAL(18, 2) = @TICKETPRICE * @PEOPLECOUNT;

		RETURN 'Total price ' + CAST(@TOTALPRICE AS nvarchar(20));
		
END




SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', 33);
SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', -1);
SELECT dbo.udf_CalculateTickets('Invalid','Rancabolang', 33)




--12 Wrong Data

CREATE OR ALTER PROCEDURE usp_CancelFlights
AS
	UPDATE Flights
	SET ArrivalTime = NULL ,
		DepartureTime = NULL
	WHERE ArrivalTime > DepartureTime
GO

EXEC usp_CancelFlights

