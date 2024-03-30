SELECT *
FROM PortfolioProject.coviddeaths;

SELECT *
FROM PortfolioProject.covidvaccinations;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.coviddeaths;

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
FROM PortfolioProject.coviddeaths;

-- Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS case_rate
FROM PortfolioProject.coviddeaths;

--  Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS max_case, MAX((total_cases/population))*100 AS max_case_rate
FROM PortfolioProject.coviddeaths
GROUP BY location, population
ORDER BY 4 DESC;

-- Countries with Highest Death Count per Location
SELECT location, MAX(convert(total_deaths,unsigned integer)) AS max_death_count
FROM PortfolioProject.coviddeaths
WHERE continent is not null
GROUP BY location
ORDER BY max_death_count DESC;

-- Countries with Highest Death Count per Continent
SELECT continent, MAX(convert(total_deaths,unsigned integer)) AS max_death_count
FROM PortfolioProject.coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY max_death_count DESC;

-- Global Numbers
SELECT date, SUM(new_cases) AS total_new_cases, SUM(convert(new_deaths, unsigned integer)) AS total_new_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_rate
FROM PortfolioProject.coviddeaths
GROUP BY date
ORDER BY death_rate DESC;

-- Total Population vs. Total Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null;

-- Accumulated Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(vac.new_vaccinations, unsigned integer)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS accumulated_vaccinations
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

-- CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, Accumulated_vaccinations) AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(vac.new_vaccinations, unsigned integer)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS accumulated_vaccinations
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac 
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (accumulated_vaccinations/population)*100
FROM PopvsVac;

-- Temporary Table
DROP TABLE IF EXISTS PercentPopulationVaccinated;
USE PortfolioProject;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Accumulated_vaccinations numeric
);

INSERT INTO percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(vac.new_vaccinations, unsigned integer)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS accumulated_vaccinations
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac 
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null;

SELECT *
FROM PercentPopulationVaccinated;

-- For Data Visualization
CREATE VIEW death_rate AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
FROM PortfolioProject.coviddeaths;

CREATE VIEW case_rate AS
SELECT location, date, population, total_cases, (total_cases/population)*100 AS case_rate
FROM PortfolioProject.coviddeaths;

CREATE VIEW max_case AS
SELECT location, population, MAX(total_cases) AS max_case, MAX((total_cases/population))*100 AS max_case_rate
FROM PortfolioProject.coviddeaths
GROUP BY location, population
ORDER BY 4 DESC;

CREATE VIEW max_death_count AS
SELECT location, MAX(convert(total_deaths,unsigned integer)) AS max_death_count
FROM PortfolioProject.coviddeaths
WHERE continent is not null
GROUP BY location
ORDER BY max_death_count DESC;

CREATE VIEW accumulated_vaccinations AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(vac.new_vaccinations, unsigned integer)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS accumulated_vaccinations
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;
