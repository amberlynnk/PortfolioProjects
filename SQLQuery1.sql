SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order BY 3,4

--select data that is being used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- looking at total_cases vs total_deaths
-- shows likelyhood of covid deaths based on United states 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

--Looking at total_cases vs population 
--This shows the percentage of the population that contracted covid
SELECT location, date, population, total_cases, (total_cases/Population)*100 AS percentpopulation
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

--Looking at the countries with the highest infection rates compared to the population
SELECT location, MAX(total_cases) As highestinfectioncount, (Max(total_deaths/total_cases))*100 AS percentpopulationinfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, Population
order by percentpopulationinfected desc

-- showing countries with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) As totaldeathcount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is not null
GROUP BY Location
order by totaldeathcount DESC

-- broken down by continent
SELECT location, MAX(cast(total_deaths as int)) As totaldeathcount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is null
GROUP BY location
order by totaldeathcount DESC

-- Showing Continents with the highest death count

SELECT location, MAX(cast(total_deaths as int)) As totaldeathcount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is not null
GROUP BY Location
order by totaldeathcount DESC

--Global numbers
SELECT SUM(new_cases) As total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS deathpercentage 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
--Group by date
order by 1,2


--Looking at the total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location,dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE 
WITH popvsvac (continent, location, date, population,new_vaccinations, rollingpeoplevaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location,dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT * , (rollingpeoplevaccinated/population)*100 AS vacinatedpop
FROM popvsvac

--Temp table

DROP table if exists #percentpopulationvaccinated
CREATE table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location,dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * , (rollingpeoplevaccinated/population)*100 
FROM #percentpopulationvaccinated

--Creating a view to store data for later visulizations

CREATE VIEW percentpopulationvaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location,dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


-- Created a view for total population vs vaccinations visulization 
CREATE VIEW totalpopvsvaccinations AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location,dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

-- Created view for continents with the highest death counts
CREATE VIEW  highestdeathcountspercontinent as 
SELECT location, MAX(cast(total_deaths as int)) As totaldeathcount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is not null
GROUP BY Location
--order by totaldeathcount DESC

-- created view for maximum deaths per continent
CREATE VIEW maxdeathspercontinent AS
SELECT location, MAX(cast(total_deaths as int)) As totaldeathcount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is null
GROUP BY location
--order by totaldeathcount DESC


--creating view for countries with the highest death counts per population numbers

CREATE VIEW countriesdeathsperpopulation AS
SELECT location, MAX(cast(total_deaths as int)) As totaldeathcount 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is not null
GROUP BY Location
--order by totaldeathcount DESC

--Creating view for total covid cases per population

CREATE VIEW totalcovidperpopulation AS
SELECT location, date, population, total_cases, (total_cases/Population)*100 AS percentpopulation
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
--order by 1,2