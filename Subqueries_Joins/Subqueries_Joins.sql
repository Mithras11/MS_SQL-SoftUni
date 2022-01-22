USE SoftUni

SELECT TOP(5) e.EmployeeID AS EmployeeId,
		e.JobTitle,
		e.AddressID AS AddressId,
		a.AddressText 
FROM Employees AS e
JOIN Addresses AS a ON 
	e.AddressID=a.AddressID
ORDER BY AddressId

------

SELECT TOP(50)
	e.FirstName,
	e.LastName, 
	t.Name AS Town,
	a.AddressText		
FROM Employees AS e
JOIN Addresses AS a ON
	e.AddressID=a.AddressID
JOIN Towns AS t ON
	t.TownID=a.TownID
ORDER BY FirstName, LastName

------

SELECT 
	e.EmployeeID,
	e.FirstName,
	e.LastName,
	d.Name AS DepartmentName
FROM Employees AS e
JOIN Departments AS d ON
	e.DepartmentID=d.DepartmentID
WHERE d.Name='Sales'
ORDER BY EmployeeID 
	
-----

SELECT TOP(5)
	e.EmployeeID,
	e.FirstName,
	e.Salary,
	d.Name AS DepartmentName
FROM Employees AS e
JOIN Departments AS d ON
	e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY e.DepartmentID 

-----

SELECT TOP(3) 
	e.EmployeeID,
	e.FirstName
FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep ON
	e.EmployeeID = ep.EmployeeID
WHERE ep.ProjectID IS NULL

------

SELECT 
	e.FirstName,
	e.LastName,
	e.HireDate,
	d.Name AS DeptName
FROM Employees AS e
JOIN Departments AS d ON
	e.DepartmentID = d.DepartmentID
WHERE HireDate > '1999-01-01' AND
	d.Name IN ('Sales', 'Finance')
ORDER BY HireDate

------

SELECT TOP(5)
	e.EmployeeID,
	e.FirstName,
	p.Name AS ProjectName
FROM Employees AS e
JOIN EmployeesProjects AS ep ON
	e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON
	ep.ProjectID = p.ProjectID
WHERE p.StartDate > '2002-08-13' AND
	p.EndDate IS NULL
ORDER BY EmployeeID

-------

SELECT 
	e.EmployeeID,
	e.FirstName,
	CASE 
	WHEN p.StartDate >= '2005-01-01' THEN NULL
	ELSE p.Name
	END AS ProjectName
FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep ON
	e.EmployeeID = ep.EmployeeID
LEFT JOIN Projects AS p ON
	ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24 

-------
SELECT 
	e.EmployeeID,
	e.FirstName,
	e.ManagerID,
	m.FirstName AS ManagerName
FROM Employees AS e
LEFT JOIN Employees AS m ON
	e.ManagerID = m.EmployeeID
WHERE e.ManagerID IN (3,7)
ORDER BY e.EmployeeID

-------
SELECT TOP(50)
	e.EmployeeID,
	CONCAT(e.FirstName,' ', e.LastName) AS EmployeeName,
	CONCAT(m.FirstName,' ', m.LastName) AS ManagerName,
	d.Name
FROM Employees AS e
LEFT JOIN Employees AS m ON
	e.ManagerID = m.EmployeeID
JOIN Departments AS d ON
	e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID

--------
SELECT MIN(Salary)
FROM (SELECT  
		AVG(e.Salary) AS Salary,
		d.Name AS DeptName
	FROM Employees AS e
	JOIN Departments AS d ON
		e.DepartmentID = d.DepartmentID
	GROUP BY d.Name) AS TMP

-----

USE Geography

SELECT 
	mc.CountryCode,
	m.MountainRange,
	p.PeakName,
	p.Elevation
FROM MountainsCountries AS mc
JOIN Mountains AS m ON
	mc.MountainId = m.Id
JOIN Peaks AS p ON
	m.Id = p.MountainId
WHERE mc.CountryCode = 'BG' AND
	p.Elevation > 2835
