/*
Covid 19 Data Exploration 
*/


Select *
From PortfolioProject..CovidDeaths
Order By 3,4



-- Select Data that we are going to be using

Select location, date, total_cases, new_cases,total_deaths, population
From PortfolioProject..CovidDeaths
Order By 3,4 desc



-- Looking at Total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage 
From PortfolioProject..CovidDeaths
Where location Like '%Turkey%'
Order By 1,2



-- Looking at Total cases vs Population
-- Shows what percentage of population got covid

Select location, date, population, total_cases,  (total_cases/population)*100 As PercentPopulationInfected 
From PortfolioProject..CovidDeaths
-- Where location Like '%Turkey%'
Order By 5 desc



-- Looking at countries with highest infection rate compared to population

Select location,  population, max(total_cases) As HighestInfectionCount,  max((total_cases/population))*100 As PercentPopulationInfected 
From PortfolioProject..CovidDeaths
Group By location,population
Order By 4 desc



-- Showing countries with highest death count per population

Select location,  population, max(cast (total_deaths as int)) As HighestDeathCount --,  max((total_deaths/population))*100 As PercentPopulationDeath
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location,population
Order By 3 desc



-- Let's Break Things Down By Continent

Select continent, max(cast (total_deaths as int)) As TotalDeathCount  
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By 2 desc


Select location, max(cast (total_deaths as int)) As TotalDeathCount  
From PortfolioProject..CovidDeaths
Where continent is  null
Group By location
Order By 2 desc



-- Global Numbers

Select  date, SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
group by date
Order By 1,2

Select  SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
-- group by date
Order By 1,2

select * 
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
 on dea.location = vac.location
 and dea.date = vac.date



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 