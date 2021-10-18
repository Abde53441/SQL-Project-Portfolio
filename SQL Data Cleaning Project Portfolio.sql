--- Cleaning Data in SQL Queries

Select * 
from PortfolioProject.dbo.NashvilleHousing


----------------------------------------
---- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)


----------------------------------------------------------
---- Populate Property Address Data

Select *
from NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

-- We Will be Using Here Self Join

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


--------------------------------------------------------
------- Breaking Out Address into Individual Columns (Address, City, State)

Select *
from NashvilleHousing


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

-- Splitting Owner Address

Select 
PARSENAME(Replace(OwnerAddress, ',','.'), 3),
PARSENAME(Replace(OwnerAddress, ',','.'), 2),
PARSENAME(Replace(OwnerAddress, ',','.'), 1)
from NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'), 1)

Select *
From NashvilleHousing


-----------------------------------------------------------------------
--- Changing Y and N to Yes and No in "Sales as Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
Group By SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
Group By SoldAsVacant
Order by 2


----------------------------------------------------------
-- Removing Duplicates

Select *
from NashvilleHousing


With RowNumCTE as (
Select *,
       ROW_NUMBER () OVER (
       Partition by  ParcelID,
	                 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 Order by
					 UniqueID ) row_num
from NashvilleHousing
)
Delete
from RowNumCTE
where row_num > 1

-----------------------------------------------------
--- Deleting Unused Columns

Select *
from NashvilleHousing

Alter Table NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, SaleDate, TaxDistrict