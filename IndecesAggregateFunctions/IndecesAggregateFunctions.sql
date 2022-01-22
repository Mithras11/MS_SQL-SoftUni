SELECT COUNT(*) AS Count
FROM WizzardDeposits

-----

SELECT DepositGroup, MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits
GROUP BY DepositGroup

-----

SELECT TOP(2) DepositGroup 
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY (AVG(MagicWandSize)) ASC

-----
	
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
GROUP BY DepositGroup

----

SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator='Ollivander family'
GROUP BY DepositGroup

-----

SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC

------

SELECT DepositGroup,MagicWandCreator, MIN(DepositCharge) AS MinDepositCharge
FROM WizzardDeposits
GROUP BY DepositGroup,MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup 

------

SELECT AgeGroup, COUNT(*) AS WizzardCount
FROM (SELECT Age,
		CASE 
			WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
			WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
			WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
			WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
			WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
			WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
			ELSE '[61+]'
		END AS AgeGroup
	FROM WizzardDeposits) AS tmp
GROUP BY AgeGroup

-------

SELECT	LEFT(FirstName,1)
FROM WizzardDeposits
WHERE DepositGroup='Troll chest'
GROUP BY LEFT(FirstName,1)

------

SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest)
FROM WizzardDeposits
WHERE DepositStartDate > '01/01/1985'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired ASC

------
SELECT SUM([Difference])
FROM
	(SELECT
		FirstName AS Host, 
		DepositAmount AS HostDeposit,
		LEAD(FirstName) OVER (ORDER BY Id) AS Guest, 
		LEAD(DepositAmount) OVER (ORDER BY Id) AS GuestDeposit,
		(DepositAmount-LEAD(DepositAmount) OVER (ORDER BY Id)) AS Difference
	FROM WizzardDeposits) AS TMP

------

USE SoftUni

SELECT DepartmentID, SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY DepartmentID
	
------


SELECT DepartmentID, MIN(SALARY) AS MinimumSalary
FROM Employees
WHERE DepartmentID IN (2, 5, 7) AND
	HireDate > '01-01-2000'
GROUP BY DepartmentID

-------

SELECT DepartmentID, Salary, ManagerID
INTO NewTable
FROM Employees
WHERE SALARY > 30000

DELETE FROM NewTable
WHERE ManagerID = 42

UPDATE  NewTable
SET SALARY += 5000
WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary)
FROM NewTable
GROUP BY DepartmentID

-------

SELECT DepartmentID, MAX(Salary) AS MaxSalary
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

-----

SELECT COUNT(*) AS [Count]
FROM Employees
WHERE ManagerID IS NULL

-------
SELECT DISTINCT DepartmentID, Salary AS ThirdHighestSalary
FROM
	(SELECT 
		DepartmentID,
		Salary,
		DENSE_RANK() OVER (PARTITION BY DepartmentID
			ORDER BY Salary DESC) AS SalaryRank
	FROM Employees) AS TMP
WHERE SalaryRank=3

-------
SELECT TOP(10)
	e.FirstName,
	e.LastName,
	--e.Salary, 
	e.DepartmentID
	--t.AvgSalary
FROM Employees AS e
JOIN 
	(SELECT DepartmentID, AVG(Salary) AS AvgSalary
	FROM Employees
	GROUP BY DepartmentID) AS t ON e.DepartmentID = t.DepartmentID
WHERE Salary > AvgSalary
ORDER BY e.DepartmentID
