USE [Portfolio Project]
-- a count of all the rows in the dataset
SELECT COUNT(*) FROM [Portfolio Project].[dbo].[Covid data - India]

SELECT TOP 10 * FROM [Portfolio Project].[dbo].[Covid data - India]

-- Select the minimum date that was reported. This actually reflects dates that were reported in March, but this is not accurate.
-- the raw data files that were downloaded were from October. We will therefore filter the dta later on from October 01 to Nov 20
SELECT min([Covid data - India].[Date Announced]) FROM [Covid data - India]

-- Select the max date that was reported. 
SELECT max([Covid data - India].[Date Announced]) FROM [Covid data - India]

-- check the number of observations in the range that we are concerned
-- as can be seen, the majority of the observations are for the period that we are concerned. 
-- there are however a fraction of observations from before this period. 
SELECT Distinct([Covid data - India].[Date Announced]) as Date_Reported, count(*) as no_of_records FROM [Covid data - India]
group by [Date Announced]
Order by Date_Reported;

-- a look at the distinct values for ager bracket. Per the below, we see there are 73962 NULL values
select distinct([Covid data - India].[Age Bracket]), count(*) as no_of_records from [Covid data - India]
Group by [Age Bracket]
order by [Age Bracket]

-- a look at the distinct properties of gender
-- again we have a substantial amount of NULL values. 
select distinct([Covid data - India].Gender), count(*) no_of_records from [Covid data - India]
group by Gender;

-- a look at the distinct properties of state
-- here there are only 6 NULL values. 
-- additionally, there appears to be 2 detected states that may be relater - AP & A&P. The state code will help us identify this
select distinct([Covid data - India].[Detected State]), count(*) no_of_records from [Covid data - India]
group by [Detected State] 
order by [Detected State]

-- here we can see that A&P, AP and Andhra Pradesh all have the same state code
select distinct([Detected State]) as state, [State code] as state_code 
from [Covid data - India]
order by state, [State code]

-- given the above, we will update the state per the state_code
-- Version Contol - an approach wherebye we will make back up of the raw file, prior to updating

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='covid_clean_data' and xtype='U')
SELECT * INTO covid_clean_data
FROM [Covid data - India]
WHERE covid_clean_data.[Date Announced] BETWEEN '2020-10-01' and '2020-11-20';

-- we can now update the state property where applicable
update covid_clean_data
Set [Detected State] = 'Andhra Pradesh'
WHERE covid_clean_data.[State code] = 'AP'

-- a check to ensure that our update has worked successfully. 
Select distinct([Detected State]) 
from covid_clean_data where [State code] = 'AP'
Select distinct([Detected State]), [state code] from covid_clean_data
order by [State code]

-- a check for the  data types. WE are checking for the number of cases, as this is what we are looking to test
-- Either of the following approaches can be used
-- from the below we can see that the Num_Cases is fload data type. We will look to proceed with this. 
exec sp_columns covid_clean_data
select COLUMN_NAME, DATA_TYPE 
  from information_schema.columns 
 where table_name = 'covid_clean_data'
 order by ordinal_position

 -- from the output on the Current Status, we can see that one of the observations is that the status categry is either Migrated or Other
 -- Given that we dont know much about a category of Migrations, will take this category to be other
 Select distinct([Current Status]) from covid_clean_data

 -- update current status to be Other where we have Migrated_Other
 Update covid_clean_data
 Set covid_clean_data.[Current Status] = 
 Case	
	When [Current Status] = 'Migrated_Other' Then 'Others'
	else [Current Status]
 End

 Select distinct([Current Status]) from covid_clean_data