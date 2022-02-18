Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--looking at The Total Cases vs. Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by 1,2

--looking at your specific country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking a the Total Cases vs. The Population

Select location, date, population,total_cases, (total_cases/population)*100 as InfectPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at the Countries with Highest Infection Rate Compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, population
order by PercentagePopulationInfected DESC

-- LETS BREAK THINGS DOWN BY CONTIENENT


Select continent, Max(Cast(Total_Deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount DESC

--These numbers are incorrect because it doesnt include every country so lets change the group to location and include where continent is null

Select location, Max(Cast(Total_Deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount DESC

--want to exclude categories that mention income

--showing the contient with the hightest death count

Select continent, Max(Cast(Total_Deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount DESC

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%' 
Where continent is not null
--group by date
order by 1,2

--Covid Vaccinations Comparisons

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location)
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Same Formula Just using Convert instead of Cast

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxxed
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVaxed)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxed
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaxed/population)*100
From PopsVac

--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255), 
date datetime,
population numeric, 
new_vaccinations numeric,
RollingPeopleVaxed numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxxed
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaxed/population)*100
From #PercentPopulationVaccinated



-- Creating View to Store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaxxed
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

select*
From PercentPopulationVaccinated

Create View ContinentWithHighestDeathCount as 
Select continent, Max(Cast(Total_Deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
--order by TotalDeathCount DESC

Create View CountriesWithHighestInfectionComparedtoPopulation as 
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, population
--order by PercentagePopulationInfected DESC