-- query for data used for tableau

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(cast(new_deaths as float)) / sum(cast(new_cases as float)) * 100 as MortalityRate
from dbo.covid_dat
where continent is not null 
order by 1,2

select location, sum(new_deaths) as total_death
from dbo.covid_dat
where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income','Low income')
group by location
order by total_death desc

--does not account for reinfection, etc. numbers may be inflated 
select location, population, max(total_cases) as MaxInfectionCt, max(cast(total_cases as float) / population) * 100 as InfectionRate
from dbo.covid_dat
group by location, population
order by InfectionRate desc

select location, population, date, max(total_cases) as MaxInfectionCt, max(cast(total_cases as float) / population) * 100 as InfectionRate
from dbo.covid_dat
group by location, population, date
order by InfectionRate desc