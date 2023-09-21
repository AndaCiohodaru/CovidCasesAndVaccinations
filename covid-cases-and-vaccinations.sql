/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT *
FROM PortfolioProject..['COVID DEATHS ]
where continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject..['COVID VACCINATIONS ]
ORDER BY 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['COVID DEATHS ]
where continent is not null
order by 1,2



--Looking at the Total cases vs Total deaths
-- Shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
From PortfolioProject..['COVID DEATHS ]
Where location like '%romania%'
and  continent is not null
order by 1,2

-- Looking at the Total cases vs Population
--Shows what percentge of population infected with Covid

Select location, date,population, total_cases,(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PopulationwithCovidpercentage
From PortfolioProject..['COVID DEATHS ]
--where location like '%romania%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location,population, max(total_cases)as HighestInfectionCount, max(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentofPopulationInfected
From PortfolioProject..['COVID DEATHS ]
where continent is not null
--Where location like '%romania%'
group by population,location
order by PercentofPopulationInfected desc

--Showing the countries with the highest Death Count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['COVID DEATHS ]
where continent is not null
--Where location like '%romania%'
group by location
order by TotalDeathCount desc

--Breaking things down by continent
--Showing continents with the highest death count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['COVID DEATHS ]
--Where location like '%romania%'
where continent != ''
group by location
order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['COVID DEATHS ]
--Where location like '%romania%'
where continent != ''
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS 
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..['COVID DEATHS ]
where continent !=''
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations
--Shows Percentage of Population that has reived at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['COVID DEATHS ] dea
Join PortfolioProject..['COVID VACCINATIONS ] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition by in previous query

with PopvsVac(Continent, Location, Date, Population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS float )) OVER (PARTITION BY dea.Location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..['COVID DEATHS ] dea
Join PortfolioProject..['COVID VACCINATIONS ] vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent !=''
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac



--Using Temp Table to perform Calculation on Partition by in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations float,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS float )) OVER (PARTITION BY dea.Location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..['COVID DEATHS ] dea
Join PortfolioProject..['COVID VACCINATIONS ] vac
     on dea.location=vac.location
     and dea.date=vac.date
--where dea.continent !=''
--order by 1,2,3

Select *,(RollingPeopleVaccinated/Population)*100
From  #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS float )) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..['COVID DEATHS ] dea
Join PortfolioProject..['COVID VACCINATIONS ] vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent !=''
--order by 1,2,3

