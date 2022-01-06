Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows the likihood of death if contracted

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at the Total Cases vs Population
-- Show what percentage of the Population has got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfection, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population (Issue with data type nvarchar)

Select location, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Showing Total Death Count broke down by Continent

Select location, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc

-- Showing breakdown by Continent without '%income%'
-- Create View

SELECT *
FROM
(
Select location, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
--Order by TotalDeathCount desc
) tmpResults
where location not like '%income%'
Order by TotalDeathCount desc

-- Global Numbers by Date

Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- Global Numbers

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2

-- Joining both tables
-- Looking at Total Population vs Vaccinations
-- Create View

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Showing Rolling Count of New Vaccinations per Day
-- Create View

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Use CTE to ADD Rolling Percentage Vaccinated

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
From PopvsVac

-- Temp Table
Drop Table if exists #PercentPeopleVaccinated 
Create Table #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null

Select*, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
From #PercentPeopleVaccinated

--Creating View to store data fo Visualations
-- Rolling Percentage of New Vaccinations Per Day Veiw

Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select* 
From PercentPeopleVaccinated

-- Global Numbers Veiw

Create View GlobalDeathCount as
SELECT *
FROM
(
Select location, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
) tmpResults
where location not like '%income%'

-- Populations vs Vaccinations Veiw

Create View PopVsVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

-- Rolling New Vaccinations Per Day View

Create View RollingVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null




