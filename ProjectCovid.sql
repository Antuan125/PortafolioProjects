


--select *
--from Portafolio..Deaths
--where continent is not null
--order by 3,4

--selecting data 

--Select location, date, total_cases, new_cases, total_deaths, population
--from Portafolio..Deaths
--order by 1,2

---getting total cases vs total deaths
---add note
--Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  as DeathPercentage
--from Portafolio..Deaths
--where location like '%japan%'
--order by 1,2


--Total case vs total population
--Select location, date, total_cases,population, (total_cases/population)*100  as Infectedpopulation
--from Portafolio..Deaths
----where location like '%mexic%' --specify country
--order by 1,2
---Looking at country for highest infection rate compared to population 
--Select location,population, Max(total_cases) as HInfectionCount, MAX((total_cases/population))*100  as PercentInfectedPopulation
--from Portafolio..Deaths
----where location like '%mexic%' --specify country
--Group by location,population
--order by PercentInfectedPopulation desc


-----Showing highest deaths by location
--Select location, Max(cast(total_deaths as int )) as PeopleDeath
--from Portafolio..Deaths
--where continent is not null
----where location like '%mexic%' --specify country
--Group by location
--order by PeopleDeath desc


---Showing highest deaths by continent
--Select continent, Max(cast(total_deaths as int )) as PeopleDeath
--from Portafolio..Deaths
--where continent is not null
----where location like '%mexic%' --specify country
--Group by continent
--order by PeopleDeath desc


--Global numbers
--Select SUM(new_cases)as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, 
--SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, (total_deaths/total_cases)*100  as DeathPercentage
--from Portafolio..Deaths
--where continent is not null
--order by 1,2

--Looking at total population vs vaccinations using CTE
with popvsac(continent,location,date,population,new_vaccinations,totalvaccinations)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as totalvaccinations--, Max(totalvaccinations/population) *100
from portafolio..Deaths dea
join Portafolio..Vaccinations vac
	on  dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (totalvaccinations/population)*100
from popvsac
order by 2,3


--Looking at total population vs vaccinations using temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	totalvaccinations numeric
	)
insert into #percentpopulationvaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as totalvaccinations--, Max(totalvaccinations/population) *100
from portafolio..Deaths dea
join Portafolio..Vaccinations vac
	on  dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
select *, (totalvaccinations/population)*100
from #percentpopulationvaccinated
order by 2,3

--creating view to visualize data
create view percentpopulationvaccinated as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as totalvaccinations--, Max(totalvaccinations/population) *100
from portafolio..Deaths dea
join Portafolio..Vaccinations vac
	on  dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3