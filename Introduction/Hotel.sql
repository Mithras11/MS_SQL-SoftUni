USE Hotel

CREATE TABLE Employees(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(15) NOT NULL,
	LastName NVARCHAR(20) NOT NULL,
	Title VARCHAR(30) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Employees
	VALUES
		('Kalo', 'Balov', 'Nobody', NULL),
		('Misho', 'Dimchov', 'Someone else', NULL),
		('Mimi', 'Lalova', 'She', 'just a female')

CREATE TABLE Customers(
	AccountNumber BIGINT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(15) NOT NULL,
	LastName NVARCHAR(20) NOT NULL,
	PhoneNumber VARCHAR(20) NOT NULL,
	EmergencyName NVARCHAR(MAX) NOT NULL,
	EmergencyNumber SMALLINT NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Customers
	VALUES
		('Kalo', 'Balov', '+359 899 899 090', 'K', 122, NULL),
		('Yalo', 'Balov', '+359 899 899 092', 'Y', 922, NULL),
		('Balo', 'Balov', '+359 899 899 091', 'B', 522, 'Blahblah')
	

CREATE TABLE RoomStatus(
	RoomStatus VARCHAR(20) PRIMARY KEY NOT NULL,   ----suspcious
	Notes VARCHAR(MAX)
)

INSERT INTO RoomStatus
	VALUES
		('Occupied', NULL),
		('Available', NULL),
		('Booked', NULL)


CREATE TABLE RoomTypes(
	RoomType VARCHAR(20) PRIMARY KEY NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO RoomTypes
	VALUES
		('small room', NULL),
		('cave', NULL),
		('large room', NULL)
	
	
CREATE TABLE BedTypes(
	BedType VARCHAR(20) PRIMARY KEY NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO BedTypes
	VALUES
		('small bed', NULL),
		('1 person only', NULL),
		('large bed', NULL)


CREATE TABLE Rooms(
	RoomNumber SMALLINT PRIMARY KEY NOT NULL,
	RoomType VARCHAR(20) FOREIGN KEY REFERENCES RoomTypes(RoomType) NOT NULL,
	BedType VARCHAR(20) FOREIGN KEY REFERENCES BedTypes(BedType) NOT NULL,
	Rate DECIMAL(2,1) NOT NULL,
	RoomStatus VARCHAR(20) FOREIGN KEY REFERENCES RoomStatus(RoomStatus) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Rooms
	VALUES
		(122, 'small room', 'small bed', 3.2, 'occupied', NULL),
		(822, 'small room', 'small bed', 3.2, 'occupied', NULL),
		(622, 'cave', '1 person only', 4.2, 'occupied', 'still available')

CREATE TABLE Payments(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	EmployeeId BIGINT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
	PaymentDate DATE NOT NULL,
	AccountNumber INT NOT NULL,
	FirstDateOccupied DATE NOT NULL,
	LastDateOccupied DATE NOT NULL,
	TotalDays TINYINT NOT NULL,
	AmountCharged DECIMAL(6,2) NOT NULL,
	TaxRate DECIMAL(2,1) NOT NULL,
	PaymentTotal DECIMAL(6,2) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Payments
	VALUES
		(1, '09-13-2018', 123456, '08-13-2018', '09-13-2018', 1, 2000, 0.1, 2200, NULL),
		(2, '09-13-2018', 023456, '08-13-2018', '09-13-2018', 1, 2000, 0.1, 2200, NULL),
		(3, '09-13-2018', 120056, '08-13-2018', '09-13-2018', 1, 2000, 0.1, 2200, 'same')


CREATE TABLE Occupancies(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	EmployeeId BIGINT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
	DateOccupied DATE NOT NULL,
	AccountNumber INT NOT NULL,
	RoomNumber SMALLINT NOT NULL,
	RateApplied DECIMAL(2,1),
	PhoneCharge DECIMAL(6,2) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Occupancies
	VALUES
		(1, '09-13-2018', 123456, 122, 0.1, 600, NULL),
		(2, '09-13-2018', 120456, 822, 0.1, 0, NULL),
		(3, '09-13-2018', 123906, 622, 0.1, 400, NULL)



-----

UPDATE Payments
SET TaxRate -= (TaxRate * 0.03)

SELECT TaxRate FROM Payments

------

TRUNCATE TABLE Occupancies
