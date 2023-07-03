select * from CovidDeaths

select * from CovidVaccinations

select location, date, total_cases, new_cases, total_deaths, population from CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying of you contract with the corona virusin your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%India%'
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercent
from CovidDeaths
--where location like '%India%'
order by 1,2

--Looking at countries with highest infection Rate compared to population

select location, population, Max(total_cases) as HighestInfected, Max((total_cases/population))*100 as HighestPopulationPercent
from CovidDeaths
--where location like '%India%'
group by location, population
order by HighestPopulationPercent desc

--LETS BREAK THIS DOWN BY CONTINENT


--Showing countries with highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
--where location like '%India%'
where continent is not null
group by continent
order by TotalDeaths desc


--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_Percent 
from CovidDeaths
--where location like '%India%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by 
dea.location order by dea.location, dea.date) as Cumilative_Total 
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With Popvsvac (continent, location, date, population, new_vaccinations, CumilativeTotal)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by 
dea.location order by dea.location, dea.date) as CumilativeTotal 
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (CumilativeTotal/population)*100 as Cumilative_Percent
from Popvsvac

--Temp Table
drop table if exists Percentpeoplevaccinated 
create table Percentpeoplevaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumilativeTotal numeric
)
insert into Percentpeoplevaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by 
dea.location order by dea.location, dea.date) as CumilativeTotal 
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
select *, (CumilativeTotal/population)*100 as Cumilative_Percent
from Percentpeoplevaccinated

--create view to store data for later visuals

create view Percentpeoplevacc as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by 
dea.location order by dea.location, dea.date) as CumilativeTotal 
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from Percentpeoplevacc

--View for Highest Death per Continent

create view HighestDeath as
select continent, MAX(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
--where location like '%India%'
where continent is not null
group by continent
--order by TotalDeaths desc

select * from HighestDeath

