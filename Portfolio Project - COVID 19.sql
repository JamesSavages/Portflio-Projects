USE [Portfolio Project]
--SELECT * FROM ['COVID Vacinations$'] order by date

-- Select the data that we will be using for the COVID Deaths
SELECT 
location,date,total_cases, new_cases,total_cases,population
FROM ['COVID Deaths$'] 
ORDER by 1,2
WHERE continent is not null

-- Looking at the total cases versus the total deaths. 
-- we will then look at the % i.e. those that actually get infected
-- shows the likelyhood of dying if you contract covid in your country
SELECT 
location,date,total_cases,total_deaths,(CAST((total_deaths/total_cases)*100 AS DECIMAL(5,2))) as DeathPercentage
FROM ['COVID Deaths$'] 
WHERE location like 'Ireland' and continent is not null
ORDER by 1,2
WHERE continent is not null

-- Looking at the total cases versus the population
-- shows what percetage of population got covid
SELECT 
location,date,population,total_cases,(CAST((total_cases/population)*100 AS DECIMAL(5,2))) as DeathPercentage
FROM ['COVID Deaths$'] 
WHERE location like 'Ireland' and continent is not null
ORDER by 1,2


-- Looking at countries with highest infection rate, compared to population
SELECT 
location,population,MAX(total_cases) as HighestInfectionCount,MAX(CAST((total_cases/population)*100 AS DECIMAL(5,2))) as PercentofPopulationInfected
FROM ['COVID Deaths$'] 
--WHERE location like 'Ireland'
GROUP BY location,population
ORDER by PercentofPopulationInfected desc
WHERE continent is not null

-- Looking at countries with highest death count per population
-- need to cast total_deaths to INT
-- note - in the COVID Detah table, where Continent is NULL, the Continet gets inputted to the Location field.
-- given this, we need to use NOT NULL

SELECT 
location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ['COVID Deaths$'] 
--WHERE location like 'Ireland'
WHERE continent is not null
GROUP BY location
ORDER by TotalDeathCount desc

---- WE NOW WANT TO START BREAKING OUT PER CONTINENT--------------


-- if we wanted to break it out per continent, the stats do not look accurate when we use SELECT Continent WHERE continent is Not null
	-- however, if we want to see the true continent stats, it looks far more accurate to SELECT location WHERE Continent IS NULL
-- also, in this case there is Income date being populated, which we will need to exclude
-- review this, as he contrdicts himself on the continent piece. May be best to proceed with the following SELECT statement. 
SELECT 
location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ['COVID Deaths$'] 
--WHERE location like 'Ireland'
WHERE continent is null and location Not like '%income%'
GROUP BY location
ORDER by TotalDeathCount desc


-- Showing the continet with the highest death count
SELECT 
continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ['COVID Deaths$'] 
--WHERE location like 'Ireland'
WHERE continent is not null
GROUP BY continent
ORDER by TotalDeathCount desc


-- GLOBAL NUMBERS

-- Calculate Everything Across the entire world i.e. Global Numbers
-- we are going to SUM the new_cases as this will add up to the total new cases
-- we are doing this, as originally it was providing breakout by date. 
-- we therefore need to use aggregate functions and GROUP by date
-- the new_deaths is in Varchar so we need to cast as INT

SELECT 
date,sum(new_cases) as Total_Cases,sum(cast(new_deaths as INT)) as Total_Deaths,Cast(SUM(cast(new_deaths as INT))/sum(new_cases) as decimal(5,2)) * 100 as DeathPercentage
FROM ['COVID Deaths$'] 
WHERE continent is not null
Group by date
ORDER by 1,2

-------------------
SET ANSI_WARNINGS OFF
GO
-- looking at the total population versus vacination

-- we are looking to partition by location - reason being, it will complete the sum for one country
-- after which we want it to stop for that country. 
-- need to conver to bigint due to arithmitec error
-- we will look to compare the newly credted field RollingPeopleVacinated with the population
-- however we cannot compare these given that we just created the field.
	-- we will create a CTE
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(isnull(cast(vac.new_vaccinations as bigint),0)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated
FROM ['COVID Deaths$'] dea
Join ['COVID Vacinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3;

-- looking for Total Population vs Vaccination
-- number of columns we are selecting need to be consistent with CTE
-- using CTE
With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVacinated)
as
(
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(isnull(cast(vac.new_vaccinations as bigint),0)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated
FROM ['COVID Deaths$'] dea
Join ['COVID Vacinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
SELECT *, (RollingPeopleVacinated/population)*100 as PercentageVacinated
FROM PopvsVac

-- Trying the above using a Temp Table. 

DROP TABLE IF EXISTS #PercentPopulationVacinated
Create table #PercentPopulationVacinated

	(continent varchar(255),
	location varchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVacinated numeric)

Insert into #PercentPopulationVacinated
	SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(isnull(cast(vac.new_vaccinations as bigint),0)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated
FROM ['COVID Deaths$'] dea
Join ['COVID Vacinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

SELECT *, (RollingPeopleVacinated/population)*100 as PercentageVacinated
FROM #PercentPopulationVacinated

--- Creating a View to store data for later visualizations

Create View PercentPopulationVacinated
as
	SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(isnull(cast(vac.new_vaccinations as bigint),0)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated
FROM ['COVID Deaths$'] dea
Join ['COVID Vacinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3