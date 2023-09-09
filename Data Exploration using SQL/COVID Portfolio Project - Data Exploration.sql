/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4



--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



-- Total Cases Vs Total Deaths
-- Shows the likelyhood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%india%' and continent is not null
order by 1,2



-- Looking at Total cases Vs Population
-- Shows what percentage of population got infected

Select Location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
order by 1,2



-- Countries with highest infection rate when compared to population

Select Location, population, MAX(total_cases), MAX((total_cases/population))*100 as PopulationPercentage
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by Location, population
order by PopulationPercentage desc



-- Countries with highest death count when compared to population

Select Location, MAX(cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by Location
order by TotalDeathCount desc



-- Showing continents with the highest death count per population

Select continent, MAX(cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc



--Global Numbers
--Sorting it on daily basis

Select date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2



-- On a whole total numbers

Select SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2



-- Total number of vaccinations filtered out by location and date
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- Vaccination count Vs Total population
-- Using CTE to perform calculations on Partition by

with PopVsVac (Continent, location, date, population, new_vaccinations, VaccinationCount) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (VaccinationCount/population)*100 as VaccinationPercentage
from PopVsVac



-- Using TEMP Table to perform calculations on Partition by

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinationCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (VaccinationCount/population)*100 as VaccinationPercentage
from #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null