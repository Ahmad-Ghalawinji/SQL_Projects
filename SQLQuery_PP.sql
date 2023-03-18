select *
from PP..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PP..CovidVaccinations
--order by 3,4

-- Select the used data

select location, date, total_cases, new_cases, total_deaths, population
from PP..CovidDeaths
order by 1,2

-- Looking for total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Ratio
from PP..CovidDeaths
where location like '%france%'
order by 1,2

-- Looking for the total cases vs population
-- Show the percentage of population who got Covid
select location, date, total_cases, population, (total_cases/population)*100 as Total_Cases_Precentage
from pp..CovidDeaths
where location like '%france%'
order by 1, 2, 5
-- Looking for the total deaths vs total cases
-- Show the percentage of deaths vs total cases
select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as Total_Deaths_Percentage
from pp..CovidDeaths
where location like '%france%'
order by 1, 2


-- Looking for the country with highest infection rate
select location, population, max(total_cases) as Highest_Infection_Count, max(total_cases/population)*100 as Highest_Infection_Rate
from pp..CovidDeaths
group by location, population
order by Highest_Infection_Rate desc

-- Looking for the country with highest deaths rate w.r.t population 
select Location, Population, max(cast(total_deaths as int)) as Number_of_Deaths, max(total_deaths/population)*100 as Highest_Deaths_Rate
from pp..CovidDeaths
where continent is not null
group by location, population
order by Highest_Deaths_Rate desc


-- Looking for the country with highest deaths rate w.r.t total cases 
select Location,date, Population, total_cases, max(cast(total_deaths as int)) as Number_of_Deaths, max(total_deaths/total_cases)*100 as Highest_Deaths_Rate_to_TotalCases
from pp..CovidDeaths
where continent is not null
group by location, population, total_cases, date
order by Number_of_Deaths desc


-- NOW, WE WILL DO IT BY CONTNENT

select continent, max(cast(total_deaths as int)) as Total_Deaths_Count
from pp..CovidDeaths
where continent is not null
group by continent
order by Total_Deaths_Count desc

-- Looking for the continent with highest deaths rate w.r.t population 
select continent, max(cast(total_deaths as int)) as Number_of_Deaths
from pp..CovidDeaths
where continent is not null
group by continent
order by Number_of_Deaths desc

-- MAKE IT GLOBALLY
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int)) / sum (new_cases) *100 as Deaths_Precentage
from pp..CovidDeaths
where continent is not null
order by 1,2

-- Globally per date
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int)) / sum (new_cases) *100 as Deaths_Precentage
from pp..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total population vs vaccinations
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Cumulative_Vaccinated_Number
from pp..CovidDeaths dea 
join pp..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--USE CTE
with pop_vs_vac(continent, location, date, population, new_vaccinations, Cumulative_Vaccinated_Number)
as(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Cumulative_Vaccinated_Number
from pp..CovidDeaths dea 
join pp..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (Cumulative_Vaccinated_Number/population)*100 as Percentage_Vaccinated
from pop_vs_vac


--Creating view for visualizations
create view  Percentage_Vaccinated as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Cumulative_Vaccinated_Number
from pp..CovidDeaths dea 
join pp..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3