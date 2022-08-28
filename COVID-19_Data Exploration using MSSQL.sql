

--Get the Covid_death table
SELECT * FROM PortfolioProject.dbo.[COVID_Death$]


--Check total cases vs total deaths 
SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject.[dbo].[COVID_Death$]
order by 1,2

--Get the percentage number of people affected in Germany
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage 
FROM PortfolioProject.[dbo].[COVID_Death$]
WHERE location like '%Germ%'
ORDER BY 1,2

--Get the percetage of population infected 
SELECT location, date, population, total_cases,  (total_cases/population) * 100 AS population_cases_percentage 
FROM PortfolioProject.[dbo].[COVID_Death$]
 ORDER BY 1,2 ASC

--Looking at countries wth highest infection rate compared to population 
SELECT location, population, MAX (total_cases) AS cases,  MAX((total_cases/population)) * 100 AS population_cases_percentage 
FROM PortfolioProject.[dbo].[COVID_Death$]
GROUP BY location, population
ORDER BY population_cases_percentage DESC

--Showing countries with highest death count per population
SELECT location, MAX (total_deaths) AS death_count
FROM PortfolioProject.[dbo].[COVID_Death$]
GROUP BY location
ORDER BY death_count DESC

--Formatting the total_death datatype using cast function
SELECT location, MAX (CAST (total_deaths AS INT)) AS death_count
FROM PortfolioProject.[dbo].[COVID_Death$]
GROUP BY location
ORDER BY death_count DESC


--Group data showing the contitnent where value is null
SELECT location, MAX (CAST (total_deaths AS INT)) AS death_count
FROM PortfolioProject.[dbo].[COVID_Death$]
WHERE continent is null
GROUP BY location
ORDER BY death_count DESC



--Get the sum of new cases and deaths and percentage
SELECT location,date, SUM (new_cases) AS total_newcases, SUM (CAST(new_deaths AS INT)) AS total_newdeaths, 
SUM(CAST(new_deaths AS INT))/ SUM (new_cases) * 100 AS new_percentage 
FROM PortfolioProject.[dbo].[COVID_Death$]
WHERE continent is null
GROUP BY date 
ORDER BY new_percentage DESC


--Get the Covid_vaccination table
SELECT * FROM PortfolioProject.[dbo].[COVID_Vaccination$]


--Join the two Tables 
SELECT * FROM PortfolioProject.[dbo].[COVID_Death$] AS death
Join PortfolioProject.[dbo].[COVID_Vaccination$] AS vaccination
	ON death.location = death.location
	AND death.date = death.date



--Get the total number of people vaccinated 
SELECT death.continent,death.location,death.date,death.population, vaccination.new_vaccinations 
FROM PortfolioProject.[dbo].[COVID_Death$] AS death
Join PortfolioProject.[dbo].[COVID_Vaccination$] AS vaccination
	ON death.location = death.location
	AND death.date = death.date
WHERE vaccination.continent is not null
ORDER BY 1,2,3


--Looking at countries wIth highest vaccination rate compared to population 
SELECT DISTINCT (vaccination.location), MAX (vaccination.total_vaccinations) AS people_vaccinated,  
MAX((vaccination.total_vaccinations/death.population)) * 100 AS population_cases_percentage 
FROM PortfolioProject.[dbo].[COVID_Death$] AS death
Join PortfolioProject.[dbo].[COVID_Vaccination$] AS vaccination
	ON death.location = death.location
	AND death.date = death.date
GROUP BY vaccination.location, death.population
ORDER BY population_cases_percentage DESC


--Rolling count of People vaccinated
SELECT death.continent,death.location,death.date,death.population, vaccination.new_vaccinations, 
SUM(CONVERT(INT, vaccination.new_vaccinations)) 
OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS rolling_people_vaccinated
FROM PortfolioProject.[dbo].[COVID_Death$] AS death
Join PortfolioProject.[dbo].[COVID_Vaccination$] AS vaccination
	ON death.location = death.location
	AND death.date = death.date
WHERE vaccination.continent is not null
ORDER BY 1,2,3


--Get the percentage of of rolling people vaccinated using CTE
WITH population_vaccination (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS
(SELECT death.continent,death.location,death.date,death.population, vaccination.new_vaccinations, 
SUM(CONVERT(INT, vaccination.new_vaccinations)) 
OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS rolling_people_vaccinated
FROM PortfolioProject.[dbo].[COVID_Death$] AS death
Join PortfolioProject.[dbo].[COVID_Vaccination$] AS vaccination
	ON death.location = death.location
	AND death.date = death.date
WHERE vaccination.continent is not null)
--ORDER BY 1,2,3)
SELECT * , (rolling_people_vaccinated/ population) * 100 FROM population_vaccination



-- Creating Temporary table

CREATE TABLE #percent_population_vaccination 
(continent nvarchar (255), location nvarchar (255), date DATETIME, population NUMERIC,
new_vaccinations NUMERIC, rolling_people_vaccinated NUMERIC)

INSERT INTO #percent_population_vaccination
SELECT death.continent,death.location,death.date,death.population, vaccination.new_vaccinations,
SUM(CONVERT(bigint, vaccination.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS rolling_people_vaccinated
FROM PortfolioProject.[dbo].[COVID_Death$] AS death
Join PortfolioProject.[dbo].[COVID_Vaccination$] AS vaccination
	ON death.location = death.location
	AND death.date = death.date
WHERE vaccination.continent is NOT null
--ORDER BY 1,2,3)
SELECT * , (rolling_people_vaccinated/ population) * 100 FROM #percent_population_vaccination


--------------------------------------------------------------------------------------------------------------------
--Create view to store data for visualization

CREATE VIEW covidcases AS 
	SELECT death.continent,death.location,death.date,death.population, vaccination.new_vaccinations, 
		SUM(CONVERT(bigint, vaccination.new_vaccinations)) 
		OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS rolling_people_vaccinated
	FROM PortfolioProject.[dbo].[COVID_Death$] AS death
		Join PortfolioProject.[dbo].[COVID_Vaccination$] AS vaccination
		ON death.location = death.location
		AND death.date = death.date
	WHERE vaccination.continent is not null


SELECT * FROM covidcases



