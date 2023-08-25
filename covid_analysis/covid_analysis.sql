--alter table dbo.covid_dat
--alter column date date NULL

Select Location, date, total_cases, new_cases, total_deaths, Population from dbo.covid_dat
order by 1,2

-- rate of death for infection (%)
-- In 2020-06-22, Canada had its highest mortality rate at 8.2974%
select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as MortalityRate
from dbo.covid_dat
where location = 'Canada'
order by 1,2

-- total case compared to population 
-- cumulative infection rate reaches 12% of population
select Location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as TotalInfectionPercentage
from dbo.covid_dat
where location = 'Canada'
order by 1,2

-- all countries
-- statistics might be deceiving due to repeated infection by same person
select location, population, max(total_cases) as HighInfCount, max((cast(total_cases as float)/cast(population as float))*100) as PercentagePopInf
from dbo.covid_dat
where continent is not null
group by location, population
order by PercentagePopInf desc

-- mortality, all countries
select location, max(total_deaths) as MortCount
from dbo.covid_dat
where continent is not null
group by location
order by MortCount desc

-- mortality, by continent
-- data includes 'high income', 'low income' as location
select location, max(total_deaths) as MortCount
from dbo.covid_dat
where continent is null
group by location
order by MortCount desc


-- global numbers description
select date, sum(new_cases) as GlobalTotalCases, sum(new_deaths) as GlobalTotalDeaths
from dbo.covid_dat
where continent is not null
group by date
order by 1,2


-- ================= second table

--alter table dbo.vacc_dat
--alter column date date NULL

-- CTE and temp table to save info

with PopulationvsVacc (continent, location, date, population, new_vaccinations, total_vacc)
as(
select vac.continent, cov.location, cov.date, cov.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by cov.location order by cov.location, cov.date) as total_vacc
from dbo.vacc_dat as vac
join dbo.covid_dat as cov
	on cov.location = vac.location
	and cov.date = vac.date
where cov.continent is not null
)
select * , (cast(total_vacc as float)/ cast(population as float)) * 100 as PercVacc
from PopulationvsVacc
order by 2,3


-- create temp table

--get table column type
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, DATETIME_PRECISION, NUMERIC_PRECISION
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'covid_dat'


drop table if exists #PopulationvsVacc
create Table #PopulationvsVacc
(
continent nvarchar(50),
location nvarchar(50),
date date,
population numeric,
new_vaccinations numeric,
total_vacc numeric
)

insert into #PopulationvsVacc
select vac.continent, cov.location, cov.date, cov.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by cov.location order by cov.location, cov.date) as total_vacc
from dbo.vacc_dat as vac
join dbo.covid_dat as cov
	on cov.location = vac.location
	and cov.date = vac.date
where cov.continent is not null


--store data for future visualizations
create view PopulationvsVacc as
select vac.continent, cov.location, cov.date, cov.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by cov.location order by cov.location, cov.date) as total_vacc
from dbo.vacc_dat as vac
join dbo.covid_dat as cov
	on cov.location = vac.location
	and cov.date = vac.date
where cov.continent is not null

-- query from view
select * from PopulationvsVacc

