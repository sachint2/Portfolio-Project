/*
Cleaning data in SQL queries 
*/
use PortfolioProject

Select *
from NashvilleHousing

---------------------------------------------------------------
--- Changing the date format
Select SaleDateConverted, CONVERT(date, SaleDate)
from NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)	

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)	

----------------------------------------------------------------
-- Populate Property Address data

Select PropertyAddress
from NashvilleHousing
--Where PropertyAddress is null 
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress) 
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

Update a     ------When u do a join in update statement we dont use NashvilleHousing as a update instead we need use by the alias 'a'
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress) 
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

-----------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address (PropertyAddress and OwnerAddress) into individual columns (Address, City, State)

Select PropertyAddress
from NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address --- the reason behind doing -1 is to make sure that there is no ',' in the output
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

Select * 
From NashvilleHousing

Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) --- the reason behind we chose to do from 3,2,1 and not 1,2,3 is because the outputs works backwards when used as 1,2,3
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select * 
From NashvilleHousing

---------------------------------------------------------------------------------------------
-- Change the Y and N to Yes and No in "Sold as Vacant" field 

Select Distinct(SoldAsVacant), count(SoldAsVacant) as UpdatedSoldAsVacant
from NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant desc


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 End
from NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 End

-----------------------------------------------------------------------------------------------------------------------
-- Removing Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
from NashvilleHousing
)
DELETE --- No duplicate columns now 
from RowNumCTE
where row_num > 1
order by PropertyAddress

----------------------------------------------------------------------------------------------------------------------
---- Delete Unused Columns. Always be careful doing this !!! 

Select *
from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate