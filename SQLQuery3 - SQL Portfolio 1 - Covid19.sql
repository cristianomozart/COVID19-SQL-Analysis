

			  -- 1 ORGANISING THE DATA ON COVID19 CASES AND DEATHS --
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioCovid..[Covid19-Deaths-Table]
ORDER BY 1, 2 --ORDER BY THE FIRST COLUMN AND SECOND COLUMN, WHICH ARE LOCATION AND DATE

             -- 2 TOTAL CASES VS DEATHS --

/* What is the likelihood of dying from contracting COvid19?
How many cases are there in these countries and how many deaths do they have for their entire cases?
                      ERROR IN THE QUERY
Trying to run the below query an error message was showed indicating that one or both of the columns 
total_cases and total_deaths are stored as nvarchar (string) data types. 
So we need to convert or cast these columns to a numeric data type. 
GOING FORWARD WE NEED TO PAY ATTENTION TO THE DATA TYPE.
*/
SELECT Location, 
       date, total_cases, total_deaths, 
       (CONVERT(float, total_deaths)/CAST(total_cases AS FLOAT))*100 as DeathPercentage
FROM PortfolioCovid..[Covid19-Deaths-Table]
ORDER BY 1, 2;

			   -- 3 NOW THE LIKELYHOOD OF DYING FILTERED BY THE COUNTRY --
SELECT Location, 
      date, total_cases, total_deaths, 
     (CONVERT(float, total_deaths)/CAST(total_cases AS FLOAT))*100 as DeathPercentage
FROM PortfolioCovid..[Covid19-Deaths-Table]
WHERE location like '%brazil%'
ORDER BY 1, 2 ;

			    -- 4 CASES VS POPULATION
/* 
Shows what percentage of the population has got Covid. Specific per Country
*/
SELECT Location, date, population , total_cases, (CAST(total_cases AS FLOAT)/population)*100 as PercentagePopInfected
FROM PortfolioCovid..[Covid19-Deaths-Table]
WHERE location like '%brazil%'
ORDER BY 1, 2

			   --- 5 HIGHEST INFECTION RATE AGAINST POPULATION
SELECT Location, population , 
MAX(total_cases) AS HighestinfectionCount, 
Max((CAST(total_cases AS FLOAT)/population))*100 as PercentagePopInfected
	FROM PortfolioCovid..[Covid19-Deaths-Table]
	GROUP BY location, population
	ORDER BY PercentagePopInfected DESC

		   --- 6 COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION 
	
 SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathsCount
 FROM PortfolioCovid..[Covid19-Deaths-Table]
 GROUP BY location
 ORDER BY TotalDeathsCount
/*
In the Location column there are a few data that actually is not correct such as:
'World', Afric, Asia, South America, grouping the entiry continent
So, we need to explore the data to fix this.
*/
SELECT *
FROM PortfolioCovid..[Covid19-Deaths-Table]
WHERE Continent IS NOT NULL --- we can add this clause to fix the location issue
ORDER BY 3, 4
GO

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathsCount
 FROM PortfolioCovid..[Covid19-Deaths-Table]
 WHERE Continent IS NOT NULL
 GROUP BY location
 ORDER BY TotalDeathsCount Desc

					--- 7 BREAKING IT DOWN BY CONTINENT

 /*IF WE WANT TO BREAK IT DOWN BY CONTINENT
 SHOWING THE CONTINENTS WTH THE HIGHEST DEATH COUNT PER POPULATION
*/
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
 FROM PortfolioCovid..[Covid19-Deaths-Table]
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC --THE RESULT DO NOT SEEMS CORRECT 
								-- WHICH WILL BE AN ISSUE FOR THE DRIWL DOWN EFFECT ON THE VISUALISATION

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioCovid..[Covid19-Deaths-Table]
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC -- THIS SEEMS TO BE THE CORRECT VALUES

		    -- 8 BREAKING THE NUMBERS GLOBALY

SELECT date,
SUM(new_cases) as total_cases,
SUM(CAST(new_deaths as int)) as total_deaths,
		CASE WHEN SUM(new_cases) = 0 THEN 0 
		ELSE SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 END as DeathPercentage --THER ARE '0' VALUES
FROM PortfolioCovid..[Covid19-Deaths-Table]
GROUP BY date
ORDER BY 1, 2;


SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioCovid..[Covid19-Deaths-Table]
WHERE continent IS NOT NULL
ORDER BY 1, 2

				----- NOW LET'S WORK WITH THE TABLE VACCINATIONS -------
		/*
		JOINING THE TABLES
		*/

SELECT * 
FROM PortfolioCovid..[Covid19-Vaccination-Table]

SELECT *
FROM [Covid19-Deaths-Table] death
JOIN [Covid19-Vaccination-Table] vac
	ON death.location = vac.location
	AND death.date = vac.date;


		/*
		 TOTAL POPULATION VS VACCINATIONS
		*/

SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations
FROM [Covid19-Deaths-Table] death
JOIN [Covid19-Vaccination-Table] vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY 2, 3

		/*
		IN ORDER TO SEE THE NEW VACCINATION COUNTING PER DAY WE NEED TO USE 'PARTITION BY'. 
		THIS WILL GIVE A ROLLING COUNTING 
		*/
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) 
	OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollCountVaccination
	FROM [Covid19-Deaths-Table] death
	JOIN [Covid19-Vaccination-Table] vac
		ON death.location = vac.location
		AND death.date = vac.date
	WHERE death.continent IS NOT NULL
	ORDER BY 2, 3

		/*
		IN ORDER TO SEE THE PERCENTAGE OF THE POPULATION HAS BEEN VACCINATED DAILY WE NEED TO USE A CTE FOR FURTHER CALCULATIONS.
		*/
		-- percentage of the population vaccinated: roulling counting = (RollCountVaccination/population)*100
WITH POPvsVAC (continent, location, date, population, new_vaccinations, RollCountVaccination)
AS
	(
	SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) 
	OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollCountVaccination
	FROM [Covid19-Deaths-Table] death
	JOIN [Covid19-Vaccination-Table] vac
		ON death.location = vac.location
		AND death.date = vac.date
	WHERE death.continent IS NOT NULL
	) 
--to see the calculation we need to run it within the CTE
SELECT * , (RollCountVaccination/population)*100  AS DailyVaccinationPercentage
FROM POPvsVAC

/*
ANOTHER WAY IS USING 'TEMP TABLE' FOR FURTHER CALCULATIONS.
*/

DROP TABLE IF EXISTS #PercentPopulationVaccinated --USING THIS QUERY IS HELPFUL IF ANY ALTERATIONS IS NEEDED IN FUTURE, 
-- MAKING IT EASIER TO DO IT
CREATE TABLE #PercentPopulationVaccinated
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollCountVaccination numeric,
	)
		--- inserting the data into the TEMP TABLE
INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollCountVaccination
	FROM [Covid19-Deaths-Table] death
	JOIN [Covid19-Vaccination-Table] vac
		ON death.location = vac.location
		AND death.date = vac.date
	WHERE death.continent IS NOT NULL
SELECT * , (RollCountVaccination/population)*100  AS DailyVaccinationPercentage
FROM #PercentPopulationVaccinated;

GO
---CREATING VIEW TO STORE DATA FOR LATER VISUALISATION

CREATE VIEW PercentPopulationVaccinated
AS
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollCountVaccination
	FROM [Covid19-Deaths-Table] death
	JOIN [Covid19-Vaccination-Table] vac
		ON death.location = vac.location
		AND death.date = vac.date
	WHERE death.continent IS NOT NULL
GO
SELECT *
FROM PercentPopulationVaccinated

		/*
		After creating the view and selecting the first 1000 rows we encountered an error: 
		'ORDER BY list of RANGE window frame has total size of 1020 bytes.
		Largest size supported is 900 bytes.'
		So we need to add ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW to the OVER clause. 
		This specifies that the window frame starts at the first row of the partition and ends at the current row 
		within the partition, which is typically how a rolling total is calculated.
		*/

DROP VIEW IF EXISTS PercentPopulationVaccinated

GO

CREATE VIEW PercentPopulationVaccinated
AS
SELECT 
    death.continent, 
    death.location, 
    death.date, 
    death.population, 
    vac.new_vaccinations,
    SUM(CONVERT(float, vac.new_vaccinations)) OVER (
        PARTITION BY death.location 
        ORDER BY death.location, death.date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RollCountVaccination
FROM 
    [Covid19-Deaths-Table] death
	JOIN  [Covid19-Vaccination-Table] vac
    ON death.location = vac.location
    AND death.date = vac.date
WHERE 
    death.continent IS NOT NULL;
