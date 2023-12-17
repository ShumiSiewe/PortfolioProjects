/*

 Data cleaning

*/

select * from portfolioProject..NashvilleHousing

-- standardize the date format


select SaleDate,SaleDateCDonverted, convert(date,saledate)
from portfolioProject..NashvilleHousing

update portfolioProject..NashvilleHousing
set SaleDate = convert(date,saledate)

Alter table portfolioProject..NashvilleHousing
add SaleDateCDonverted Date

Update portfolioProject..NashvilleHousing
set SaleDateCDonverted = convert(date,saledate)

   

--populate property address data

select a.ParcelID,a.PropertyAddress,ISNULL(a.propertyaddress,b.PropertyAddress)
from portfolioProject..NashvilleHousing a
join portfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
--where a.ParcelID = '114 07 0A 039.00'
where a.PropertyAddress is null

update a
set propertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
from portfolioProject..NashvilleHousing a
join portfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
--where a.ParcelID = '114 07 0A 039.00'
where a.PropertyAddress is null


--Breaking out individual columns (Addresss, City,State)

select PropertyAddress
from portfolioProject..NashvilleHousing

select 
propertyaddress
,SUBSTRING(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+ 1,LEN(propertyAddress))as Address
from portfolioProject..NashvilleHousing


Alter table portfolioProject..NashvilleHousing
add propertysplitAddress Nvarchar(255)

Update portfolioProject..NashvilleHousing
set propertysplitAddress = SUBSTRING(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table portfolioProject..NashvilleHousing
add propertySplitCity Nvarchar(255)

Update portfolioProject..NashvilleHousing
set propertySplitCity = SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+ 1,LEN(propertyAddress))

select * from portfolioProject..NashvilleHousing

select OwnerAddress
from portfolioProject..NashvilleHousing

select 
OwnerAddress
,PARSENAME(Replace(owneraddress,',','.') , 3)
,PARSENAME(Replace(owneraddress,',','.') , 2)
,PARSENAME(Replace(owneraddress,',','.') , 1)

from portfolioProject..NashvilleHousing


Alter table portfolioProject..NashvilleHousing -- I will uusually run all the alter at once be4 running the updates
add ownersplitAddress Nvarchar(255)

Update portfolioProject..NashvilleHousing
set ownersplitAddress = PARSENAME(Replace(owneraddress,',','.') , 3)

Alter table portfolioProject..NashvilleHousing
add OwnerSplitCity Nvarchar(255)

Update portfolioProject..NashvilleHousing
set ownerSplitCity = PARSENAME(Replace(owneraddress,',','.') , 2)

Alter table portfolioProject..NashvilleHousing
add ownerSplitState Nvarchar(255)

Update portfolioProject..NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(owneraddress,',','.') , 1)


select *
from portfolioProject..NashvilleHousing

-- change Y and N to yes and No in "sold as vacant" field

select distinct (SoldAsVacant),count(SoldAsVacant)
from portfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
from portfolioProject..NashvilleHousing

update portfolioProject..NashvilleHousing
set SoldAsVacant =case when SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End

-- Removing Duplicates 
With RowNumCTE AS (
select *,
  ROW_NUMBER() over (
  Partition By ParcelID,PropertyAddress,SaleDate, salePrice,LegalReference

  order by UniqueID
  ) row_num

from portfolioProject..NashvilleHousing
)
--order by ParcelID
Delete
from RowNumCTE
where row_num > 1

--Deleting unused Columns

select * 
from portfolioProject..NashvilleHousing

Alter Table portfolioProject..NashvilleHousing
Drop column propertyAddress,OwnerAddress,TaxDistrict,SaleDate