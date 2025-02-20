Select * 
From PortfolioProject..CovidDeaths
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, total_deaths, new_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--- Looking at Total Cases VS Total Deaths
---Shows likelihood of dying if you contract covid in your contry

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
Where location like 'india%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%India'

order by 1,2

--Looking at Countries with Highest Infecction Rate compared to Population

Select Location,  Population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as 
PercentagePopulationInfected
from PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentagePopulationInfected desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is  not null 
Group by continent
order by TotalDeathCount desc


-- Global Numbers


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Looking at total Population vs vaccinations

Select dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date    = vac.date
	  where dea.continent is not null
	  order by  3, 4


-- USE CTE

with PopvsVac ( continent, Location, Date, Population,New_Vaccinantion, RollingPeopleVaccinated)
as
(

Select dea.continent,  dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
	  and dea.date    = vac.date
where dea.continent is not null
--order by  3, 4
	  )

select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac
--order by 3 , 4

--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);
WITH VaccinationData AS 
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(INT, vac.new_vaccinations)) OVER (
            PARTITION BY dea.location ORDER BY dea.date
        ) AS RollingPeopleVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
)
INSERT INTO #PercentPopulationVaccinated
SELECT * FROM VaccinationData;

SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentVaccinated
FROM #PercentPopulationVaccinated;



-- Creating View to store data for later visualisation


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * 
From PercentPopulationVaccinated