ORDER BY p.Elevation DESC

--------

SELECT 
	mc.CountryCode,
	COUNT(m.MountainRange) AS MountainRanges
FROM MountainsCountries AS mc
JOIN Mountains AS m ON
	mc.MountainId = m.Id
WHERE mc.CountryCode IN ('US', 'RU', 'BG')
GROUP BY (mc.CountryCode)

-------

SELECT TOP(5)
	c.CountryName,
	r.RiverName
FROM Rivers AS r
JOIN CountriesRivers AS cr ON
	r.Id = cr.RiverId
RIGHT JOIN Countries AS c ON
	cr.CountryCode = c.CountryCode
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName

-------

SELECT 
	ContinentCode,
	CurrencyCode,
	CurrencyCount AS CurrencyUsage
FROM
		(SELECT 
			ContinentCode,
			CurrencyCode,
			CurrencyCount,
			DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY CurrencyCount DESC)  AS CurrencyRank
		FROM
			(SELECT
				ContinentCode,
				CurrencyCode, 
				COUNT(CurrencyCode) AS CurrencyCount
				FROM Countries 
			GROUP BY ContinentCode, CurrencyCode) AS CountQuery
		WHERE CurrencyCount > 1) AS RankQuery
WHERE CurrencyRank = 1
ORDER BY ContinentCode

-------

SELECT COUNT(c.CountryName) AS [Count]
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON
	c.CountryCode = mc.CountryCode
WHERE mc.MountainId IS NULL

---------

	
SELECT TOP(5)
	CountryName,
	Elevation AS HighestPeakElevation,
	[Length] AS LongestRiverLength
FROM
	(SELECT
			CountryName,
			DENSE_RANK() OVER (PARTITION BY CountryName ORDER BY Elevation DESC) AS [Peak Rank],
			Elevation,
			PeakName,
			DENSE_RANK() OVER (PARTITION BY CountryName ORDER BY Length DESC) AS [River Rank],
			RiverName,
			[Length]
	FROM
			(SELECT c.CountryName,
				   p.PeakName,
				   p.Elevation,
				   r.RiverName,
				   r.[Length]
			FROM Countries AS c
			LEFT JOIN MountainsCountries AS mc ON
				c.CountryCode = mc.CountryCode
			LEFT JOIN Mountains AS m ON
				mc.MountainId = m.Id
			LEFT JOIN Peaks AS p ON
				mc.MountainId = p.MountainId
			LEFT JOIN CountriesRivers AS cr ON
				c.CountryCode =  cr.CountryCode	
			LEFT JOIN Rivers AS r ON
				cr.RiverId = r.Id)
	AS BasicQuery)
AS RankQuery

WHERE [Peak Rank] = 1 AND
      [River Rank] = 1

ORDER BY HighestPeakElevation DESC,
	     LongestRiverLength DESC,
		 CountryName


--------


SELECT TOP(5)
	  Country,
	  ISNULL(PeakName, '(no highest peak)') AS [Highest Peak Name],
	  ISNULL(Elevation, 0) AS [Highest Peak Elevation],
	  ISNULL(MountainRange, '(no mountain)') AS Mountain	       	   
FROM
	(SELECT Country,
		   PeakName,
		   Elevation,
		   DENSE_RANK() OVER (PARTITION BY Country ORDER BY Elevation DESC) AS Highest_Rank,
		   MountainRange
	FROM
		(SELECT c.CountryName AS Country,
			   p.PeakName,
			   p.Elevation,
			   m.MountainRange
		FROM Countries AS c
		LEFT JOIN MountainsCountries AS mc ON
			c.CountryCode = mc.CountryCode
		LEFT JOIN Mountains AS m ON
			mc.MountainId = m.Id
		LEFT JOIN Peaks AS p ON
			mc.MountainId = p.MountainId) AS PeaksQuery)
AS HighestQuery
WHERE Highest_Rank = 1 
ORDER BY Country, [Highest Peak Name]



 