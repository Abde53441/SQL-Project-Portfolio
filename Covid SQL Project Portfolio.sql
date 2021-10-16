Select * from 
CovidDeaths$ 
where continent is not null
order by 3,4

Select * from
CovidVaccinations$ 
order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2

-- We Will be Looking at Total Cases V/s Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
Where location = 'India' and continent is not null
order by 1,2

-- Looking at Total Cases V/s Population
-- finding out the percentage of population contracted Covid

Select location, date, total_cases,population,(total_cases/population)*100 as InfectionRate
from CovidDeaths$
Where location = 'India'
order by 1,2

-- Checking out Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths$
Group by location, population
order by PercentPopulationInfected DESC

--Checking out the Highest Death Count per population

Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths$
Where continent is not null
Group by location
order by HighestDeathCount  DESC

--Showing continent wise Highest Death Count Per Population

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths$
Where continent is not null
Group by continent
order by HighestDeathCount  DESC

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths$
Where continent is not null
--Group by date
order by 1,2

-- Looking at Total Vaccination Against Population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths$ dea JOIN CovidVaccinations$ vac 
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- Using Over and Partition to Calculate Running Total of Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea JOIN CovidVaccinations$ vac 
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--- USING CTE (Common Table Expression) for Above Query

WITH PopvsVac (Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea JOIN CovidVaccinations$ vac 
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

---USING TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea JOIN CovidVaccinations$ vac 
ON dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating View to store database

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea JOIN CovidVaccinations$ vac 
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select * from PercentPopulationVaccinated