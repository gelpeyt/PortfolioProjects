-- Data Exploration of COVID Data using SQL

-- Select * 
-- From PortfolioProject..CovidDeaths
-- Where continent is not null
-- Order by 3,4

-- Select data to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Philippines' and continent is not null
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of population contracted COVID

Select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where location = 'Philippines' and continent is not null
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by InfectedPopulationPercentage desc

-- Showing Countries with Highest Death Count

Select location, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing Continents with Highest Death Count

Select continent, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select Sum(new_cases) as total_new_cases, Sum(Cast(new_deaths as int)) as total_new_deaths,
	(Sum(Cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, 
	Convert(bigint, vac.new_vaccinations) as new_vaccinations,
	Sum(Convert(bigint, vac.new_vaccinations)) 
		OVER (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Using CTE
With PopsVsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, 
		Convert(bigint, vac.new_vaccinations) as new_vaccinations,
		Sum(Convert(bigint, vac.new_vaccinations)) 
			OVER (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
--	Where dea.continent is not null
--	Order by 2,3
)

Select *, (Rolling_People_Vaccinated/Population)*100 as VaccinatedPopulationPercentage
From PopsVsVac

-- Using Temp Table
Drop table if exists #PercentPopulationVacinated
Create table #PercentPopulationVacinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population float,
	New_Vaccinations bigint,
	Rolling_People_Vaccinated bigint
)

Insert into #PercentPopulationVacinated	
	Select dea.continent, dea.location, dea.date, dea.population, 
		Convert(bigint, vac.new_vaccinations) as new_vaccinations,
		Sum(Convert(bigint, vac.new_vaccinations)) 
			OVER (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
--	Order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100 as VaccinatedPopulationPercentage
From #PercentPopulationVacinated


-- Creating View to Store Data for Visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, 
	Convert(bigint, vac.new_vaccinations) as new_vaccinations,
	Sum(Convert(bigint, vac.new_vaccinations)) 
		OVER (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated
