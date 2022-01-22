USE Movies

CREATE TABLE Directors(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	DirectorName NVARCHAR(30) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Directors
	VALUES
		('Federico Fellini', 'from Italy'),
		('Pedro Almodovar', NULL),
		('Tarkovsky', 'Russian'),
		('Konchalovsky', 'Russian'),
		('Godard', NULL)

---------


CREATE TABLE Genres(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	GenreName NVARCHAR(30) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Genres
	VALUES
		('Action', NULL),
		('Drama', 'could be interesting'),
		('Comedy', 'Highly recommended'),
		('Horror', NULL),
		('Porn', NULL)

--------


CREATE TABLE Categories(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	CategoryName NVARCHAR(30) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Categories
	VALUES
		('B-Rated', NULL),
		('European', 'could be interesting'),
		('Asian', 'incomprehensible'),
		('Experimental', NULL),
		('Various', NULL)

-------


CREATE TABLE Movies(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	Title NVARCHAR(MAX) NOT NULL,
	DirectorId BIGINT NOT NULL,
	CopyrightYear DATE,
	[Length] DECIMAL(5,2),
	GenreId BIGINT NOT NULL,
	CategoryId BIGINT NOT NULL,
	Rating DECIMAL(2,1),
	Notes NVARCHAR(MAX)
)

INSERT INTO Movies
	VALUES
		('Amarcord', 1, '1973', 2.7, 2, 2, NULL, NULL),
		('Breathless', 5, '1960', 1.27, 2, 2, 4.5, NULL),
		('Nostalghia', 3, '1983', 2.05, 2, 2, NULL, 'bored me to death'),
		('Dolce vita', 1, '1973', 2.7, 2, 2, NULL, 'too long'),
		('Contempt', 5, '1973', 2.7, 2, 2, NULL, NULL)
		
SELECT * FROM Movies
