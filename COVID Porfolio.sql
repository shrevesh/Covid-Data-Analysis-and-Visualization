select * 
from coviddeath
where continent is not null

select *
from covidvaccin

-- Select Data that we are going to use
select location, date, total_cases, new_cases, total_deaths, population
from coviddeath

-- Looking at Total Cases and Total Deaths: how many cases they recorded and how many deaths, and the death rate
-- Show the likelihood of dying if you contract covid in your country
select location, convert(varchar,date, 102) date, total_cases, total_deaths, cast((total_deaths/total_cases)*100 as decimal(10,2)) death_rate
from coviddeath
where location like '%states%'
and continent is not null -- if location have states in their name
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select location, convert(varchar,date, 102) date, total_cases, population, cast((total_cases/population)*100 as decimal(10,2)) contraction_rate
from coviddeath
-- where location like '%states%' -- if location have states in their name
where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, Max(total_cases) HighestInfectionCount, cast((max(total_cases)/population)*100 as decimal(10,2)) InfectionRate
from coviddeath
where continent is not null
Group by location, population
order by 4 desc

-- Looking at Countries with Highest Death Rate compared to Population
select location, Max(total_cases) HighestInfectionCount, cast((max(total_cases)/population)*100 as decimal(10,2)) InfectionRate, Max(cast(total_deaths as int)) HighestDeathsCount, cast((max(cast(total_deaths as int))/population)*100 as decimal(10,2)) DeathRate
from coviddeath
where continent is not null
Group by location, population
order by 3 desc

-- Let's break things down by continent
select location, MAX(cast(total_cases as int)) HighCaseCount, Max(cast(total_deaths as int)) HighestDeathsCount
from coviddeath
where continent is null 
and location not in ('World', 'High Income', 'Upper middle income','Lower middle income', 'Low income')
Group by location
order by 2 desc

-- Let's break things down by  income
select location, MAX(cast(total_cases as int)) HighCaseCount,Max(cast(total_deaths as int)) HighestDeathsCount
from coviddeath
where continent is null
and location in ('High Income', 'Upper middle income','Lower middle income', 'Low income')
Group by location
order by 2 desc



-- Showing the continent with the highest death count per population
select continent, Max(cast(total_deaths as int)) HighestDeathsCount
from coviddeath
where continent is not null 
Group by continent
order by 2 desc

-- Global Number
-- Death Percentage across the world
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_dealths, cast(sum(cast(new_deaths as int))/sum(new_cases) *100 as decimal(10,2)) as DeathPercentage
from coviddeath
where continent is not null
and year(date) < 2022
order by 1,2

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_dealths, cast(sum(cast(new_deaths as int))/sum(new_cases) *100 as decimal(10,2)) as DeathPercentage
from coviddeath
where continent is not null
and year(date) > 2022
order by 1,2

Select year(date) year, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_dealths, cast(sum(cast(new_deaths as int))/sum(new_cases) *100 as decimal(10,2)) as DeathPercentage
from coviddeath
where continent is not null
group by year(date)
order by 1,2

-- Death Percentage across the world by day
Select cast(date as date) date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_dealths, cast(sum(cast(new_deaths as int))/isnull(sum(new_cases),0) *100 as decimal(10,2)) as DeathPercentage
from coviddeath
where continent is not null
group by date
having sum(new_cases) > 0
order by 2

-- Looking at Total Population vs Vaccinations

select dea.continent,
       dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeath dea
inner join covidvaccin vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac AS
(select dea.continent,
       dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeath dea
inner join covidvaccin vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/population)*100 PeopleVaccinatedPercentage
from PopvsVac

-- DROP Table if exists vpopvac
CREATE VIEW vpopvac AS
select dea.continent,
       dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeath dea
inner join covidvaccin vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 PeopleVaccinatedPercentage
from vpopvac

select location, max(RollingPeopleVaccinated)/population*100 PeopleVaccinatedPercentage
from vpopvac
group by location, population
order by 1 desc

