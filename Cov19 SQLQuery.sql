
/* 
The complete Our World in Data COVID-19 dataset

Complete COVID-19 dataset is a collection of the COVID-19 data maintained by Our World in Data.
Download source: https://ourworldindata.org/coronavirus

Data fields description can be found in 
https://github.com/owid/covid-19-data/tree/master/public/data/
and
https://github.com/owid/covid-19-data/blob/master/public/data/owid-covid-codebook.csv

The dataset was split in two so to perform JOINs, etc.

The columns from original table imported to SQL Server in table [cov19deaths] are:
	   [iso_code] ,[continent],[location],[date],[population],
	   [total_cases],[new_cases], [total_deaths],[new_deaths]
	   stored in [dbo].[cov19deaths]

The columns from original table imported to SQL Server in table [cov19vaccinations] are:
	   [iso_code],[continent],[location],[date]
      ,[total_tests],[new_tests],[positive_rate]
      ,[total_vaccinations],[people_vaccinated],[people_fully_vaccinated],[new_vaccinations]
*/

/* COVID-19 Data exploration List
Data about Deaths, infections
 - Find how many and the day that each Country has the first case(s) of covid-19 
 - Find how many and the day that each Country has the first death case(s) of covid-19 
 - Find how many and the day that each Country has the MAX new case(s) of covid-19 
 - Find how many and the day that each Country has the MAX new deaths of covid-19 
 - Find Total deaths per continent
 - Highest deaths per location
 - Find World Totals  
 - Find Continents Totals  
 - Checking Coronavirus (COVID-19) Death percentage over total Population 
 - Find out the countries with the highest infection rates compared to Population 

Data about Vaccinations
 - Find out the countries with the highest infection rates compared to Population 
 - Find how many and the day that each Country had the first people vaccinated
 - Find how many and the day that each Country had the MAX new vaccinations
 - Find how many and the day that each Country had the MAX new tests
 - Highest total_vaccinations per continent
 - Highest people_fully_vaccinated per  continent
 - Highest total_vaccinations per location
 - Vaccination Progress by Country over Population (VPOP) 
 - Vaccinated People & Fully Vaccinated People Increment
 - Percentage of Population that has been Vaccinated OR Fully Vaccinated

Checking Data
- Checking the data, I found difference, data not matching between Total Vaccinations by Date and Increment New Vaccinations by Date

Greece Data Exploration
 - FindCoronavirus (COVID-19) Death percentage over total covid19 cases
and  Infection percentage over total population for Greece 
 - Find  how many and the day that Greece has the first case(s) of covid-19 
 - Find  how many and the day that Greece has the first death case(s) of covid-19 
 - Find  how many and the day that Greece has the MAX new case(s) of covid-19 
 - Find how many and the day thatGreece has the MAX new deaths of covid-19 
 - Vaccination Progress in Greece over Population (VPOP)
 - Vaccinated People & Fully Vaccinated People Increment
 - Percentage of Population that has been Vaccinated OR Fully Vaccinated 
*/ 




/* Checking the data in both tables*/
SELECT  *
  FROM [Covid19].[dbo].[cov19deaths]
  where Date = '2022/02/28'
  order by continent, location, date;

  SELECT  *
  FROM [Covid19].[dbo].[cov19vaccinations]
  where Date = '2022/02/28'
    order by continent, location, date;

	-----------------------------------------
/* The data in [location] contains information for countries (locations) and continents
   Continents exist in 'continent' column and in 'location' column.
   To collect only the countries, we must set the [continent] <> '' in SELECT query */
SELECT   [location],[continent],[date],[population],[total_cases],[new_cases]
FROM [Covid19].[dbo].[cov19deaths]
WHERE [continent] <> ''
ORDER BY continent, location, date;

/* Checking total row data per each location by continent (SELECT location)*/
SELECT  COUNT(continent) as row_data, continent, location
FROM [Covid19].[dbo].[cov19deaths]
WHERE continent <> ''
GROUP BY continent, location;
--==========================================

