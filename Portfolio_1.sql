select * from Portfolio..covid_deaths
where continent is not null
order by 3,4

select * from Portfolio..covid_vaccination$
where continent is not null
order by 3,4

--total cases vs total deaths

select location, date, total_cases, new_cases,total_deaths, population_density
from portfolio..Covid_deaths
where continent is not null
order by 1,2

select location, date, total_cases,total_deaths,(total_cases/population_density)*100 as DeathPercentage
from portfolio..Covid_deaths
where continent is not null
order by 1,2

--select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
--from portfolio..Covid_deaths
--where location like '%states%'
--order by 1,2

select location, population_density, MAX(total_cases) as Infection, MAX((total_cases/population_density))*100 as DeathPercentage
from portfolio..Covid_deaths
--where location like '%states%'
where continent is not null
group by location, population_density
order by Infection

--Looking at the countries with highest infection rate compared to population
select location, population_density, MAX(total_cases) as Infection, MAX((total_cases/population_density))*100 as DeathPercentage
from portfolio..Covid_deaths
--where location like '%states%'
where continent is not null
group by location, population_density
order by DeathPercentage desc

--Looking at the countries with highest death count per population
select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
from portfolio..Covid_deaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--breaking by continent
select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
from portfolio..Covid_deaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

select SUM(new_cases) as total_cases,SUM(cast(new_deaths as bigint)) as total_deaths,
SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
from portfolio..covid_deaths
where continent is not null
--group by date
order by 1,2

--join 2 tables
select *
from portfolio..covid_deaths dea
join
portfolio..covid_vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date

---looking at total population vs vaccination
select dea.continent,dea.location, dea.date,dea.population_density, vac.new_vaccinations
from portfolio..covid_deaths dea
join
portfolio..covid_vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date


select dea.continent,dea.location, dea.date,dea.population_density, vac.new_vaccinations
from portfolio..covid_deaths dea
join
portfolio..covid_vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


select dea.continent, dea.location, dea.date,dea.population_density, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingVacinated 
--(RollingVacinated/Population_density)*100
from portfolio..covid_deaths dea
join
portfolio..covid_vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

with PopvsVac (continent, location, date,population_density, new_vaccinations, RollingVacinated )
as
(
select dea.continent, dea.location, dea.date,dea.population_density, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingVacinated 
--(RollingVacinated/Population_density)*100
from portfolio..covid_deaths dea
join
portfolio..covid_vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingVacinated/Population_density)*100
from PopvsVac

drop table if exists #percentpopulationvacinated
Create table #percentpopulationvacinated
(
continent nvarchar (255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccination numeric
)

Insert into #percentpopulationvacinated
Select dea.continent, dea.location, dea.date, dea.population_density,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingVacinated 
--(RollingVacinated/Population_density)*100
from portfolio..covid_deaths dea
join
portfolio..covid_vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
--select *, (RollingVacinated/Population_density)*100
--from #percentpopulationvacinated

CREATE VIEW percentpopulationvacinated as 
Select dea.continent, dea.location, dea.date, dea.population_density,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingVacinated 
--(RollingVacinated/Population_density)*100
from portfolio..covid_deaths dea
join
portfolio..covid_vaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from percentpopulationvacinated
