--1.Number of Users for Email Provider

SELECT [Email Provider], COUNT(Id) AS [Number Of Users]
FROM	(SELECT Id, SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS [Email Provider]		
		FROM Users) AS t
GROUP BY [Email Provider]
ORDER BY [Number Of Users] DESC, [Email Provider]


--2. All Users in Games

SELECT	g.[Name] AS Game,
		gt.[Name] AS [Game Type],
		u.Username,
		ug.[Level],
		ug.Cash,
		c.[Name] AS [Character]
FROM Games AS g
JOIN GameTypes AS gt ON
	g.GameTypeId = gt.Id
JOIN UsersGames AS ug ON
	g.Id = ug.GameId
JOIN Users AS u ON
	ug.UserId = u.Id
JOIN Characters AS c ON
	ug.CharacterId = c.Id
ORDER BY [Level] DESC, Username, Game


--3.Users in Games with Their Items

SELECT  u.Username,
		g.[Name] AS Game,
		COUNT(i.Id) AS [Items Count],
		SUM(i.Price) AS [Items Price]
FROM Users AS u
JOIN UsersGames AS ug ON
	u.Id = ug.UserId
JOIN Games AS g ON
	ug.GameId = g.Id
JOIN UserGameItems AS ugi ON
	ug.Id = ugi.UserGameId
JOIN Items AS i ON
	ugi.ItemId = i.Id
GROUP BY Username, g.Name
HAVING COUNT(i.Id) >= 10
ORDER BY [Items Count] DESC, [Items Price] DESC, Username


--5.All Items with Greater than Average Statistics

SELECT  i.[Name],
		i.Price,
		i.MinLevel,
		s.Strength,
		s.Defence,
		s.Speed,
		s.Luck,
		s.Mind
FROM ITEMS AS i
JOIN [Statistics] AS s ON
	i.StatisticId = s.Id
WHERE s.Mind > (SELECT AVG(Mind) FROM [Statistics])
	AND s.Speed > (SELECT AVG(Speed) FROM [Statistics])
	AND s.Luck > (SELECT AVG(Luck) FROM [Statistics])
ORDER BY i.[Name]					
		

--6.Display All Items with Information about Forbidden Game Type

SELECT  i.[Name] AS Item,
		i.Price,
		i.MinLevel,
		gt.[Name] AS [Forbidden Game Type]
FROM Items AS i
LEFT JOIN GameTypeForbiddenItems AS gtfi ON
	i.Id = gtfi.ItemId
LEFT JOIN GameTypes AS gt ON
	gtfi.GameTypeId = gt.Id
ORDER BY [Forbidden Game Type] DESC, Item 


--7.Buy Items for User in Game

declare @userId int = (select id from Users where Username = 'Alex');
declare @gameId int = (select Id from Games where [Name] = 'Edinburgh');
declare @userGameId int = (select id from UsersGames where UserId = @userId and GameId = @gameId);

declare @totalCost money = (select sum(Price) from Items where [Name] in 
						('Blackguard', 'Bottomless Potion of Amplification',
						'Eye of Etlich (Diablo III)', 'Gem of Efficacious Toxin',
						'Golden Gorget of Leoric', 'Hellfire Amulet'));

update UsersGames
set Cash -= @totalCost
where Id = @userGameId

declare @item1 int = (select id from Items where [Name] = 'Blackguard');
declare @item2 int = (select id from Items where [Name] = 'Bottomless Potion of Amplification');
declare @item3 int = (select id from Items where [Name] = 'Eye of Etlich (Diablo III)');
declare @item4 int = (select id from Items where [Name] = 'Gem of Efficacious Toxin');
declare @item5 int = (select id from Items where [Name] = 'Golden Gorget of Leoric');
declare @item6 int = (select id from Items where [Name] = 'Hellfire Amulet');



insert into UserGameItems
values (@item1, @userGameId),
	   (@item2, @userGameId),
	   (@item3, @userGameId),
	   (@item4, @userGameId),
	   (@item5, @userGameId),
	   (@item6, @userGameId)



select  u.Username,
		g.[Name],
		ug.Cash,
		i.[Name] as [Item Name]
from Users as u
join UsersGames as ug on
	u.Id = ug.UserId
join Games as g on
	ug.GameId = g.Id
join UserGameItems as ugi on
	ug.Id = ugi.UserGameId
join items as i on
	ugi.ItemId = i.Id
where g.[Name] = 'Edinburgh'
order by [Item Name]


--8. Peaks and mountains

