-- Queries used for Tableau Covid Project

--1. Showing Global Death Percentage

Select Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/Sum(new_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Just a double check based off the data provided
-- Numbers are extremely close so I will keep them


--Select Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/Sum(new_cases)*100 as Deathpercentage
--From PortfolioProject..CovidDeaths
--Where location = 'World'
--Order by 1,2

-- 2. Showing Death Count Per Continent

-- Need to take these out as they are not included in the above queries and want to stay consistent
-- Note European Union is part of Europe
-- Needed to elimate not like '%income%'

Select location, Sum(Cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
and location not in ('World','European Union','International')
and location not like '%income%'
Group by location 
Order by TotalDeathCount desc

-- 3. Showing Percentage of Population Infected Per Country

Select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

-- 4. Showing Rolling Percentage of Population Infected Per Country for Forecast 

Select location, population, date, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population, date
Order by PercentPopulationInfected desc

-- 5.  Showing Rolling Population Vaccinated

Select dea.continent, dea.location, dea.date, dea.population, Max(vac.new_vaccinations) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Group by dea.continent, dea.location, dea.date, dea.population
Order by 2,3

-- Went with abve to remove New Vaccinations for better in visual (without Partition)
-- Below query would be great for Std. Dev. to indentify Yearly Treads for Cost Analysis 

--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location 
--Order by dea.location, dea.date) as RollingPeopleVaccinated
--From PortfolioProject..CovidDeaths  dea
--Join PortfolioProject..CovidVaccinations  vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

-- 6. Global Death Percentage if Infected

Select Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Just a double check based off the data provided
-- Numbers are extremely close so I will keep them

--Select Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--Where location = 'World'
--Order by 1,2


-- 7. Use CTE to Show Rolling People Vaccinated & Rolling Percentage Vaccinated


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