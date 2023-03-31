select * 
from Portfolioproject..[Covid death]
where continent is not null
order by 3,4

--Select Data to be used for this project
Select location,date,total_cases,new_cases,total_deaths,population
from Portfolioproject..[Covid death]
where continent is not null
order by 1,2

--Determine the Total cases vs Total death in each location, calculating the percentage of the total death 
--This show the likelihood of contracting covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from Portfolioproject..[Covid death]
where continent is not null
order by 1,2

--Determine the Total cases vs population in each location, calculating the percentage of the total cases 
--This shows the percentage of the population that have got covid in each location

select Location, date, population, total_cases, (total_cases/population)*100 as percentpopulationInfected
from Portfolioproject..[Covid death]
where continent is not null
order by 1,2

--Determine countries with the highest infection rate compared to population
--Showing the highest infected cases compared to the percentage of the population infected

select Location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as percentpopulationInfected
from Portfolioproject..[Covid death]
where continent is not null
group by location, population
order by percentpopulationInfected DESC

--Determine the countries with the highest Death count
--Showing the total death count in every location 

select Location, MAX(cast(total_deaths as int)) as Totaldeathcount
from Portfolioproject..[Covid death]
where continent is not null
group by location
order by Totaldeathcount DESC

--calculate the average number of deaths per day

SELECT Location, Date, Population, AVG(cast(new_deaths as Float)) as AverageDeathperday
FROM Portfolioproject..[Covid death]
GROUP BY Location, Date, Population
ORDER BY Location, Date

--Calculates the total number of Covid deaths and Covid vaccinations administered over time. 

SELECT Distinct
    dea.date, 
    SUM(CAST(dea.new_deaths AS BIGINT)) OVER (ORDER BY dea.date) AS total_New_deaths,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (ORDER BY dea.date) AS total_New_vaccinations
FROM Portfolioproject..[Covid death] dea
JOIN Portfolioproject..[Covid Vaccination] vac 
ON dea.location = vac.location AND dea.date = vac.date
ORDER BY dea.date


--LET'S BREAK THINGS DOWN BY CONTINENT

--Determine the continent with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
from Portfolioproject..[Covid death]
where continent is not null
group by continent
order by Totaldeathcount DESC

--Another view by Location

select location, MAX(cast(total_deaths as int)) as Totaldeathcount
from Portfolioproject..[Covid death]
where continent is not null
group by location
order by Totaldeathcount DESC

--Determine the Total cases vs population in each continent, calculating the percentage of the total cases 
--This shows the percentage of the population that have got covid in each continent

select continent, population, total_cases, (total_cases/population)*100 as percentpopulationInfected
from Portfolioproject..[Covid death]
where continent is not null

--Calculates the total number of Covid deaths and Covid vaccinations administered over time in every continent

SELECT Distinct
    dea.date, dea.continent,
    SUM(CAST(dea.new_deaths AS BIGINT)) OVER (ORDER BY dea.date) AS total_New_deaths,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (ORDER BY dea.date) AS total_New_vaccinations
FROM Portfolioproject..[Covid death] dea
JOIN Portfolioproject..[Covid Vaccination] vac 
ON dea.continent = vac.continent AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.continent




--GLOBAL NUMBERS EXPLORATION

--Showing the global Total new cases and Total new death, calculating the percentage of the total new death across the world

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as NewDeathpercentage
from Portfolioproject..[Covid death]
where continent is not null
--group by date
order by 1,2

-- Joined the Covid death and covid vaccination
select * 
from Portfolioproject..[Covid death] dea
	join Portfolioproject..[Covid Vaccination] vac
		on dea.location = vac.location
		and dea.date = vac.date

--Looking at the Total population vs Vaccination 

SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations, 
       SUM(CAST(vac.new_vaccinations AS BIGINT)) 
           OVER (PARTITION BY dea.location 
                 ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM Portfolioproject..[Covid death] dea
JOIN Portfolioproject..[Covid Vaccination] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
    AND vac.new_vaccinations IS NOT NULL
ORDER BY dea.location, dea.date;



--USE CTE

WITH PopvsVac AS 
(
    SELECT dea.continent, 
           dea.location, 
           dea.date, 
           dea.population, 
           vac.new_vaccinations, 
           SUM(CAST(vac.new_vaccinations AS BIGINT)) 
               OVER (PARTITION BY dea.location 
                     ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
    FROM Portfolioproject..[Covid death] dea
    JOIN Portfolioproject..[Covid Vaccination] vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
        AND vac.new_vaccinations IS NOT NULL
)
Select *, (Rollingpeoplevaccinated/population)*100 as Percentpopulationvaccinated
FROM PopvsVac



--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations, 
       SUM(CAST(vac.new_vaccinations AS BIGINT)) 
           OVER (PARTITION BY dea.location 
                 ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM Portfolioproject..[Covid death] dea
JOIN Portfolioproject..[Covid Vaccination] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
Select *, (Rollingpeoplevaccinated/population)*100 as Percentpopulationvaccinated
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations 

DROP VIEW if exists PercentagePopulationVaccinated;
CREATE VIEW PercentagePopulationVaccinated AS 
SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations, 
       SUM(CAST(vac.new_vaccinations AS BIGINT)) 
           OVER (PARTITION BY dea.location 
                 ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM Portfolioproject..[Covid death] dea
JOIN Portfolioproject..[Covid Vaccination] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
Select * from PercentagePopulationVaccinated

