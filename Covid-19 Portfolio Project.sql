use PortfolioProject

select *
from PortfolioProject..CovidDeaths
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4



select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by location, date

--- Total Cases Vs Total Deaths 
--- Showing the total death percentage of people infected from COVID in America 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death Percentage'
from CovidDeaths
where location = 'United States'
order by location, date

--- Total Cases Vs Total Populations 
--- Showing what percentage of total population got COVID in United States		
--- As of today 27.37 % of the total population in the States have got COVID
select location, date, population, total_cases, (total_cases/population)*100 as 'Percentage of Population Infected'
from CovidDeaths
where location = 'United States'
order by location, date

--- Countries with the highest infection rate compared to population

select location, population, max(total_cases) as 'Highest Infection Count', max((total_cases/population))*100 as 'Percentage of Max Population Infected'
from CovidDeaths
group by population, location
order by [Percentage of Max Population Infected] desc

--- Countries with the highest infection rate compared to population and dates

select location, population, date, max(total_cases) as 'Highest Infection Count', max((total_cases/population))*100 as 'Percentage of Max Population Infected'
from CovidDeaths
group by population, location, date
order by [Percentage of Max Population Infected] desc

--- Countries with highest death count per populations

select location, max(total_deaths) as 'Total deaths count'
from CovidDeaths
where continent is not null
group by location
order by [Total deaths count] desc

select * from CovidDeaths

--- continents and the highest death count per populations

select continent, max(total_deaths) as 'Total deaths count'
from CovidDeaths
where continent is not null
group by continent
order by [Total deaths count] desc

--- Total death percentage across the world 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from CovidDeaths
where continent is not null
order by 1,2

--- Total death percentage across the world per day
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from CovidDeaths
where continent is not null
group by date
order by 1,2
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Total Populations Vs Vaccinations


select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert (bigint, v.new_vaccinations)) over (partition by d.location order by d.date, d.location) as 'People Vaccinated'
from CovidDeaths d
join CovidVaccinations v
  on d.location = v.location
  and d.date = v.date
where d.continent is not null 
order by 2,3

--- By using CTE (Common Table Expressions)

With PopulationVsVaccinations (continent, location, date, population, new_vaccinations, People_Vaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert (bigint, v.new_vaccinations)) over (partition by d.location order by d.date, d.location) as People_Vaccinated
from CovidDeaths d
join CovidVaccinations v
  on d.location = v.location
  and d.date = v.date
where d.continent is not null 
)
select * , (People_Vaccinated/population)*100 as PercentPopulationVaccinated
from PopulationVsVaccinations


--- Temporary Table

Drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert (bigint, v.new_vaccinations)) over (partition by d.location order by d.date, d.location) as People_Vaccinated
from CovidDeaths d
join CovidVaccinations v
  on d.location = v.location
  and d.date = v.date
---where d.continent is not null 


select * , (People_Vaccinated/population)*100 
from #PercentPopulationVaccinated

--- Creating View for the visualizations

drop view if exists PercentPopulationVaccinated

Create view PercentPopulationVaccinated as 
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert (bigint, v.new_vaccinations)) over (partition by d.location order by d.date, d.location) as People_Vaccinated
from CovidDeaths d
join CovidVaccinations v
  on d.location = v.location
  and d.date = v.date
where d.continent is not null 

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Below are some of the queries used from the above used for Tableau Project 
---1: Total death percentage across the world 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from CovidDeaths
where continent is not null
order by 1,2

-- Just a double checking based off the data given to make sure that the data matches 
-- numbers are extremely close so we will keep them


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
---Where location like '%states%'
where location = 'World'
---Group By date
order by 1,2


---2. We take these out as they are not inluded in the above queries and want to stay consistent
---   European Union is part of Europe


select location, SUM(cast(new_deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income','Low income','Lower middle income','upper middle income')
Group by location
order by TotalDeathCount desc


---3. countries with the highest infection rate compared to population

select location, population, max(total_cases) as 'Highest Infection Count', max((total_cases/population))*100 as 'Percentage of Max Population Infected'
from CovidDeaths
group by population, location
order by [Percentage of Max Population Infected] desc


---4. Countries with the highest infection rate compared to population and dates

select location, population, date, max(total_cases) as 'Highest Infection Count', max((total_cases/population))*100 as 'Percentage of Max Population Infected'
from CovidDeaths
group by population, location, date
order by [Percentage of Max Population Infected] desc


