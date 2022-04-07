SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths )/SUM(New_Cases)*100 as DeathPercentage
FROM project_portfolio.group_cdeaths
WHERE continent IS NOT null 
ORDER BY 1,2;

/*2*/
SELECT location, SUM(new_deaths) AS TotalDeathCount
FROM project_portfolio.group_cdeaths
WHERE continent is null 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;

/*3*/
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/population))*100 AS PercentPopulationInfected
FROM project_portfolio.group_cdeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

/*4*/

SELECT Location, Population,date, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/population))*100 AS PercentPopulationInfected
FROM project_portfolio.group_cdeaths
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC;
