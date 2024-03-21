/*

Cleaning Data in SQL Queries

*/


Select *
From Housing_DB..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
--The time in the SaleDate column does not serve any purpose, so we are gonna remove that

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date, SaleDate)

Select SaleDateConverted
From NashvilleHousing

--Or, But this did not work

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Select SaleDate
From NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
from NashvilleHousing
where PropertyAddress is Null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Housing_DB..NashvilleHousing a
Join Housing_DB..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a

Set PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
From Housing_DB..NashvilleHousing a
Join Housing_DB..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Select *
from NashvilleHousing
where PropertyAddress is Null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),         --Here It selects property address, the 1 is for the first part and then in the char index is like a search. It searches for the ',' and takes the address until the , and if we dont want the ',' to be shown so we use -1.
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))   -- here the len function shows where to end the substring that is at the end of the address column.
From Housing_DB..NashvilleHousing


Alter Table Housing_DB..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update Housing_DB..NashvilleHousing
Set PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table Housing_DB..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Housing_DB..NashvilleHousing
Set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From Housing_DB..NashvilleHousing


-- Breaking down the owner address using ParseName function. The ParseName does things backwards. So thats why we do it 3,2,1 to get it in the correct order

Select OwnerAddress
From Housing_DB..NashvilleHousing  -- So lets break this down.

Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),    -- The ParseName looks for '.' to brrakdown the rows but we have a column. So we are using the replace function.
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From Housing_DB..NashvilleHousing


Alter Table Housing_DB..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update Housing_DB..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table Housing_DB..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update Housing_DB..NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table Housing_DB..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update Housing_DB..NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From Housing_DB..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Housing_DB..NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From Housing_DB..NashvilleHousing

Update Housing_DB..NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
				   When SoldAsVacant = 'N' Then 'No'
				   Else SoldAsVacant
	               End

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

/* ROW_NUMBER function is a SQL ranking function that assigns a sequential rank number to each new record in a partition.

When the SQL Server ROW NUMBER function detects two identical values in the same partition, it assigns different rank numbers to both.

The rank number will be determined by the sequence in which they are displayed.*/

-- Here when we directly use the select and Rownumber function, we cant use where function as its not a table. so we use a CTE.

With RowNumCTE As(
Select *, ROW_NUMBER() Over(
	Partition By ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference,
	OwnerName
	Order By UniqueID
	) row_num
From Housing_DB..NashvilleHousing
)


 /*
 Select * 
 From RowNumCTE
 where row_num > 1
  */

--Deleting the Duplicates now
Delete
From RowNumCTE
where row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From Housing_DB..NashvilleHousing


ALTER TABLE Housing_DB..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

