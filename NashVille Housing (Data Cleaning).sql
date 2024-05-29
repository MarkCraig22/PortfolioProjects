--- DATA CLEANING PROJECT ---

-- 1. Standardize Date Format

USE Housing
SELECT SaleDate
FROM NashVilleHousing2;


SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM NashVilleHousing2;

UPDATE NashvilleHousing2
SET SaleDate = CONVERT(DATE, SaleDate);

----------------------------------------------------------------------------------------------------------------------------

-- 2. Populate Property Address Data 

SELECT *
FROM NashvilleHousing2
--- WHERE PropertyAddress IS NULL
ORDER BY parcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashvillehousing2 a
JOIN Nashvillehousing2 b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashvillehousing2 a
JOIN Nashvillehousing2 b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

----------------------------------------------------------------------------------------------------------------------------

-- 3. Change Address into individual columns 


--- Property Address Column

SELECT PropertyAddress
FROM NashVilleHousing2;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS Address
FROM NashVilleHousing2;

ALTER TABLE NashvilleHousing2
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashVilleHousing2
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 )

ALTER TABLE NashvilleHousing2
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashVilleHousing2
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT *
FROM NashVilleHousing2;


--- Owner Address Column

SELECT OwnerAddress
FROM NashVilleHousing2;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM NashVilleHousing2;


ALTER TABLE NashvilleHousing2
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashVilleHousing2
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing2
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashVilleHousing2
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing2
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashVilleHousing2
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM NashVilleHousing2;

-------------------------------------------------------------------------------------------------------------------------------

-- 4. Sold and Vacant field 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashVilleHousing2
GROUP BY SoldAsVacant;

-- Column looks good, no need to change

----------------------------------------------------------------------------------------------------------------------------

-- 5. Remove Duplicates

WITH RowNumCTE AS(
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
FROM NashVilleHousing2
--ORDER BY ParcelID;
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;
-- ORDER BY PropertyAddress


-- 6. Remove unused columns 

SELECT *
FROM NashVilleHousing2;

ALTER TABLE NashVilleHousing2
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;
 