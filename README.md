### Portflio Projects
This portfolio of projects consisits of 4 seperate projects. 

## Project 1: Data Cleaning in SQL.

# SQL Data Cleaning:

Data cleaning is a key component to any Data Analysis project. Some of the key reasons as to why include:

**Ensures Data Quality*:
Accuracy and Consistency: Data cleaning removes errors, duplicates, and inconsistencies, ensuring that the data is accurate and reliable for analysis.

**Prevents Errors in Analysis**:
Reliable Queries: Clean data guarantees that SQL queries return correct and meaningful results, avoiding misleading conclusions.

**Enhances Decision-Making**:
Trustworthy Insights: Clean data leads to accurate analytics, enabling informed and effective decision-making.

**Improves Database Performance**:
Efficiency: Reducing redundant and unnecessary data improves the speed and performance of SQL operations.

For our project, we are utilizing Nashville Housing. This is a large, messy Nashville hoursing dataset, consisting of the Address, Owner Name, Land Value, Land Use, Sales Price, Acreage, Buidling Value, Year Build, Bedrooms, Bathrooms and much more. Identify some of the key errors in the data was key for the analysis, as it is for any analysis. This included:

**Duplicate Data -**
Based on some of the key fields, such as ParcelID, PropertyAddress , SalePrice, SaleDate, LegalReference is was evident that there was duplicate data in the dataset. Use Common Table Expressions (CTEs) in SQL, we were able to remove any duplicats. Additionally, we were able to audit for this after, to ensure there was duplicates remaining. This is key for ensuring data accuracy. 

**NULL Data -** there were NULL values in the ProperyAddress, in instances where the ParcelAddress was duplicated. Given this, we were able to populate the Address using a previous instance of that Parcel ID.

**Parcing Property Address -** it order to analyse the location at the city and state level, this required us to split the city and state from the PropertyAddress field. Being able to analyse any data set at the city and state level is extremely beneficial and insightful. 

**Sold as Vacent -** initially, this field consisted of **Y** and **No**. In order to make this more intuitive for the user, we overwrote this to report as **Yes** and **No**.


## Project 2: **Exploratroy Data Analysis - COVID 19**

For this project, we initially explored detailed COVID 19 data in SQL. We ustilised the data to explore the fluctuations of COVID 19 over time in certain regions. 

• We use SQL to identify key trends in the data, as well as clean the data. This is to ensure that it is ready for analysis in Tableau (refer to below link). 

• As can be seen from the visualization of the results, the United Kingdom had one of the highest percentages of COVID, with just short of 35% (at the time this analysis was conducted.)

https://public.tableau.com/app/profile/james.savage4094/viz/CovidDashboard_16640149367760/Dashboard1 

Project 1:
This looks at cleaning data in SQL. The dataset being used here is the Nashville housing dataset.

Project 3:
This looks at movie correlation in python, examining the correlation of various variables with moviess gross sales. 

Project 4:
A review of the top 10 regions affected by the COVID 19 in India. The aim is to identify the primary regions to dispose vacinations. 
