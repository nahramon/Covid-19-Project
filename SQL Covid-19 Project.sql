select *
from CovidDeaths
where continent is not null
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

-- Select Data that we are going to use:
--select location, date, total_cases, new_cases, total_deaths, population
--from COVIDProject..CovidDeaths
--order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Chances of dying in Argentina if you contract COVID
select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from COVIDProject..CovidDeaths
where location like '%argentina%'
and continent is not null
order by 1,2


-- Looking at the Total Cases vs Population
-- Shows the percentage of population that got COVID
select location, date, population, total_cases, (total_cases / population) * 100 as PercentPopulationInfected 
from COVIDProject..CovidDeaths
where location like '%argentina%' 
and continent is not null
order by 1,2

-- Countries with highest infection rate compared to Population
select location, population, MAX( total_cases) as HighestInfectionCount, (MAX(total_cases) / population) * 100 as PercentPopulationInfected 
from COVIDProject..CovidDeaths
where continent is not null
group by population, location
order by PercentPopulationInfected desc

-- Countries with the highest death count compared to Population
select location, MAX( cast(total_deaths as int)) as TotalDeathCount
from COVIDProject..CovidDeaths
where continent is not null
group by  location
order by TotalDeathCount desc


-- Continent with the highest death count compared to Population
select continent, MAX( cast(total_deaths as int)) as TotalDeathCount
from COVIDProject..CovidDeaths
where continent is not null
group by  continent
order by TotalDeathCount desc

-- Global Numbers by day
select date, SUM(new_cases) as total_cases, SUM( cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
from COVIDProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- Global Numbers total
select SUM(new_cases) as total_cases, SUM( cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
from COVIDProject..CovidDeaths
--where location like '%argentina%'
where continent is not null
order by 1,2


-- CTE Option
With PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccionated)
as
-- Total Population vs Vaccinations
(
Select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))  OVER (Partition by dea.location order by dea.location, dea.date) as PeopleVaccionated
--, PeopleVaccionated / population) * 100
From COVIDProject..CovidDeaths as dea
 Join COVIDProject..CovidVaccinations as vac
	On dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
--Order by 2,3
)
select * , (PeopleVaccionated / population ) * 100
from PopvsVac


-- Temp Table Option

Create  Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccionated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))  OVER (Partition by dea.location order by dea.location, dea.date) as PeopleVaccionated
--, PeopleVaccionated / population) * 100
From COVIDProject..CovidDeaths as dea
 Join COVIDProject..CovidVaccinations as vac
	On dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
--Order by 2,3

select * , (PeopleVaccionated / population ) * 100
from #PercentPopulationVaccinated

-- Create View for later visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))  OVER (Partition by dea.location order by dea.location, dea.date) as PeopleVaccionated
--, PeopleVaccionated / population) * 100
From COVIDProject..CovidDeaths as dea
 Join COVIDProject..CovidVaccinations as vac
	On dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null
--Order by 2,3