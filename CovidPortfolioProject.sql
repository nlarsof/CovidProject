
Select *
From PortfolioProjectCovid..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProjectCovid..CovidVaccinations$
--order by 3,4 

--Select data we are going to be using 

Select Location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjectCovid..CovidDeaths$
where continent is not null
order by 1,2


Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjectCovid..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


--LETS BREAK THINGS DOWN BY CONTINENT 


Select location, MAX(cast(Total_deaths as int))as TotalDeathCount
From PortfolioProjectCovid..CovidDeaths$
--Where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc

--Showing continents with the highest death count per population


--Global Numbers 

Select Location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths$
--where location like '%states%'
where continent is not null
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths$
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--USE CTE 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths$ dea
Join PortfolioProjectCovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac

--USE CTE 



-- TEMP TABLE 

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths$ dea
Join PortfolioProjectCovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations 

CREATE VIEW NewPercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths$ dea
Join PortfolioProjectCovid..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

