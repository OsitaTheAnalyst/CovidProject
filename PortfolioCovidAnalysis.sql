select * 
from CovidDeaths
where continent = ''

select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from CovidDeaths
where location like '%States%'
--order by 1,2

select * from CovidVaccination
--order by 3,4

--Looking at Total cases vs Total Deaths
--shows likelihood of dying from covid in each country
Select Location, date, total_cases, total_deaths, (total_deaths/nullif(total_cases,0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where location like '%Niger%'
--order by 1,2

--Looking at Total cases vs Population
--shows likelihood of contacting covid in Nigeria
Select Location, date, total_cases, population, (nullif(total_cases,0)/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths 
where location like '%Nigeria%'
order by 1,2

--Countries with the Highest Infection rate compared with their Population
Select Location, Population, Max(total_cases) as HighestInfectionCount, max(nullif(total_cases,0)/nullif(population,0))*100 as PercentageInfectedPopulation
from PortfolioProject..CovidDeaths 
--where location like '%Nigeria%'
group by location, population
order by PercentageInfectedPopulation desc

--Countries with the Highest Mortality rate
Select Location, Max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent !='' 
group by location
order by TotalDeathCount desc

--Breaking it down to continents
Select Continent, Max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent !='' 
group by continent
order by TotalDeathCount desc

--Checking the Global new cases by date
Select date, Sum(new_cases) as NewCases, Sum(new_deaths) as NewDeaths ,Sum(nullif(new_deaths,0))/Sum(nullif(new_cases,0))*100 as PercentageNewDeaths
from PortfolioProject..CovidDeaths 
--where location like '%Nigeria%'
group by date

--Total Global new cases
Select Sum(new_cases) as NewCases, Sum(new_deaths) as NewDeaths ,Sum(nullif(new_deaths,0))/Sum(nullif(new_cases,0))*100 as PercentageNewDeaths
from PortfolioProject..CovidDeaths 

--Looking at the Population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.date, dea.location) as RollingCountOfPeopleVaccinated
from CovidDeaths dea
join CovidVaccination vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent !=''

--USE CTE
with PoPvsVaC (Continent,Location, Date, Population, New_Vaccinations, RollingCountOfPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.date, dea.location) as RollingCountOfPeopleVaccinated
from CovidDeaths dea
join CovidVaccination vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent !=''
) 
select *,(nullif(RollingCountOfPeopleVaccinated,0)/nullif(Population,0))*100 as PercentCountOfPeopleVaccinated
from PoPvsVaC

--Creating views to store data for later visualization

create view PercentCountOfPeopleVaccinated as
with PoPvsVaC (Continent,Location, Date, Population, New_Vaccinations, RollingCountOfPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.date, dea.location) as RollingCountOfPeopleVaccinated
from CovidDeaths dea
join CovidVaccination vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent !=''
) 
select *,(nullif(RollingCountOfPeopleVaccinated,0)/nullif(Population,0))*100 as PercentCountOfPeopleVaccinated
from PoPvsVaC
--order by 1,2

--checking the created view
select * from PercentCountOfPeopleVaccinated