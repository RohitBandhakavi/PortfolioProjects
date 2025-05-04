-- this Is a Cleaning and more of a Exploratory Data Analysis for Tuberculosis cases around the world in the time period 2000 - 2024
-- https://www.kaggle.com/code/devraai/tuberculosis-trends-analysis-and-prediction/input

-- Creating a Staging DB

create table TB_Staging
like tuberculosis_trends_raw;

insert TB_Staging
select *
from tuberculosis_trends_raw;

select *
from tuberculosis_trends_raw;

-- Removing Duplicates if Any

Select *, 
Row_Number() Over(
Partition By `Country`,
`Region`,
`Income_Level`,
`Year`,
`TB_Cases`,
`TB_Deaths`,
`TB_Incidence_Rate`,
`TB_Mortality_Rate`,
`TB_Treatment_Success_Rate`,
`Drug_Resistant_TB_Cases`,
`HIV_CoInfected_TB_Cases`,
`Population`,
`GDP_Per_Capita`,
`Health_Expenditure_Per_Capita`,
`Urban_Population_Percentage`,
`Malnutrition_Prevalence`,
`Smoking_Prevalence`,
`TB_Doctors_Per_100K`,
`TB_Hospitals_Per_Million`,
`Access_To_Health_Services`,
`BCG_Vaccination_Coverage`,
`HIV_Testing_Coverage`
) as row_num
From TB_Staging;

-- Creating A CTE

With duplicate_CTE As
(
Select *, 
Row_Number() Over(
Partition By `Country`,
`Region`,
`Income_Level`,
`Year`,
`TB_Cases`,
`TB_Deaths`,
`TB_Incidence_Rate`,
`TB_Mortality_Rate`,
`TB_Treatment_Success_Rate`,
`Drug_Resistant_TB_Cases`,
`HIV_CoInfected_TB_Cases`,
`Population`,
`GDP_Per_Capita`,
`Health_Expenditure_Per_Capita`,
`Urban_Population_Percentage`,
`Malnutrition_Prevalence`,
`Smoking_Prevalence`,
`TB_Doctors_Per_100K`,
`TB_Hospitals_Per_Million`,
`Access_To_Health_Services`,
`BCG_Vaccination_Coverage`,
`HIV_Testing_Coverage`
) as row_num
From TB_Staging
)

Select *
From duplicate_CTE
Where row_num > 1;

-- here we created a row_num column to see if there are any duplicates and turns out that there are none.

-- Standardizing Data

select *
from TB_Staging;
Update TB_Staging
Set Country = Trim(Country);


-- Seeing all the Distinct countries and see if there is anything i can do.
Select Distinct Country
From TB_Staging
Order By 1;

-- Check for null and BLank values

Select * from TB_Staging
where TB_Hospitals_Per_Million is Null;

Alter Table TB_Staging
Drop Column Region;

Select Distinct Income_Level
From TB_Staging;


-- Exploratory data Analysis

Select * from TB_Staging
where country = 'Bangladesh' And Year = 2003 And Income_Level = 'Low';

Select Country, Year, Max(TB_Deaths)
from TB_Staging
where Country = 'India'
Group By Country, Year
Order by 2;

-- Checking the Total number of TB deaths per year 

Select Year, Sum(TB_Deaths) Deaths_per_year
From TB_Staging
Group By Year
Order By Deaths_per_year Desc;

-- As we can see, Naturally the year 2000 has the most TB cases.
-- But the Surprising thing is that the next highest outbreak year was 2016.
-- You would think the later in time we go the less these cases would be but thats not the case.

-- Corelation between income levels and the TB cases in the country

Select Country, Income_Level, Sum(TB_Deaths) Deaths_Incomelevel
from TB_Staging
Group By Country, Income_Level
order by 3 Desc;

-- As i anricipated, the low and lower middle have the most of the cases combined.
-- but the surprising thing is that High income level people also have some high number of recorded cases.
-- This can also depend on other factors which we can see when we do some prediction models in python.

-- Rolling Total of the Total Deaths per year

Select Year, Country, 
Sum(TB_Deaths) as TotalDeaths_Year
From TB_Staging
Group By Year, Country
Order by Year Asc;

With Rollong_CTE As
(
Select Year, 
Sum(TB_Deaths) as TotalDeaths_Year
From TB_Staging
Group By Year
Order by Year Asc
)

Select Year,
Sum(TotalDeaths_Year) Over (Order By Year Asc) As Rolling_Deaths_peryear
From Rollong_CTE
Order By Year Asc;

-- here we created a CTE so that we can see the rolling total of the total deaths over the world over the years and how its escalating.
-- In similar way we could also do the incidence rate or the Average of the deaths or the smoking rate too.

-- GDP with Avg Cases/ year

Select * From TB_Staging;

Create Temporary Table Avgs As
Select Country, Avg(GDP_Per_Capita) Avg_GDp, Avg(TB_Cases ) Avg_Cases
From TB_Staging
Group By Country
Order by 1;

Select * From Avgs
order By 2 Desc;

-- Here we can see that the number of cases dosent really depend on the GDP of the Country

-- Lets see the Correlation of GDP and Total cases in india now 

Select Country, Year, Avg(TB_Cases), Avg(GDP_Per_Capita)
from TB_Staging
where Country = 'india'
Group By Year 
Order By Year;
-- So its again proven that the GDP does not effect the chance of Getting TB directly.










