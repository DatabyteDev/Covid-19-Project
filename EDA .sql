

--Link to the Dataset used: https://ourworldindata.org/covid-deaths





select *
from PortfolioProject.dbo.CovidDeaths
order by 3,4


select *
from PortfolioProject.dbo.CovidVaccinations
order by 3,4



select location, date, population, total_cases, new_cases, total_deaths
from PortfolioProject.dbo.CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths, and the percentage mortality rate against those infected in Morocco


select location, date, total_cases, cast(total_deaths as int) as total_death, (cast(total_deaths as float) / total_cases) * 100 as Death_Precentage
from PortfolioProject..CovidDeaths
where location like 'Morocco'
order by 1,2




-- Looking at Total Cases vs Population, and the percentage of infection in each country

select location, date, population, total_cases,(total_cases/population)*100 as infection_Precentage
from PortfolioProject..CovidDeaths
-- where location like 'Morocco'
order by 1,2




-- Countries with the Highest Infection Rate per Population


select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as infection_Precentage
from PortfolioProject..CovidDeaths
group by location, population
order by infection_Precentage desc



-- Countries with the Highest Death Count per Population


select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Continents with the Highest Death Count per Population


select continent, max(convert(int,total_deaths)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



--Global Numbers



select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Precentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



--Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,new_vaccinations)) over(partition by dea.location order by dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--We can use a CTE to get the percentage of population vaccinated

with PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,new_vaccinations)) over(partition by dea.location order by dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 as VaccinationRate
from PopvsVac

-- We can also use a TEMP TABLE

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,new_vaccinations)) over(partition by dea.location order by dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 as VaccinationRate
from #PercentPopulationVaccinated




--Queries that will be used in Tableau for visualization


--1

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


--2

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International','High income','Upper middle income','Lower middle income','Low income')
Group by location
order by TotalDeathCount desc


--3

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


--4

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
