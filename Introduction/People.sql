CREATE DATABASE People

USE People

CREATE TABLE People(
	Id INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(2),
	[Height] DECIMAL(18,2),
	[Weight] DECIMAl(18,2),
	Gender CHAR(1) NOT NULL,
	Birthdate DATE NOT NULL,
	Biography NVARCHAR(MAX)
)

SELECT * FROM People

INSERT INTO People
	VALUES
		(1,'Kalo', NULL, 182, 83, 'm', '1988-jul-07', 'Born and raised'),
		(2,'Bobi', NULL, 187, 78, 'm', '1988-mar-06', 'Born and raised'),
		(3,'Mimi', NULL, NULL, NULL, 'f', '1988-jun-10', 'Born and raised'),
		(4,'Dido', NULL, 180, 86, 'm', '1988-aug-05', 'Born and raised'),
		(5,'Joji', NULL, 160, 45, 'f', '1988-sep-12', 'Born and raised')