SELECT p.PeakName, m.MountainRange AS Mountain, p.Elevation
FROM Peaks AS p
JOIN Mountains AS m ON
	p.MountainId = m.Id
ORDER BY Elevation DESC, PeakName

--9. Peaks with Mountain, Country and Continent


SELECT  p.PeakName,
		m.MountainRange AS Mountain, 
		c.CountryName,
		cn.ContinentName
FROM Peaks AS p
JOIN Mountains AS m ON
	p.MountainId = m.Id
JOIN MountainsCountries AS mc ON
	m.Id = mc.MountainId
JOIN Countries AS c ON
	mc.CountryCode = c.CountryCode
JOIN Continents AS cn ON
	c.ContinentCode = cn.ContinentCode
ORDER BY PeakName, CountryName

--10. Rivers by country

SELECT  c.CountryName,
		cn.ContinentName,
		COUNT(r.Id) AS RiversCount,
		ISNULL(SUM(r.[Length]), 0) AS TotalLength
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr ON
	c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON
	cr.RiverId = r.Id
LEFT JOIN Continents AS cn ON
	c.ContinentCode = cn.ContinentCode
GROUP BY c.CountryName, cn.ContinentName
ORDER BY RiversCount DESC, TotalLength DESC, CountryName

--11. Count of Countries by Currency

SELECT  cu.CurrencyCode,
		cu.[Description] AS Currency,
		COUNT(c.CountryCode) AS NumberOfCountries
FROM Currencies AS cu
LEFT JOIN Countries AS c ON
	cu.CurrencyCode = c.CurrencyCode
GROUP BY cu.CurrencyCode, cu.[Description]
ORDER BY NumberOfCountries DESC, Currency

--12. Population and Area by Continent

SELECT  cn.ContinentName,
		SUM(c.AreaInSqKm) AS CountriesArea,
		SUM(CAST(c.[Population] AS BIGINT)) AS CountriesPopulation
FROM Continents AS cn
JOIN Countries AS c ON
	cn.ContinentCode = c.ContinentCode
GROUP BY cn.ContinentName
ORDER BY CountriesPopulation DESC

--13. Problem 13.Monasteries by Country

--13.1

CREATE TABLE Monasteries
		(Id INT PRIMARY KEY IDENTITY NOT NULL, 
		[Name] NVARCHAR(MAX) NOT NULL,
		CountryCode CHAR(2) REFERENCES Countries(CountryCode) NOT NULL)

--13.2

INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR')

--13.3

ALTER TABLE Countries
ADD IsDeleted BIT DEFAULT 0 NOT NULL

--13.4

UPDATE Countries
SET IsDeleted = 1
WHERE CountryCode IN 
	(SELECT CountryCode FROM
		(SELECT c.CountryCode, COUNT(cr.RiverId) AS RiverCount
		FROM Countries AS c
		JOIN CountriesRivers AS cr ON
			c.CountryCode = cr.CountryCode
		GROUP BY c.CountryCode
		HAVING COUNT(cr.RiverId) > 3) AS t1)

--13.5

SELECT m.[Name] AS Monastery, c.CountryName AS Country
FROM Monasteries AS m
JOIN Countries AS c ON
	m.CountryCode = c.CountryCode
WHERE c.IsDeleted = 0
ORDER BY Monastery

--14. Monasteries by Continents and Countries

--14.1

UPDATE Countries
SET CountryName = 'Burma'
WHERE CountryName = 'Myanmar'

--14.2

DECLARE @countryCode1 char(2) = (SELECT CountryCode FROM Countries WHERE CountryName = 'Tanzania');

INSERT INTO Monasteries
VALUES ('Hanga Abbey', @countryCode1)


--14.3

DECLARE @countryCode2 char(2) = (SELECT CountryCode FROM Countries WHERE CountryName = 'Myanmar');

INSERT INTO Monasteries
VALUES ('Myin-Tin-Daik', @countryCode2)   --THROWS ERROR -> THERE IS NO SUCH COUNTRY


--14.4

SELECT  cn.ContinentName,
		c.CountryName,
		ISNULL(COUNT(m.Id), 0) AS MonasteriesCount  --ISNULL ONLY BECAUSE OF JUDGE :)
FROM Continents AS cn
JOIN Countries AS c ON
	cn.ContinentCode = c.ContinentCode
LEFT JOIN Monasteries AS m ON
	c.CountryCode = m.CountryCode
WHERE c.IsDeleted = 0
GROUP BY cn.ContinentName, c.CountryName
ORDER BY MonasteriesCount DESC, CountryName