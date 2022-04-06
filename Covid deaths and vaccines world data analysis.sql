/*selectin data to work with*/
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM project_portfolio.group_cdeaths
WHERE continent IS NOT null 
ORDER BY 1,2;

/*likelyhood of dying if you get infected */
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM project_portfolio.group_cdeaths
WHERE location like '%states%'
ORDER BY 1,2;

/* highest number of deaths compared to population */
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population)*100) AS PercentPopulationInfected
FROM project_portfolio.group_cdeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

/* highest death among the countries*/
Select location, MAX(Total_deaths) as TotalDeathCount 
FROM project_portfolio.group_cdeaths
WHERE continent IS NOT null
GROUP BY location
ORDER BY TotalDeathCount DESC;

/*world numbers of cases*/
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
FROM project_portfolio.group_cdeaths
WHERE continent IS NOT null
ORDER BY 1,2;

/* total populations and total vaccinations */
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
FROM project_portfolio.group_cdeaths dea
JOIN project_portfolio.group_cvaccines vac
    On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3;

/*CTE to perform calculation on partition*/
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
FROM project_portfolio.group_cdeaths dea
JOIN project_portfolio.group_cvaccines vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS Rollingpercentage
FROM PopvsVac;

/*Creating temp table for calculation*/
CREATE TABLE percentpopulationvaccinated ( Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_vaccinations numeric, RollingPeopleVaccinated numeric )
INSERT INTO percentpopulationvaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 FROM project_portfolio.group_cdeaths dea
 JOIN project_portfolio.group_cvaccines vac
        On dea.location = vac.location
	and dea.date = vac.date

/*creating view for visualization*/
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM project_portfolio.cdeaths dea
JOIN project_portfolio.cvaccines vac
WHERE dea.continent IS NOT null;