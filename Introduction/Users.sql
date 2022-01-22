USE People

--CREATE TABLE Users(
--	Id BIGINT PRIMARY KEY NOT NULL,
--	Username NVARCHAR(30) NOT NULL,
--	[Password] NVARCHAR(26) NOT NULL,
--	ProfilePicture VARBINARY(900),
--	LastLoginTime DATETIME2,
--	IsDeleted BIT
--)

--INSERT INTO Users
--	VALUES
--		(1, 'Kalo', 'PHIPHO', NULL, '2021-aug-19 2:21PM', 1),
--		(2, 'Bobi', 'FLAFLA', NULL, '2021-aug-19 2:12PM', 0),
--		(3, 'Dido', 'POOOOOOP', NULL, '2021-aug-19 2:56PM', 1),
--		(4, 'Mimi', 'BLOOOB', NULL, '2021-aug-19 12:00AM', 1),
--		(5, 'Joji', '12321', NULL, '2021-aug-19 4:03AM', 1)


CREATE TABLE Users(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	Username VARCHAR(30) NOT NULL,
	[Password] VARCHAR(26) NOT NULL,
	ProfilePicture VARBINARY(MAX)
	CHECK(DATALENGTH(ProfilePicture) <= 900 * 1024),
	LastLoginTime DATETIME2 NOT NULL,
	IsDeleted BIT NOT NULL
)

INSERT INTO Users(Username, [Password], LastLoginTime, IsDeleted)
	VALUES
		('Kalo', 'PHIPHO', '08-13-2021 2:21PM', 1),
		('Bobi', 'FLAFLA', '08-09-2021 2:12PM', 0),
		('Dido', 'POOOOOOP', '08-04-2021 2:56PM', 1),
		('Mimi', 'BLOOOB', '08-21-2021 12:00AM', 1),
		('Joji', '12321', '08-19-2021 4:03AM', 1)

SELECT * FROM Users

ALTER TABLE Users
DROP CONSTRAINT [PK__Users__3214EC07DD2A6406]

ALTER TABLE Users
ADD CONSTRAINT PK__Users__CompositeIdUsername
	PRIMARY KEY(Id, Username)


ALTER TABLE Users
ADD CONSTRAINT CK_Users_PasswordLength
	CHECK(LEN([Password]) >= 5)

INSERT INTO Users(Username, [Password], LastLoginTime, IsDeleted)
	VALUES
		('Misho11', '123', '08-25-2021 4:43PM', 1)  --throws error
		
		
INSERT INTO Users(Username, [Password], LastLoginTime, IsDeleted)
	VALUES
		('Misho11', '123456', '08-25-2021 4:43PM', 1)

ALTER TABLE Users
	ADD CONSTRAINT DF_Users_LastLoginTime
	DEFAULT GETDATE() FOR LastLoginTime

INSERT INTO Users(Username, [Password], IsDeleted)
	VALUES
		('MishoNoTime', '123456', 1)

ALTER TABLE Users
	DROP CONSTRAINT PK__Users__CompositeIdUsername

ALTER TABLE Users
	ADD CONSTRAINT PK_Users_Id
	PRIMARY KEY(Id)

ALTER TABLE Users
	ADD CONSTRAINT CK_Users_UsernameLength
	CHECK(LEN([Username]) >= 3)


INSERT INTO Users(Username, [Password], IsDeleted)
	VALUES
		('Li', '5555555', 1) --THROWS ERROR

	
INSERT INTO Users(Username, [Password], IsDeleted)
	VALUES
		('Lili', '123456', 1)

