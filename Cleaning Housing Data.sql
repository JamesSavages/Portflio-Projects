/*
Cleaning Data in SQL Queries
*/

USE [Portfolio Project]

SELECT * FROM [Nashville Housing]

SELECT SaleDate, CONVERT(date,SaleDate) as SalesDateConverted
FROM [Nashville Housing]

-- Standardize Date Format

ALTER TABLE [Nashville Housing]
ADD SalesDateConverted Date

Update [Nashville Housing]
SET SalesDateConverted = Convert(Date,SaleDate)

SELECT SaleDate,SalesDateConverted  FROM [Nashville Housing]

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

-- there is a lot of info, including the address. 
-- we will start by select everything.  
Select *
From [Nashville Housing]
--Where PropertyAddress is null
order by ParcelID

-- where the parcel IDs are the same, the trend is that the rows have the same Address. 
-- there are instances where we have NULL Addresses, with records that have the same ParcelID
-- so we can populate the NULL address, where the ParcelIDs are the same
-- we can do so using a self join
-- where we have a null for one record i.e. a below, we will return whats in row b address
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Nashville Housing] a 
JOIN [Nashville Housing] b
	ON a.ParcelID = b.ParcelID -- where the parcel IDs are the same
	AND a.[UniqueID ] <> b.[UniqueID ] -- but the Unique IDs are not equal
WHERE a.PropertyAddress is NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Nashville Housing] a
JOIN [Nashville Housing] b
	ON a.ParcelID = b.ParcelID -- where the parcel IDs are the same
	AND a.[UniqueID ] <> b.[UniqueID ] -- but the Unique IDs are not equal
WHERE a.PropertyAddress is NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- we will do so on the using the commar delimiter
Select PropertyAddress
From [Nashville Housing]

-- this will look to remvoe the city. We add the -1, so as to remove the ',' at the end
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
-- next we are looking to start from the comma itself (+1). We then need to specify where it will go to
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
From [Nashville Housing]


ALTER TABLE [Nashville Housing]
ADD PropertySplitAddress varchar(255)

Update [Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE [Nashville Housing]
ADD PropertySplitCity varchar(255)

Update [Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * FROM [Nashville Housing]


-- next we are going to look at the owner address. 
SELECT 
OwnerAddress
FROM [Nashville Housing]

-- this time we are going to look at doing the same, using ParceName
-- Parse name is useful with periods. WE therefore need to replace the ',' with a '.'
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Nashville Housing]


ALTER TABLE [Nashville Housing]
ADD OwnerSplitAddress varchar(255)

Update [Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitCity varchar(255)

Update [Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitState varchar(255)

Update [Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * FROM [Nashville Housing]

--------------------------------------------------------------------------------------------------------------------------
-- next we are looking at Sold as Vacent
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT 
SoldAsVacant,COUNT(SoldAsVacant)
FROM [Nashville Housing]
Group by (SoldAsVacant)
Order by 2

SELECT
	SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant  = 'N' then 'No'
		ELSE SoldAsVacant
	END
FROM [Nashville Housing]

UPDATE [Nashville Housing]
SET SoldAsVacant = 	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant  = 'N' then 'No'
		ELSE SoldAsVacant
	END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- we are going to do so using CTE's and Window Functions

SELECT * 
FROM [Nashville Housing]

-- we will use Row_Number
WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() Over(Partition by ParcelID,PropertyAddress ,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) Row_Num
FROM [Nashville Housing])
--ORDER BY ParcelID)
DELETE 
FROM RowNumCTE
WHERE Row_Num > 1

-- confirmed that there are now no duplicate values
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE [Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT * FROM [Nashville Housing]

