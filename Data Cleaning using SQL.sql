/*

Cleaning Data in SQL Queries

*/
SELECT * 
FROM [Data Cleaning].dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [Data Cleaning].dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


-- Adding New Column for Date
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM [Data Cleaning].dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


-- Checking for null address values
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Data Cleaning].dbo.NashvilleHousing AS a 
JOIN [Data Cleaning].dbo.NashvilleHousing AS b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Updating Null Address values 
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Data Cleaning].dbo.NashvilleHousing AS a 
JOIN [Data Cleaning].dbo.NashvilleHousing AS b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-----------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Column (Address, City, State)

SELECT PropertyAddress
FROM [Data Cleaning].dbo.NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID


-- Creating substring to seperate address using delimiter and position
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,  LEN(PropertyAddress)) AS City
FROM [Data Cleaning].dbo.NashvilleHousing


-- Creating new column for seperated Address
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,  LEN(PropertyAddress))


-- Checking if it worked..
SELECT *
FROM [Data Cleaning].dbo.NashvilleHousing




--OWNER ADDRESS CLEANING
 SELECT  OwnerAddress
FROM [Data Cleaning].dbo.NashvilleHousing


-- Seperating Owner address using delimiters and position
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM [Data Cleaning].dbo.NashvilleHousing


-- Creating New column for owner address
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-- Checking if it worked
SELECT  *
FROM [Data Cleaning].dbo.NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Changing Y and N to YES And NO in "Sold as Vacant" field

-- Checking values present in sola as vacant field
SELECT Distinct(SoldAsVacant) , COUNT(SoldAsVacant)
FROM [Data Cleaning].dbo.NashvilleHousing
GROUP BY SoldAsVacant
Order by 2



-- Changing Y and N Values to Yes and No
SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [Data Cleaning].dbo.NashvilleHousing


-- Updating Values in table
UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates


-- Using CTE to find Duplicate rows and deleting them
WITH RowNumCTE AS (
SELECT *, 
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
                      UniqueID
					  ) row_num


FROM [Data Cleaning].dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Deleting unused columns

SELECT *
FROM [Data Cleaning].dbo.NashvilleHousing

ALTER TABLE [Data Cleaning].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE [Data Cleaning].dbo.NashvilleHousing
DROP COLUMN SaleDate














