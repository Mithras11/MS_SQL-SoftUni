CREATE DATABASE TableRelations
USE TableRelations

--First problem

CREATE TABLE Persons(
	PersonID INT IDENTITY PRIMARY KEY NOT NULL,
	FirstName NVARCHAR(30) NOT NULL,
	Salary DECIMAl(8,2) NOT NULL,
	PassportID INT NOT NULL
)

INSERT INTO Persons	(FirstName, Salary, PassportID)
	VALUES
		('Roberto', 43300.00, 102),
		('Tom', 56100.00, 103),
		('Yana', 60200.00, 101)

CREATE TABLE Passports(
	PassportID INT IDENTITY(101,1) PRIMARY KEY NOT NULL,
	PassportNumber CHAR(8)
)

INSERT INTO Passports (PassportNumber)
	VALUES
		('N34FG21B'),
		('K65LO4R7'),
		('ZE657QP2')

ALTER TABLE Persons
	ADD CONSTRAINT FK_PersonsPassports
	FOREIGN KEY (PassportID) REFERENCES Passports(PassportID)




--Second Problem

CREATE TABLE Models(
	ModelID INT IDENTITY(101,1) PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(30) NOT NULL,
	ManufacturerID INT NOT NULL,
)

INSERT INTO Models([Name], ManufacturerID)
	VALUES
		('X1', 1),
		('i6', 1),
		('Model S', 2),
		('Model X', 2),
		('Model 3', 2),
		('Nova', 3)
				

CREATE TABLE Manufacturers(
	ManufacturerID INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(30) NOT NULL,
	EstablishedOn DATE NOT NULL
)

INSERT INTO Manufacturers([Name], EstablishedOn)
	VALUES
		('BMW', '07/03/1916'),
		('Tesla', '01/01/2003'),
		('Lada', '01/05/1966')

ALTER TABLE Models
	ADD CONSTRAINT FK_ModelManufacturer
	FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)



--Third Problem

CREATE Table Students(
	StudentID INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(30) NOT NULL
)

INSERT INTO Students([Name])
	VALUES
		('Mila'),
		('Toni'),
		('Ron')
		
CREATE Table Exams(
	ExamID INT IDENTITY(101,1) PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(30) NOT NULL
)

INSERT INTO Exams([Name])
	VALUES
		('SpringMVC'),
		('Neo4j'),
		('Oracle11g')

CREATE TABLE StudentsExams(
	StudentID INT NOT NULL FOREIGN KEY REFERENCES Students(StudentID),
	ExamID INT NOT NULL FOREIGN KEY REFERENCES Exams(ExamID),
	CONSTRAINT PK_StudentsExams PRIMARY KEY(StudentID, ExamID),		
)


INSERT INTO StudentsExams(StudentID,ExamID)
	VALUES
		(1,101),
		(1,102),
		(2,101),
		(3,103),
		(2,102),
		(2,103)


--Fourth problem

CREATE TABLE Teachers(
	TeacherID INT IDENTITY(101,1) PRIMARY KEY NOT NULL,
	[Name] VARCHAR(20) NOT NULL,
	ManagerID INT,
    CONSTRAINT FK_ManagerTeacher FOREIGN KEY(ManagerID) REFERENCES Teachers(TeacherID)
)

INSERT INTO Teachers([Name],ManagerID)
	VALUES
		('John',NULL),
		('Maya',106),
		('Silvia',106),
		('Ted',105),
		('Mark',101),
		('Greta',101)


--Fifth problem

CREATE DATABASE OnlineStore
USE OnlineStore

CREATE TABLE Orders(
	OrderID INT IDENTITY PRIMARY KEY NOT NULL,
	CustomerID INT NOT NULL,
)

CREATE TABLE Customers(
	CustomerID INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] VARCHAR(50) NOT NULL,
	Birthday DATE,
	CityID INT NOT NULL
)

CREATE TABLE Cities(
	CityID INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE OrderItems(
	OrderID INT  NOT NULL,
	ItemID INT NOT NULL
)

CREATE TABLE Items(
	ItemID INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] VARCHAR(50) NOT NULL,
	ItemTypeID INT
)

CREATE TABLE ItemTypes(
	ItemTypeID INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] VARCHAR(50) NOT NULL	
)


ALTER TABLE Orders
ADD CONSTRAINT FK_OrderCustomer
	FOREIGN KEY (CustomerID)
	REFERENCES Customers(CustomerID)

ALTER TABLE Customers
ADD CONSTRAINT FK_CustomerCity
	FOREIGN KEY (CityID)
	REFERENCES Cities(CityID)
	
ALTER TABLE Items
ADD CONSTRAINT FK_CurrentItemType
	FOREIGN KEY (ItemTypeID)
	REFERENCES ItemTypes(ItemTypeID)	

ALTER TABLE OrderItems
ADD FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID),
	CONSTRAINT PK_OrderItem	PRIMARY KEY (OrderID, ItemID)



--Sixth problem

CREATE DATABASE University
USE University

CREATE TABLE Majors(
	MajorID INT IDENTITY PRIMARY KEY NOT NULL,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Students(
	StudentID INT IDENTITY PRIMARY KEY NOT NULL,
	StudentNumber INT NOT NULL,
	StudentName VARCHAR(50) NOT NULL,
	MajorID INT
)

CREATE TABLE Agenda(
	StudentID INT NOT NULL,
	SubjectID INT NOT NULL
)

CREATE TABLE Subjects(
	SubjectID INT IDENTITY PRIMARY KEY NOT NULL,
	SubjectName VARCHAR(50) NOT NULL
)

CREATE TABLE Payments(
	PaymentID INT IDENTITY PRIMARY KEY NOT NULL,
	PaymentDate DATE NOT NULL,
	PaymentAmount Decimal(6,2) NOT NULL,
	StudentID INT
)

ALTER TABLE Students
ADD CONSTRAINT FK_StudentMajor
	FOREIGN KEY (MajorID)
	REFERENCES Majors(MajorID)
	
ALTER TABLE Payments
ADD CONSTRAINT FK_PaymentStudent
	FOREIGN KEY (StudentID)
	REFERENCES Students(StudentID)
	
ALTER TABLE Agenda
ADD FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID),
	CONSTRAINT PK_PaymentStudent PRIMARY KEY (StudentID, SubjectID)


--Ninth problem

USE Geography

SELECT Mountains.MountainRange, Peaks.PeakName, Peaks.Elevation
FROM PEAKS
INNER JOIN Mountains ON Peaks.MountainId = Mountains.Id
WHERE MountainRange ='Rila'
ORDER BY Elevation DESC