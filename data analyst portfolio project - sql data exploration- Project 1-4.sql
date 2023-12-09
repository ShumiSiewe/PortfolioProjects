select  *
from CovidDeaths
order by 3,4


select *
from Covidvacination
order by 3,4


--- select the data that we are going to be using

select  [location],[date],total_cases,new_cases,total_deaths,[population]
from CovidDeaths
order by 1,2


---looking at total cases Vs total deaths
select  [location],[date],total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2

---looking at total cases Vs population

select  [location],[date],population,total_cases,(total_cases/population)*100 as percentpopulationinfected
from CovidDeaths
where location like '%states%'
order by 1,2

---looking at countries with highest infection rate  compared to population

select  [location],population,max(total_cases) as highestInfectioncount,max((total_cases/population))*100 as percentpopulationinfected
from CovidDeaths
--where location like '%states%'
group by [location],population
order by percentpopulationinfected desc


--showing the countries with highest death count per population
select location , max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by totaldeathCount desc

select location , max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is  null
group by location
order by totaldeathCount desc

select continent , max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by totaldeathCount desc


--global numbers

select  [date],sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

---joins

select dea.continent,dea.location,dea.date,dea.population,new_vaccinations
, sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingPeoplevaccinated
from CovidDeaths dea
join Covidvacination Vac
	on dea.location = vac.location
	and dea.date    = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE
with PopvsVac (continent,location,date,population,new_vaccinations,rollingPeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,new_vaccinations
, sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingPeoplevaccinated
from CovidDeaths dea
join Covidvacination Vac
	on dea.location = vac.location
	and dea.date    = vac.date
where dea.continent is not null

)
select *,(rollingPeoplevaccinated/population)*100
from PopvsVac



--Temp table
drop table if exists #percentpopulationvaccinated

create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingPeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,new_vaccinations
, sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingPeoplevaccinated
from CovidDeaths dea
join Covidvacination Vac
	on dea.location = vac.location
	and dea.date    = vac.date
--where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


---- creating view to store data for later visualizations

create view percentpopulationvaccinated as

select dea.continent,dea.location,dea.date,dea.population,new_vaccinations
, sum(convert(int,new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as rollingPeoplevaccinated
from CovidDeaths dea
join Covidvacination Vac
	on dea.location = vac.location
	and dea.date    = vac.date
where dea.continent is not null


select * from percentpopulationvaccinated