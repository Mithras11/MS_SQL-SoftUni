CREATE DATABASE School
GO 

USE School 
GO

------

CREATE TABLE Students
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName VARCHAR(30) NOT NULL,
	MiddleName VARCHAR(25) NULL,
	LastName VARCHAR(30) NOT NULL,
	Age INT CHECK(Age BETWEEN 5 AND 100), --???
	[Address] VARCHAR(50),
	Phone CHAR(10))

CREATE TABLE Subjects
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(20) NOT NULL,
	Lessons INT CHECK(Lessons > 0) NOT NULL)

CREATE TABLE StudentsSubjects
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	StudentId INT REFERENCES Students(Id) NOT NULL,
	SubjectId INT REFERENCES Subjects(Id) NOT NULL,
	Grade DECIMAL(18, 2) CHECK(Grade BETWEEN 2 AND 6) NOT NULL)

CREATE TABLE Exams
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Date] DateTime,
	SubjectId INT REFERENCES Subjects(Id) NOT NULL)

CREATE TABLE StudentsExams
	(StudentId INT REFERENCES Students(Id) NOT NULL,
	ExamId INT REFERENCES Exams(Id) NOT NULL,
	Grade DECIMAL(18, 2) CHECK(Grade BETWEEN 2 AND 6) NOT NULL,
	CONSTRAINT PK_StudentsExams PRIMARY KEY(StudentId, ExamId))

CREATE TABLE Teachers
	(Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	[Address] VARCHAR(20) NOT NULL,
	Phone CHAR(10),
	SubjectId INT REFERENCES Subjects(Id) NOT NULL)

CREATE TABLE StudentsTeachers
	(StudentId INT REFERENCES Students(Id) NOT NULL,
	TeacherId INT REFERENCES Teachers(Id) NOT NULL,
	CONSTRAINT PK_StudentsTeachers PRIMARY KEY(StudentId, TeacherId))

GO

--2. INSERT

INSERT INTO Teachers (FirstName, LastName, [Address], Phone, SubjectId)
VALUES
	('Ruthanne', 'Bamb', '84948 Mesta Junction', '3105500146', 6),
	('Gerrard', 'Lowin', '370 Talisman Plaza', '3324874824', 2),
	('Merrile',	'Lambdin', '81 Dahle Plaza', '4373065154', 5),
	('Bert', 'Ivie', '2 Gateway Circle', '4409584510', 4)

INSERT INTO Subjects
VALUES
	('Geometry', 12),
	('Health', 10),
	('Drama', 7),
	('Sports', 9)

--3 UPDATE

UPDATE StudentsSubjects
SET Grade = 6.00
WHERE SubjectId IN (1, 2) AND
	Grade >= 5.50

SELECT SUM(Grade) FROM StudentsSubjects
WHERE SubjectId = 1 OR SubjectId = 2

--4 DELETE

DELETE FROM StudentsTeachers 
WHERE TeacherId IN (SELECT t.Id
				FROM StudentsTeachers AS st
				JOIN Teachers AS t ON
					st.TeacherId = t.Id
				WHERE t.Phone LIKE '%72%')

DELETE FROM Teachers
WHERE Phone LIKE '%72%'

--5 Teen Students

SELECT FirstName, LastName, Age
FROM Students
WHERE Age >= 12
ORDER BY FirstName, LastName

--6.Students Teachers

SELECT s.FirstName, s.LastName, COUNT(st.TeacherId) AS TeachersCount 
FROM Students AS s
JOIN StudentsTeachers AS st ON
	s.Id = st.StudentId
GROUP BY s.FirstName, s.LastName

--7 Students to go

SELECT CONCAT(s.FirstName, ' ', s.LastName) AS [Full Name] 
FROM StudentsExams AS se
RIGHT JOIN Students AS s ON
	se.StudentId = s.Id
WHERE se.StudentId IS NULL
ORDER BY [Full Name]

--8 Top students

SELECT TOP(10) s.FirstName, s.LastName, CAST(AVG(se.Grade) AS decimal(3, 2)) AS Grade
FROM Students AS s
JOIN StudentsExams AS se ON
	s.Id = se.StudentId
GROUP BY s.FirstName, s.LastName
ORDER BY Grade DESC, s.FirstName, s.LastName

--9 Not so in the studying

SELECT FirstName + ' ' + IIF(MiddleName is not null, MiddleName + ' ', '') + LastName as FullName
FROM	
	(SELECT s.FirstName, s.MiddleName, s.LastName
	FROM Students AS s
	LEFT JOIN StudentsSubjects AS ss ON
		s.Id = ss.StudentId
	WHERE ss.Id IS NULL) AS t
order by FullName

--10. Average Grade per Subject

SELECT s.[Name], AVG(ss.Grade) AS AverageGrade
FROM Subjects AS s
JOIN StudentsSubjects AS ss ON
	s.Id = ss.SubjectId
GROUP BY s.[Name], s.Id
ORDER BY s.Id



--11. Exam Grades

CREATE OR ALTER FUNCTION udf_ExamGradesToUpdate (@studentId INT, @grade FLOAT)
RETURNS VARCHAR(MAX)
AS
BEGIN
		
		IF (@grade > 6.00)
		BEGIN
			RETURN 'Grade cannot be above 6.00!'
		END

		
		DECLARE @firstName VARCHAR(30) = (SELECT FirstName
					FROM Students  
					WHERE Id = @studentId);

		DECLARE @result VARCHAR(MAX);


		IF (@firstName IS NULL)
		BEGIN
			RETURN 'The student with provided id does not exist in the school!'
		END


		DECLARE @count INT = (SELECT COUNT(ss.Grade) 
					FROM Students  AS s
					JOIN StudentsSubjects AS ss ON
						s.iD = ss.StudentId
					WHERE s.Id = @studentId 
						AND ss.Grade > @grade AND  SS.Grade <= (@grade + 0.50));

		

		RETURN 'You have to update ' + CAST(@count AS VARCHAR(5)) +
				' grades for the student ' + @firstName

END

SELECT dbo.udf_ExamGradesToUpdate(12, 6.20)
SELECT dbo.udf_ExamGradesToUpdate(121, 5.50)
SELECT dbo.udf_ExamGradesToUpdate(12, 5.50)







--12. Exclude From School

CREATE OR ALTER PROC usp_ExcludeFromSchool(@StudentId INT)
AS
	IF (SELECT Id
		FROM Students
		WHERE Id = @StudentId) IS NULL

		THROW 50001, 'This school has no student with the provided id!', 1

	ELSE

		DELETE FROM StudentsExams
		WHERE StudentId = @StudentId	
		
		DELETE FROM StudentsTeachers
		WHERE StudentId = @StudentId
		
		DELETE FROM StudentsSubjects
		WHERE StudentId = @StudentId	

		DELETE FROM Students
		WHERE Id = @StudentId

GO