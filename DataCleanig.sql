
--Cleaning Data in SQL Queries
--****************************
SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

--Standarize Date Format
--***********************
SELECT SaleDate ,CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

--There are 2 ways to convert that date. In first way sometimes it works aknd sometimes don't
--First way
UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate=CONVERT(Date,SaleDate)

--Second way
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted,CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

--Populate Property address data
--******************************
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID 

--Getting info about this
SELECT  a.ParcelID, a.PropertyAddress as A_PropertyAddress, b.ParcelID, b.PropertyAddress as B_PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Updating the null values in propertyadress field
Update a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--Breaking out Address into Individual Columns(address,City,State)
--***************************************************************
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.NashvilleHousing

--Splitting the address into address,city

--Address
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


--City
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


SELECT PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing

--Splitting the owner address (address, city,state)
--*************************************************

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME( REPLACE(OwnerAddress,',','.'),3) as OwnerAddresss,
PARSENAME( REPLACE(OwnerAddress,',','.'),2) as City,
PARSENAME( REPLACE(OwnerAddress,',','.'),1) as  State
FROM PortfolioProject.dbo.NashvilleHousing

--Spliting the owner address,city and state

--address
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME( REPLACE(OwnerAddress,',','.'),3)

--city
ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME( REPLACE(OwnerAddress,',','.'),2)

--state
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME( REPLACE(OwnerAddress,',','.'),1)


SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing


--Change Y and N to Yes and NO in "Sold as vaccant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
 GROUP BY SoldAsVacant
 order by 2

--Changing the Y to Yes and N to No using case
--*******************************************
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END

--Remove Duplicates
--******************
WITH ROWNUMCTE AS (
SELECT *,
ROW_NUMBER() OVER  (
PARTITION BY  ParcelID,
			PropertyAddress, 
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY 
			UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM ROWNUMCTE
WHERE row_num >1
--ORDER BY PropertyAddress

--Delete unused columns from the table 
--************************************

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate