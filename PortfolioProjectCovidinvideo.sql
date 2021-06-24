Select *
From [Portfolio Project]..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths$
Order by 1,2
-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
Where location like '%Pakistan%'
Order by 1,2

-- Total Cases vs Population
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths$
--Where location like '%Pakistan%'
Order by 1,2

-- Country with Highest infection Rate vs Population
Select location, population,MAX(total_cases)as HighestInfectionCount, (MAX(total_cases) /population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths$
--Where location like '%Pakistan%'
Group by location,population
Order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
--Where location like '%Pakistan%'
where continent is not null
Group by location
Order by TotalDeathCount desc

-- Breakdown according to Continents
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
--Where location like '%Pakistan%'
where continent is null
Group by location
Order by TotalDeathCount desc

--Showing Continents with Highest Death Count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
--Where location like '%Pakistan%'
where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global Numbers

Select Sum(new_cases) as total_cases,Sum(cast(new_deaths as int)) as total_deaths, Sum(new_cases)/Sum(cast(new_deaths as int)) as DeathPercentage
From [Portfolio Project]..CovidDeaths$
--Where location like '%Pakistan%'
where continent is not null
--group by date
Order by 1,2


--Total Population vs Vaccination
--Need to check functions used in next line.
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
 where dea.continent is not null
--order by 2,3
 )
 Select * , (RollingPeopleVaccinated/Population)*100
 From PopvsVac

 --Temp Table

 DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

 Insert into #PercentPopulationVaccinated
 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3



SELECT * FROM PercentPopulationVaccinated