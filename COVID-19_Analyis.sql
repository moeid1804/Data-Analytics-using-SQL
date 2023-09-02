--select *
--from CovidDeaths
--order by 3,4

--select *
--from CovidVaccenation
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--looking  at Total Cases vs Total Deaths
--showing dying in my country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPrecentage
from CovidDeaths
where location like'%Egypt%'
order by 1,2

--looking  at Total Cases vs Population
--shows what precentage of population got Covif
select location,date,population,total_cases,(total_cases/population)*100 as PrecentPopulationInfected
from CovidDeaths
where location like'%States%'
order by PrecentPopulationInfected desc

--looking at countries with highest Infection rate compared to population
select location,population,max(total_cases)as HighestInfection,max((total_cases/population))*100 as PrecentPopulationInfected
from CovidDeaths
group by location,population
order by PrecentPopulationInfected desc

--looking at the highest deaths rate country
select location,sum(cast(total_deaths as int))as HighestDeaths,population
from CovidDeaths
where continent is not null
group by location,population
order by HighestDeaths desc

--showing contintents with the highest death
select continent,sum(cast(total_deaths as int))as HighestDeaths
from CovidDeaths
--where location like'%Egypt%'
where continent is not null
group by continent
order by HighestDeaths desc

--looking at population vs Vaccenations
select dead.continent,dead.location,dead.date,population,vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over(partition by dead.location order by dead.date,dead.location) as RollingVaccinated
from CovidVaccenation vacc
join CovidDeaths dead
on vacc.date=dead.date and dead.location=vacc.location
where dead.continent is not null
order by 2,3


--use CTE
with PopvsVac(Continent,Location,Date,Population,New_Vaccination,RollingVaccinated) as
(
select dead.continent,dead.location,dead.date,population,vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over(partition by dead.location order by dead.date,dead.location) as RollingVaccinated
from CovidVaccenation vacc
join CovidDeaths dead
on vacc.date=dead.date and dead.location=vacc.location
where dead.continent is not null
--order by 2,3
)
select*,(RollingVaccinated/Population)*100
from PopvsVac
order by RollingVaccinated desc


--create temp table
drop table if exists #PercentagePopulationToVaccinated
create table #PercentagePopulationToVaccinated
(
Continent varchar(100),
Location varchar(100),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingVaccinated numeric
)
insert into #PercentagePopulationToVaccinated
select dead.continent,dead.location,dead.date,population,vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over(partition by dead.location order by dead.date,dead.location) as RollingVaccinated
from CovidVaccenation vacc
join CovidDeaths dead
on vacc.date=dead.date and dead.location=vacc.location
where dead.continent is not null
--order by 2,3

 select*,(RollingVaccinated/Population)*100 as PercenageVaccinated
 from #PercentagePopulationToVaccinated

 --creating view to store data for later visualizations
 create view PercentagePopulationToVaccinated as 
 select dead.continent,dead.location,dead.date,population,vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over(partition by dead.location order by dead.date,dead.location) as RollingVaccinated
from CovidVaccenation vacc
join CovidDeaths dead
on vacc.date=dead.date and dead.location=vacc.location
where dead.continent is not null
--order by 2,3

select*
from PercentagePopulationToVaccinated