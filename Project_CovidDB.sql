select *
from Covid_DB.dbo.covid_deaths
where continent is not null


alter table Covid_DB.dbo.covid_deaths alter column total_cases int 
alter table Covid_DB.dbo.covid_deaths alter column total_deaths int 


--calculating the death rate
select location, date, population, total_cases, total_deaths, (total_deaths%total_cases)*100 as DeathPercentage
from Covid_DB.dbo.covid_deaths
order by 2

-- Looking at Total Cases vs Population
select location, date, population, total_cases, (total_cases/population)*100 as Registered_Cases
from Covid_DB.dbo.covid_deaths
order by 1,2

--Country with highest infection rate vs population

select location, population, max(total_cases) as Total_Infection_Count, max((total_cases/population))*100 as Total_Infection_rate
from Covid_DB.dbo.covid_deaths
group by population, location
order by Total_Infection_rate desc

--Country with Highest Death count vs population

select location, population, max(total_deaths) as total_Death_Count, max((total_deaths/population))*100 as total_Death_rate
from Covid_DB.dbo.covid_deaths
where continent is not null
group by population, location
order by Total_Death_rate desc

--Lets look at things by Continent

select Location, max(total_deaths) as Total_Death_Count
from Covid_DB.dbo.covid_deaths
where continent is null
and location not like '%income%'	
group by Location
order by Total_Death_Count desc


--Global Numbers
select date, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, sum(new_deaths)/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
from Covid_DB.dbo.covid_deaths
where continent is not null
group by date
order by 2

alter table Covid_DB.dbo.covid_vaccinations alter column new_vaccinations bigint 

--Looking at total population and Vaccination, here we use partition by to create a rolling result of people being vaccinated

Select dea.continent, dea.location, dea.date, vac.new_vaccinations, sum( vac.new_vaccinations)
	over (partition by dea.location order by dea.date) as Rolling_people_vaccinated
from Covid_DB.dbo.covid_deaths dea
join Covid_DB.dbo.covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE to calculate the vaccination rate.

with PopvsVac( Continent, Location, Date, population, new_vaccinations, Rolling_people_vaccinated)
as(

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, sum( vac.new_vaccinations)
	over (partition by dea.location order by dea.date) as Rolling_people_vaccinated
from Covid_DB.dbo.covid_deaths dea
join Covid_DB.dbo.covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)

Select *, (Rolling_people_vaccinated/population) as vaccinationrate
from PopvsVac

--Creating Views for Later Visualization, always use the project DB while creating the view insted of master or something else.

create View PercentPeopleVaccinated as

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, sum( vac.new_vaccinations)
	over (partition by dea.location order by dea.date) as Rolling_people_vaccinated
from Covid_DB.dbo.covid_deaths dea
join Covid_DB.dbo.covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

create View DeathRate as

select location, date, population, total_cases, total_deaths, (total_deaths%total_cases)*100 as DeathPercentage
from Covid_DB.dbo.covid_deaths

create view Continents as

--Lets look at things by Continent

select Location, max(total_deaths) as Total_Death_Count
from Covid_DB.dbo.covid_deaths
where continent is null
and location not like '%income%'	
group by Location


create view GlobalNumbers as

--Global Numbers
select date, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, sum(new_deaths)/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
from Covid_DB.dbo.covid_deaths
where continent is not null
group by date



