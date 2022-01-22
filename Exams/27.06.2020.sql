CREATE DATABASE WMS 

GO

USE WMS

GO

--1.Database design

CREATE TABLE Clients 
	(ClientId INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Phone NCHAR(12) NOT NULL)

CREATE TABLE Mechanics
	(MechanicId INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	[Address] NVARCHAR(255) NOT NULL)


CREATE TABLE Models
	(ModelId INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50) UNIQUE NOT NULL)

CREATE TABLE Jobs
	(JobId INT PRIMARY KEY IDENTITY NOT NULL,
	ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL,
	[Status] NVARCHAR(11) DEFAULT 'Pending'
			CHECK([Status] IN ('Pending', 'In Progress', 'Finished')) NOT NULL,
	ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL,
	MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId) NULL,
	IssueDate DATE NOT NULL,
	FinishDate DATE NULL)


CREATE TABLE Orders
	(OrderId INT PRIMARY KEY IDENTITY NOT NULL,
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
	IssueDate DATE NULL,
	Delivered BIT DEFAULT 0)

CREATE TABLE Vendors
	(VendorId INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50) UNIQUE NOT NULL)

CREATE TABLE Parts
	(PartId INT PRIMARY KEY IDENTITY NOT NULL,
	SerialNumber NVARCHAR(50) UNIQUE NOT NULL,
	[Description] NVARCHAR(255) NULL,
	Price DECIMAL(6,2) CHECK(Price > 0) NOT NULL,
	VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL,
	StockQty INT CHECK(StockQty >= 0) DEFAULT 0)

CREATE TABLE OrderParts
	(OrderId INT NOT NULL,
	PartId int NOT NULL,
	Quantity INT DEFAULT 1 CHECK(Quantity > 0) NOT NULL,
	PRIMARY KEY (OrderId, PartId),
	FOREIGN KEY(OrderId) REFERENCES Orders(OrderId),
	FOREIGN KEY(PartId) REFERENCES Parts(PartId))

CREATE TABLE PartsNeeded
	(JobId INT NOT NULL,
	PartId int NOT NULL,
	Quantity INT DEFAULT 1, CHECK(Quantity > 0),
	PRIMARY KEY (JobId, PartId),
	FOREIGN KEY(JobId) REFERENCES Jobs(JobId),
	FOREIGN KEY(PartId) REFERENCES Parts(PartId))


--2. Insert

INSERT INTO Clients(FirstName, LastName, Phone)
VALUES
	('Teri', 'Ennaco', '570-889-5187'),
	('Merlyn', 'Lawler', '201-588-7810'),
	('Georgene', 'Montezuma', '925-615-5185'),
	('Jettie',	'Mconnell',	'908-802-3564'),
	('Lemuel',	'Latzke', '631-748-6479'),
	('Melodie',	'Knipp', '805-690-1682'),
	('Candida',	'Corbley', '908-275-8357')

INSERT INTO Parts(SerialNumber, [Description], Price, VendorId)
VALUES
	('WP8182119',	'Door Boot Seal',	117.86,	2),
	('W10780048',	'Suspension Rod',	42.81,	1),
	('W10841140',	'Silicone Adhesive', 	6.77,	4),
	('WPY055980',	'High Temperature Adhesive',	13.94,	3)


--3. Update

UPDATE JOBS
SET MechanicId = 3, [Status] = 'In Progress'
WHERE Status = 'Pending'

--4. Delete

DELETE FROM OrderParts
WHERE OrderId = 19

DELETE FROM Orders
WHERE OrderId = 19

--5 Mechanic assignments

SELECT 
	CONCAT(m.FirstName, ' ', m.LastName) AS Mechanic,
	j.[Status],
	j.IssueDate
FROM Mechanics AS m
JOIN Jobs AS j ON
	m.MechanicId = j.MechanicId
ORDER BY m.MechanicId, j.IssueDate, j.JobId

--6 Current clients

SELECT 
	CONCAT(c.FirstName, ' ', c.LastName) AS Client,
	DATEDIFF(DAY, j.IssueDate, '2017-04-24') AS [Days going],
	j.[Status]
FROM Clients AS c
JOIN Jobs AS j ON
	c.ClientId = j.ClientId
WHERE j.[Status] != 'Finished'
ORDER BY [Days going] DESC, c.ClientId ASC

--7. Mechanic performance

SELECT CONCAT(m.FirstName, ' ', m.LastName) AS Mechanic,
	AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS [Days going]
FROM Mechanics AS m
JOIN Jobs AS j ON
	m.MechanicId = j.MechanicId
GROUP BY m.FirstName, m.LastName, m.MechanicId
--ORDER BY m.MechanicId

--8. Available mechanics

SELECT CONCAT(m.FirstName, ' ', m.LastName) AS Available
FROM Mechanics AS m
LEFT JOIN Jobs AS j ON
	m.MechanicId = j.MechanicId
WHERE j.JobId IS NULL 
	OR 'Finished'= ALL
					(SELECT [Status] 
					FROM Jobs AS j
					WHERE j.MechanicId = m.MechanicId)
GROUP BY m.FirstName, m.LastName, m.MechanicId
ORDER BY m.MechanicId

-- 8. Alternative version

SELECT CONCAT(m.FirstName, ' ', m.LastName) AS Available
FROM Mechanics AS m
LEFT JOIN Jobs AS j ON
	m.MechanicId = j.MechanicId
WHERE 'Finished'= ALL
					(SELECT j.[Status] 
					FROM Jobs AS j
					WHERE j.MechanicId = m.MechanicId)
ORDER BY m.MechanicId

---9. Past expenses

SELECT J.JobId, ISNULL(SUM(p.Price * op.Quantity), 0.00) AS Total
FROM JOBS AS j
LEFT JOIN Orders AS o ON
	j.JobId = o.JobId
LEFT JOIN OrderParts AS op ON
	o.OrderId = op.OrderId
LEFT JOIN Parts AS p ON
	op.PartId = p.PartId
WHERE j.[Status] = 'Finished'
GROUP BY j.JobId
ORDER BY Total DESC, j.JobId ASC

--10 Missing parts

SELECT 
	p.PartId,
	p.[Description],
	pn.Quantity AS [Required],
	p.StockQty AS [In Stock],
	IIF(o.Delivered = 0, op.Quantity, 0) AS Ordered
FROM Parts AS p
LEFT JOIN PartsNeeded AS pn ON
	p.PartId = pn.PartId
LEFT JOIN OrderParts AS op ON
	p.PartId = op.PartId
LEFT JOIN Orders AS o ON
	op.OrderId = o.OrderId
LEFT JOIN Jobs AS j ON
	pn.JobId = j.JobId
WHERE j.[Status] NOT LIKE 'Finished'
	AND (IIF(o.Delivered = 0, op.Quantity, 0) + p.StockQty) < pn.Quantity
ORDER BY p.PartId 


--11 Place order



--12. Cost of order

CREATE FUNCTION udf_GetCost (@jobID INT)
RETURNS DECIMAL(15, 2)
AS
BEGIN
	RETURN	
		ISNULL((SELECT SUM(p.Price * op.Quantity) AS Cost
		FROM Jobs AS j
		JOIN Orders AS o ON
			j.JobId = o.JobId
		JOIN OrderParts AS op ON
			o.OrderId = op.OrderId
		JOIN Parts AS p ON
			op.PartId = p.PartId
		GROUP BY j.JobId
		HAVING j.JobId = @jobID), 0)
END

SELECT dbo.udf_GetCost(1)









