SELECT *
FROM PortfolioProject..CovidVaccinations$
order by 3,4
SELECT *
FROM PortfolioProject..CovidDeaths$
where continent is not null 


-- Selecting Data 
SELECT location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths$
order by 1,2

-- Total cases vs Total Deaths
-- Likelihood to die in India if you got Covid
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths$
WHERE location like '%INDIA%'
order by 1,2

--Total cases Vs Population
SELECT location,date,total_cases,population, (total_cases/population)*100 as Percentage_effected
From PortfolioProject..CovidDeaths$
WHERE location like '%INDIA%'
order by 1,2

-- Countries with Highest Infection rate compared to population

SELECT location,MAX(total_cases) as HighestInfected,population,Max ((total_cases/population))*100 as Percentage_effected
From PortfolioProject..CovidDeaths$
--WHERE location like '%INDIA%'
GROUP BY location,population
order by HighestInfected desc

-- Countries with Highest Death count per Population

 SELECT location,MAX(total_deaths) as Total_death_Count,population,Max ((total_deaths/population))*100 as Percentage_effected
From PortfolioProject..CovidDeaths$
--WHERE location like '%INDIA%'
GROUP BY location,population
order by Percentage_effected desc

-- Highest deaths
SELECT location , MAX(cast (total_deaths as int)) as HighestDeathsCount
From PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathsCount desc

 --Highest deaths for continent

 SELECT location , MAX(cast (total_deaths as int)) as HighestDeathsCount
From PortfolioProject..CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathsCount desc







-- Global numbers

SELECT date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as Total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100  as NewDeathPercent 
From PortfolioProject..CovidDeaths$
where continent is not null
Group BY date
order by 1,2



-- Total population vs vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingVac
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
     on dea.location= vac.location
	 and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Using CTE
with PopvsVac (Continent,location,Date,Population,New_vaccinations,RollingVac)
as
(

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingVac
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
     on dea.location= vac.location
	 and dea.date=vac.date
where dea.continent is not null

)
SELECT *,(RollingVac/Population)*100
FROm PopvsVac


-- Temp Table
Drop table if exists #PercentPopulationVac

Create TABLE #PercentPopulationVac
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingVac numeric
)

Insert into #PercentPopulationVac
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingVac
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
     on dea.location= vac.location
	 and dea.date=vac.date
where dea.continent is not null
-- order by 2,3

SELECT *,(RollingVac/Population)*100
FROm #PercentPopulationVac




-- View to store data for later visualizations
Drop View if exists PercentPopulationVacc

Create View PercentPopulationVacc as 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingVac
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
     on dea.location= vac.location
	 and dea.date=vac.date
where dea.continent is not null
-- order by 2,3
select * 
from PercentPopulationVacc


