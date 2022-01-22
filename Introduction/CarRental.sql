USE CarRental

CREATE TABLE Categories(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	CategoryName NVARCHAR(MAX) NOT NULL,
	DailyRate DECIMAL(2,1) NOT NULL,
	WeeklyRate DECIMAL(2,1) NOT NULL,
	MonthlyRate DECIMAL(2,1) NOT NULL,
	WeekendRate DECIMAL(2,1) NOT NULL
)

INSERT INTO Categories
	VALUES
		('Sport', 4.5, 4, 4.2, 5),
		('Off-Road', 4.9, 4.3, 4.2, 5),
		('Family', 4.5, 4, 4.2, 5)

CREATE TABLE Cars(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	PlateNumber VARCHAR(7) NOT NULL,
	Manufacturer VARCHAR(20) NOT NULL,
	Model VARCHAR(10) NOT NULL,
	CarYear SMALLINT NOT NULL,
	CategoryId NVARCHAR(MAX) NOT NULL,
	Doors TINYINT NOT NULL,
	Picture VARBINARY(MAX),
	Condition VARCHAR(10) NOT NULL,
	Available BIT NOT NULL
)

INSERT INTO Cars
	VALUES
		('PK 4244', 'VW', 'Golf 3', 2000, 3, 4, NULL, 'very good', 1),
		('P 4243', 'Range Rover','Beast', 2018, 2, 4, NULL, 'excellent', 0),
		('CB 4004', 'BMW', 'Bijou', 2011, 1, 2, NULL, 'perfect', 1)

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
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	DriverLicenseNumber BIGINT NOT NULL,
	FullName NVARCHAR(40) NOT NULL,
	[Address] VARCHAR(MAX) NOT NULL,
	City VARCHAR(20) NOT NULL,
	ZIPCode SMALLINT NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Customers
	VALUES
		(17181751515, 'Kalo Lyondev Balov', 'Barloga 13', 'Zlokuchene', 1615, NULL),
		(17181751512, 'Dalo Lyondev Ralov', 'Barloga 13', 'Zlokuchene', 1615, NULL),
		(17181751005, 'Malo Lyondev Halov', 'Barloga 13', 'Zlokuchene', 1615, 'Yes, same address')
		

CREATE TABLE RentalOrders(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	EmployeeId BIGINT NOT NULL,
	CustomerId BIGINT NOT NULL,
	CarId BIGINT NOT NULL,
	TankLevel TINYINT NOT NULL,
	KilometrageStart INT NOT NULL,
	KilometrageEnd INT NOT NULL,
	TotalKilometrage INT NOT NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NOT NULL,
	TotalDays SMALLINT NOT NULL,
	RateApplied DECIMAL(2,1) NOT NULL,
	TaxRate DECIMAL(2,1) NOT NULL,
	OrderStatus BIT NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO RentalOrders
	VALUES
		(1, 2, 3, 80, 60000, 60300, 300, '08-18-2021', '08-27-2021', 9, 9.8, 3.4, 1, NULL),
		(2, 2, 2, 70, 60000, 60300, 300, '08-18-2021', '08-27-2021', 9, 9.8, 3.4, 1, NULL),
		(2, 1, 1, 90, 60000, 60300, 300, '08-18-2021', '08-27-2021', 9, 9.8, 3.4, 1, 'smth')