/* Checking total row data per each continent (SELECT location = continents)*/
SELECT  COUNT(continent) as row_data, continent, location
FROM [Covid19].[dbo].[cov19deaths]
WHERE continent = ''
GROUP BY continent, location;
----- OR-----
SELECT  COUNT(continent) as row_data, continent
FROM [Covid19].[dbo].[cov19deaths]
WHERE continent <> ''
GROUP BY continent;

/*==================================================
=====================================================              
			   Data about Deaths, infections
====================================================
====================================================*/

/* Checking Coronavirus (COVID-19) Death percentage over total covid19 cases */
SELECT [continent],[location],[date],[population],
	   [total_cases], [total_deaths], round((total_deaths/total_cases)*100,3)  as round_death_percentage 
FROM [Covid19].[dbo].[cov19deaths]
WHERE continent <> '' and total_cases is not null
ORDER BY  continent, location;

/* Checking Coronavirus (COVID-19) Infection percentage over total population */
SELECT [continent],[location],[date],[population],
	   [total_cases], [total_deaths],  round((total_cases/[population])*100,3) as round_infection_percentage
	   FROM [Covid19].[dbo].[cov19deaths]
WHERE continent <> '' and total_cases is not null
ORDER BY  continent, location;

--==========================================

/* Find  how many and the day that each Country has the first case(s) of covid-19 */
WITH added_row_number AS (
  SELECT
    [iso_code] ,[continent],[location],[date] as DATE_FIRST_COVID_CASE,[population],
	   [total_cases],[new_cases] as FIRST_COVID_CASE, [total_deaths],[new_deaths],
    ROW_NUMBER() OVER(PARTITION BY [location] ORDER BY total_cases ASC) AS row_number
  FROM [Covid19].[dbo].[cov19deaths]
  WHERE continent <> '' and total_cases > 0
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1
order by FIRST_COVID_CASE desc;
--==========================================

/* Find  how many and the day that each Country has the first death case(s) of covid-19 */
WITH added_row_number AS (
  SELECT
    [iso_code] ,[continent],[location],[date] as DATE_FIRST_COVID_DEATH,[population],
	[total_cases],[new_cases], [total_deaths]  as FIRST_COVID_DEATHS,[new_deaths],
    ROW_NUMBER() OVER(PARTITION BY [location] ORDER BY total_deaths ASC) AS row_number
  FROM [Covid19].[dbo].[cov19deaths]
  WHERE continent <> '' and total_deaths > 0
  )
SELECT
  *
FROM added_row_number
WHERE row_number = 1
order by FIRST_COVID_DEATHS desc;
--==========================================

/* Find  how many and the day that each Country has the MAX new case(s) of covid-19 */
WITH added_row_number AS (
  SELECT
    [iso_code] ,[continent],[location],[date] as DATE_MAX_COVID_NEW_CASE,[population],
	[total_cases],[new_cases] as MAX_COVID_NEW_CASE, [total_deaths] ,[new_deaths],
    ROW_NUMBER() OVER(PARTITION BY [location] ORDER BY new_cases DESC) AS row_number
  FROM [Covid19].[dbo].[cov19deaths]
  WHERE continent <> '' and new_cases > 0
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1
order by MAX_COVID_NEW_CASE desc;
--==========================================

/* Find how many and the day that each Country has the MAX new deaths of covid-19 */
WITH added_row_number AS (
  SELECT
    [iso_code] ,[continent],[location],[date] as DATE_MAX_COVID_NEW_DEATHS,[population],
	[total_cases],[new_cases], [total_deaths] ,[new_deaths] as MAX_COVID_NEW_DEATHS,
    ROW_NUMBER() OVER(PARTITION BY [location] ORDER BY new_deaths DESC) AS row_number
  FROM [Covid19].[dbo].[cov19deaths]
  WHERE continent <> '' and new_cases > 0
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1
order by MAX_COVID_NEW_DEATHS desc;
--==========================================


/* Highest deaths per  continent*/
SELECT MAX(total_deaths) as TotalDeathNum, continent
FROM [Covid19].[dbo].[cov19deaths]
WHERE continent <> ''
GROUP BY continent
ORDER BY TotalDeathNum desc;
--==========================================

/* Highest deaths per location*/
SELECT MAX(total_deaths) as TotalDeathNum, location
FROM [Covid19].[dbo].[cov19deaths]
WHERE continent <> ''
GROUP BY location
ORDER BY TotalDeathNum desc;   --- only TotalDeathNum we can retrive this way 

/* If we want to see all the record information when we had the Highest deaths 
we must use Common Table Expression (CTE).*/
WITH added_row_number AS (
  SELECT
    * ,
    ROW_NUMBER() OVER(PARTITION BY [location] ORDER BY total_deaths DESC) AS row_number
  FROM [Covid19].[dbo].[cov19deaths]
  WHERE continent <> '' and total_deaths > 0
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1;

--==========================================
/* Find World and Continents Totals  */
/* Find World Totals  */
SELECT SUM([new_cases]) as TotalCases, sum([new_deaths]) as TotalDeaths, 
	   ROUND(SUM(new_deaths )/SUM(New_Cases)*100,3) as RoundDeathPercentage
	   FROM [Covid19].[dbo].[cov19deaths]
WHERE continent <> ''
ORDER BY 1,2;
---- OR using CTE-----
WITH added_row_number AS (
  SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY continent ORDER BY total_deaths DESC) AS row_number
  FROM [Covid19].[dbo].[cov19deaths]
  WHERE continent = '' 
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1;
--==========================================

/* Find Continents Totals  */
Select continent, MAX(Total_deaths) as TotalDeathCount
FROM [Covid19].[dbo].[cov19deaths]
Where continent is not null 
Group by continent
order by TotalDeathCount desc;
---- OR using CTE-----
WITH added_row_number AS (
  SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY continent ORDER BY total_deaths DESC) AS row_number
  FROM [Covid19].[dbo].[cov19deaths]
  WHERE continent <> '' 
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1;
--===================================================

/* Checking Coronavirus (COVID-19) Death percentage over total Population */ 
WITH added_row_number AS (
  SELECT
    [iso_code] ,[continent],[location],[date] as DATE_MAX_COVID_DEATHS,[population],
	[total_cases],[new_cases], [total_deaths] as MAX_COVID_DEATHS ,[new_deaths],
    ROW_NUMBER() OVER(PARTITION BY [location] ORDER BY [total_deaths] DESC) AS row_number
  FROM [Covid19].[dbo].[cov19deaths]
  WHERE location <> '' and new_cases > 0
)
SELECT
  *, round((MAX_COVID_DEATHS/POPULATION) * 100,3) AS PercDeathsOverPoulatuon
FROM added_row_number
WHERE row_number = 1
order by PercDeathsOverPoulatuon desc;
 --==================     OR  

 Select Location, Population, MAX([total_deaths]) as MAX_COVID_DEATHS,  round(Max(([total_deaths]/population))*100,4) as PercDeathsOverPoulatuon
 FROM [Covid19].[dbo].[cov19deaths]
Group by Location, Population
order by PercDeathsOverPoulatuon desc
 --========================================
 
/* Find out the countries with the highest infection rates compared to Population */ 
Select Location, Population, MAX(total_cases) as MaxInfectionCount,  round(Max((total_cases/population))*100,4) as PopulationInfectedPercent
 FROM [Covid19].[dbo].[cov19deaths]
Group by Location, Population
order by PopulationInfectedPercent desc





/*==================================================
=====================================================              
			   Data about Vaccinations
====================================================
====================================================*/

/* Find out the countries with the highest infection rates compared to Population */ 
Select [location],[date],
    min([people_vaccinated])

 FROM  [Covid19].[dbo].[cov19vaccinations]
where [people_vaccinated]>0
Group by Location, [date]
order by Location desc


 Select Location, Population, MAX([total_deaths]) as MAX_COVID_DEATHS,  round(Max(([total_deaths]/population))*100,4) as PercDeathsOverPoulatuon
 FROM [Covid19].[dbo].[cov19deaths]
Group by Location, Population
order by PercDeathsOverPoulatuon desc


/* Find how many and the day that each Country had the first people vaccinated*/
WITH added_row_number AS (
  SELECT
    [iso_code],[continent],[location],[date] as DATE_FIRST_COVID_VACCINATED_PEOPLE,
    [total_tests],[new_tests],[positive_rate],
    [total_vaccinations],[people_vaccinated]  as FIRST_COVID_VACCINATED_PEOPLE,[people_fully_vaccinated],[new_vaccinations],
    ROW_NUMBER() OVER(PARTITION BY [location] ORDER BY people_vaccinated ASC) AS row_number
  FROM [Covid19].[dbo].[cov19vaccinations]
  WHERE continent <> '' and people_vaccinated > 0
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1;

/* Find how many and the day that each Country had the MAX new vaccinations*/
WITH added_row_number AS (
  SELECT
    [iso_code],[continent],[location],[date] as DATE_MAX_COVID_NEW_VACCINATIONS,
    [total_tests],[new_tests],[positive_rate],
    [total_vaccinations],[people_vaccinated] ,[people_fully_vaccinated],[new_vaccinations]  as MAX_COVID_NEW_VACCINATIONS,
    ROW_NUMBER() OVER(PARTITION BY [location] ORDER BY new_vaccinations DESC) AS row_number
  FROM [Covid19].[dbo].[cov19vaccinations]
  WHERE continent <> ''
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1;

/* Find how many and the day that each Country had the MAX new tests*/
WITH added_row_number AS (
  SELECT
    [iso_code],[continent],[location],[date] as DATE_MAX_COVID_NEW_TESTS,
    [total_tests],[new_tests] as MAX_COVID_NEW_TESTS,[positive_rate],
    [total_vaccinations],[people_vaccinated] ,[people_fully_vaccinated],[new_vaccinations],
    ROW_NUMBER() OVER(PARTITION BY [location] ORDER BY new_tests DESC) AS row_number
  FROM [Covid19].[dbo].[cov19vaccinations]
  WHERE continent <> '' and new_tests>0
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1;

--==========================================
/* Find World and Continents Totals  */
/* Find World Totals  */
--==========================================
/* Highest total_vaccinations per  continent*/
SELECT MAX(total_vaccinations) as TotalVaccinationsNum, continent
FROM [Covid19].[dbo].[cov19vaccinations]
WHERE continent <> ''
GROUP BY continent
ORDER BY  TotalVaccinationsNum desc;

/* Highest people_fully_vaccinated per  continent*/
SELECT MAX(people_fully_vaccinated) as TotalPeopleFullyVacNum, continent
FROM [Covid19].[dbo].[cov19vaccinations]
WHERE continent <> ''
GROUP BY continent
ORDER BY TotalPeopleFullyVacNum desc;

/* Highest total_vaccinations per location*/
SELECT MAX(total_vaccinations) as TotalVaccinationsNum, location
FROM [Covid19].[dbo].[cov19vaccinations]
WHERE continent <> ''
GROUP BY location
ORDER BY TotalVaccinationsNum desc; 


--=========================Vaccination Progress by Country over Population (VPOP)===========================
--=========================== Vaccinated People & Fully Vaccinated People Increment=========================
--- =====================  Percentage of Population that has been Vaccinated OR Fully Vaccinated 
With VPOP (Continent, Location, Date, Population, New_Vaccinations, Total_People_vaccinated, Total_People_Fully_vaccinated)
as
(
Select dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations, vc.people_vaccinated, vc.people_fully_vaccinated
 From [Covid19].[dbo].[cov19deaths] dt
Join [Covid19].[dbo].[cov19vaccinations] vc
	On dt.location = vc.location
	and dt.date = vc.date
where dt.continent <> ''
)
Select *, ROUND((Total_People_vaccinated/Population)*100,4) as Perc_Total_People_vaccinated, 
			ROUND((Total_People_Fully_vaccinated/Population)*100,4) as Perc_Total_People_Fully_vaccinated 
From VPOP;



--- ============================ Greece ===============================
----========================  Data about Deaths, infections ==============
/*  FIND Coronavirus (COVID-19) Death percentage over total covid19 cases
and  Infection percentage over total population for Greece */
SELECT [continent],[location],[date],[population],
	   [total_cases], [total_deaths], round((total_deaths/total_cases)*100,3)  as round_death_percentage 
FROM [Covid19].[dbo].[cov19deaths]
WHERE location = 'Greece' and total_cases is not null
ORDER BY  continent, location;

SELECT [continent],[location],[date],[population],
	   [total_cases], [total_deaths],  round((total_cases/[population])*100,3) as round_infection_percentage
	   FROM [Covid19].[dbo].[cov19deaths]
WHERE location = 'Greece' and total_cases is not null
ORDER BY  continent, location;

/* Find  how many and the day that Greece has the first case(s) of covid-19 */
WITH added_row_number AS (
  SELECT
    [iso_code] ,[continent],[location],[date] as DATE_FIRST_COVID_CASE,[population],
	   [total_cases],[new_cases] as FIRST_COVID_CASE, [total_deaths],[new_deaths],
    ROW_NUMBER() OVER(PARTITION BY [location] ORDER BY total_cases ASC) AS row_number
  FROM [Covid19].[dbo].[cov19deaths]
  WHERE location = 'Greece' and total_cases > 0
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1;
--==========================================

/* Find  how many and the day that Greece has the first death case(s) of covid-19 */
WITH added_row_number AS (
  SELECT
    [iso_code] ,[continent],[location],[date] as DATE_FIRST_COVID_DEATH,[population],
	[total_cases],[new_cases], [total_deaths]  as FIRST_COVID_DEATHS,[new_deaths],
    ROW_NUMBER() OVER(PARTITION BY [location] ORDER BY total_deaths ASC) AS row_number
  FROM [Covid19].[dbo].[cov19deaths]
  WHERE location = 'Greece' and total_deaths > 0
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1;
--==========================================

/* Find  how many and the day that Greece has the MAX new case(s) of covid-19 */
WITH added_row_number AS (
  SELECT
    [iso_code] ,[continent],[location],[date] as DATE_MAX_COVID_NEW_CASE,[population],
	[total_cases],[new_cases] as MAX_COVID_NEW_CASE, [total_deaths] ,[new_deaths],
    ROW_NUMBER() OVER(PARTITION BY [location] ORDER BY new_cases DESC) AS row_number
  FROM [Covid19].[dbo].[cov19deaths]
  WHERE location = 'Greece' and new_cases > 0
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1;

--==========================================

/* Find how many and the day thatGreece has the MAX new deaths of covid-19 */
WITH added_row_number AS (
  SELECT
    [iso_code] ,[continent],[location],[date] as DATE_MAX_COVID_NEW_DEATHS,[population],
	[total_cases],[new_cases], [total_deaths] ,[new_deaths] as MAX_COVID_NEW_DEATHS,
    ROW_NUMBER() OVER(PARTITION BY [location] ORDER BY new_deaths DESC) AS row_number
  FROM [Covid19].[dbo].[cov19deaths]
  WHERE location = 'Greece' and new_cases > 0
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1;


--=================================Data about Vaccinations ========================

/* Find how many and the day that Greece had the first people vaccinated*/
WITH added_row_number AS (
  SELECT
    [iso_code],[continent],[location],[date] as DATE_FIRST_COVID_VACCINATED_PEOPLE,
    [total_tests],[new_tests],[positive_rate],
    [total_vaccinations],[people_vaccinated]  as FIRST_COVID_VACCINATED_PEOPLE,[people_fully_vaccinated],[new_vaccinations],
    ROW_NUMBER() OVER(PARTITION BY [location] ORDER BY people_vaccinated ASC) AS row_number
  FROM [Covid19].[dbo].[cov19vaccinations]
  WHERE location = 'Greece' and people_vaccinated > 0
)
SELECT
  *
FROM added_row_number
WHERE row_number = 1;

/*  total_vaccinations Greece*/
SELECT MAX(total_vaccinations) as TotalVaccinationsNum, location
FROM [Covid19].[dbo].[cov19vaccinations]
WHERE location = 'Greece'
GROUP BY location;

/* Highest people_fully_vaccinated Greece*/
SELECT MAX(people_fully_vaccinated) as TotalPeopleFullyVacNum, location
FROM [Covid19].[dbo].[cov19vaccinations]
WHERE location = 'Greece'
GROUP BY location;


WITH CTE AS (
SELECT MAX(people_fully_vaccinated) as TotalPeopleFullyVacNum, location
FROM [Covid19].[dbo].[cov19vaccinations]
WHERE location = 'Greece'
GROUP BY location)
SELECT *
FROM CTE;


--=========================Vaccination Progress in Greece over Population (VPOP)===========================
--=========================== Vaccinated People & Fully Vaccinated People Increment=========================
--- =====================  Percentage of Population that has been Vaccinated OR Fully Vaccinated 
With VPOP (Continent, Location, Date, Population, New_Vaccinations, Total_People_vaccinated, Total_People_Fully_vaccinated)
as
(
Select dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations, vc.people_vaccinated, vc.people_fully_vaccinated
 From [Covid19].[dbo].[cov19deaths] dt
Join [Covid19].[dbo].[cov19vaccinations] vc
	On dt.location = vc.location
	and dt.date = vc.date
where dt.location = 'Greece' 
)
Select *, ROUND((Total_People_vaccinated/Population)*100,4) as Perc_Total_People_vaccinated, 
			ROUND((Total_People_Fully_vaccinated/Population)*100,4) as Perc_Total_People_Fully_vaccinated 
From VPOP;

/*============== Checking Data
Checking the data, I found difference, data not matching between Total Vaccinations by Date and Increment New Vaccinations by Date
*/
With VPOP (Continent, Location, Date, Population, New_Vaccinations, Total_Vaccinations, VaccinationsIncrement)
as
(
Select dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations, vc.total_vaccinations,
       SUM(vc.new_vaccinations) OVER (Partition by dt.Location Order by dt.location, dt.Date) as VaccinationsIncrement
 From [Covid19].[dbo].[cov19deaths] dt
Join [Covid19].[dbo].[cov19vaccinations] vc
	On dt.location = vc.location
	and dt.date = vc.date
--where dt.location = 'Greece' 
)
Select *,	(Total_Vaccinations - VaccinationsIncrement) as Difference_Vaccination
From VPOP;



--==================================================================================
/* Saving data by Creating Views for further use in visualizations */
--==================================================================================


---========================================== Perc_Total_People_Vaccinated ==============================
DROP VIEW if exists Perc_Total_People_Vaccinated;
--------
Create View Perc_Total_People_Vaccinated as
With VPOP (Continent, Location, Date, Population, New_Vaccinations, Total_People_vaccinated, Total_People_Fully_vaccinated)
as
(
Select dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations, vc.people_vaccinated, vc.people_fully_vaccinated
 From [Covid19].[dbo].[cov19deaths] dt
Join [Covid19].[dbo].[cov19vaccinations] vc
	On dt.location = vc.location
	and dt.date = vc.date
where dt.continent <> ''
)
Select *, ROUND((Total_People_vaccinated/Population)*100,4) as Perc_Total_People_vaccinated, 
			ROUND((Total_People_Fully_vaccinated/Population)*100,4) as Perc_Total_People_Fully_vaccinated 
From VPOP;




