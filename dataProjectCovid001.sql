select *
from project001WithAlexTheAnalyst..covidDeaths
--where continent is not null
order by 3, 4

--select *
--from project001WithAlexTheAnalyst..covidVaccinations
--order by 3, 4

--select data to use
select location, date, total_cases, new_cases, total_deaths, population
from project001WithAlexTheAnalyst..covidDeaths
where continent is not null
order by 1, 2

--total cases vs total deaths
--likelihood of dying in Bangladesh 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from project001WithAlexTheAnalyst..covidDeaths
where location like 'B%desh'and continent is not null
order by 1, 2

--total cases vs population
--percentage of prople got covid
select location, date, total_cases, population, (total_cases/population)*100 as case_percentage
from project001WithAlexTheAnalyst..covidDeaths
where location like 'B%desh' and continent is not null
order by 1, 2

--highest infection rate countrywise
select location, population, MAX(total_cases) as highestInfection, MAX((total_cases/population))*100 as percentPopulationInfecdted
from project001WithAlexTheAnalyst..covidDeaths
where continent is not null
group by population, location
order by percentPopulationInfecdted desc

--death count countrywise
select location, max(cast(total_deaths as bigint)) as totalDeathCountCountryWise
from project001WithAlexTheAnalyst..covidDeaths
where continent is not null
group by location
order by totalDeathCountCountryWise desc

--death count continentwise001
select continent, location, max(cast(total_deaths as bigint)) as totalDeathCountCotinentWise
from project001WithAlexTheAnalyst..covidDeaths
where continent is null
group by location,continent
order by continent, totalDeathCountCotinentWise desc

--death count continentwise002
select continent, sum(totalDeathCountCotinentWise) as totalDeathCountCotinentWise
from (
select continent, location, max(cast(total_deaths as bigint)) as totalDeathCountCotinentWise
from project001WithAlexTheAnalyst..covidDeaths
where continent is not null
group by continent, location
--order by continent, totalDeathCountCotinentWise desc
) as a
--where continent is not null
group by continent
--order by continent, totalDeathCountCotinentWise desc

----total global data
select date, sum(new_cases) as globalNewCases, sum(cast(new_deaths as bigint)) as globalNewDeaths, sum(cast(new_deaths as bigint))/sum(new_cases)*100 as globalNewDeathPercentageByNewCases, sum(cast(total_cases as bigint)) as globalTotalCases, sum(cast(total_deaths as bigint)) as globalTotalDeaths
from project001WithAlexTheAnalyst..covidDeaths
where continent is not null
group by date
order by date

--global data for daily new cases over 10000
select date, globalNewCases, globalNewDeaths, globalNewDeathPercentageByNewCases, globalTotalCases, globalTotalDeaths
from(
select date, sum(new_cases) as globalNewCases, sum(cast(new_deaths as bigint)) as globalNewDeaths, sum(cast(new_deaths as bigint))/sum(new_cases)*100 as globalNewDeathPercentageByNewCases, sum(cast(total_cases as bigint)) as globalTotalCases, sum(cast(total_deaths as bigint)) as globalTotalDeaths
from project001WithAlexTheAnalyst..covidDeaths
where continent is not null
group by date
) as a
where globalNewCases > 10000
order by date desc

--joining two table
select *
from project001WithAlexTheAnalyst..covidDeaths death
join project001WithAlexTheAnalyst..covidVaccinations vaccine
on death.location = vaccine.location
and death.date = vaccine.date


--population vs vaccination 001
select death.continent, death.location, death.date, population, vaccination.new_vaccinations
from project001WithAlexTheAnalyst..covidDeaths death
join project001WithAlexTheAnalyst..covidVaccinations vaccination
	on death.date = vaccination.date
	and death.location = vaccination.location
where death.continent is not null
order by 2, 3


--population vs vaccination 002
select death.continent, death.location, death.date, population, vaccination.new_vaccinations, sum(convert(bigint,vaccination.new_vaccinations)) over (partition by death.location order by death.date) as consecutiveVaccination
from project001WithAlexTheAnalyst..covidDeaths death
join project001WithAlexTheAnalyst..covidVaccinations vaccination
	on death.date = vaccination.date
	and death.location = vaccination.location
where death.continent is not null
order by 2, 3

--using cte
with cte_populationVsVaccination (continent, location, date, population, new_vaccinations, consecutiveVaccination)
as
(
select death.continent, death.location, death.date, population, vaccination.new_vaccinations, sum(convert(bigint,vaccination.new_vaccinations)) over (partition by death.location order by death.date) as consecutiveVaccination
from project001WithAlexTheAnalyst..covidDeaths death
join project001WithAlexTheAnalyst..covidVaccinations vaccination
	on death.date = vaccination.date
	and death.location = vaccination.location
where death.continent is not null
)
select *, (consecutiveVaccination/population)*100 as vaccinationPercentage
from cte_populationVsVaccination
order by 2, 3


--using temp table
drop table if exists #tempVaccinePercetage
create table #tempVaccinePercetage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
consecutiveVaccination numeric,
)

insert into #tempVaccinePercetage
select death.continent, death.location, death.date, population, vaccination.new_vaccinations, sum(convert(bigint,vaccination.new_vaccinations)) over (partition by death.location order by death.date) as consecutiveVaccination
from project001WithAlexTheAnalyst..covidDeaths death
join project001WithAlexTheAnalyst..covidVaccinations vaccination
	on death.date = vaccination.date
	and death.location = vaccination.location
where death.continent is not null

select *, consecutiveVaccination/population*100 as vaccinationPercentage
from #tempVaccinePercetage


--creating view(s)
USE project001WithAlexTheAnalyst
GO
create or ALTER view tempVaccinePercetage as
select death.continent, death.location, death.date, population, vaccination.new_vaccinations, sum(convert(bigint,vaccination.new_vaccinations)) over (partition by death.location order by death.date) as consecutiveVaccination
from project001WithAlexTheAnalyst..covidDeaths death
join project001WithAlexTheAnalyst..covidVaccinations vaccination
	on death.date = vaccination.date
	and death.location = vaccination.location
where death.continent is not null


