
--Cleaning Data in SQL Queries

select * from Portfolioproject..NashvilleHousing

-- Standardize Date Format and drop the former column

select SaleDateConverted, Convert(Date,SaleDate)
from Portfolioproject..NashvilleHousing


ALTER TABLE Portfolioproject..NashvilleHousing
Add SaleDateConverted Date;

UPDATE Portfolioproject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

ALTER TABLE Portfolioproject..NashvilleHousing
DROP COLUMN SaleDate;

-- Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null
order by [UniqueID ]

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by [UniqueID ]


-- Breaking out Address into Individual Columns (Address, City, State)

--PropertyAddress

select PropertyAddress 
from Portfolioproject..NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
from Portfolioproject..NashvilleHousing

ALTER TABLE Portfolioproject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE Portfolioproject..NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Portfolioproject..NashvilleHousing
Add PropertySplitCity nvarchar(255); 

UPDATE Portfolioproject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

ALTER TABLE Portfolioproject..NashvilleHousing
DROP COLUMN PropertyAddress;

Select *
From PortfolioProject..NashvilleHousing

--Owner Address

select OwnerAddress
from Portfolioproject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE Portfolioproject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE Portfolioproject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Portfolioproject..NashvilleHousing
Add OwnerSplitCity nvarchar(255); 

UPDATE Portfolioproject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Portfolioproject..NashvilleHousing
Add OwnerSplitState nvarchar(255); 

UPDATE Portfolioproject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

ALTER TABLE Portfolioproject..NashvilleHousing
DROP COLUMN OwnerAddress;

Select *
From PortfolioProject..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject..NashvilleHousing

UPDATE Portfolioproject..NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


-- Remove Duplicates
 
with RowNumCTE as (
  select *,
    row_number() over (
      partition by ParcelID, PropertySplitAddress, PropertySplitCity, SalePrice, SaleDateConverted, LegalReference
      order by UniqueID ) as row_num
From PortfolioProject..NashvilleHousing
)
--select *
--from RowNumCTE
--where row_num > 1
--order by PropertySplitAddress, PropertySplitCity;

Delete 
from RowNumCTE
where row_num > 1


select * from Portfolioproject..NashvilleHousing


--Delete Unused Column

Alter table PortfolioProject..NashvilleHousing
drop column TaxDistrict;

select * from Portfolioproject..NashvilleHousing