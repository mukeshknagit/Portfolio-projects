SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolio_project.dbo.nashville a
JOIN portfolio_project.dbo.nashville b
            on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;
--update function--
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolio_project.dbo.nashville a
JOIN portfolio_project.dbo.nashville b
            on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;
--prperty address into individual columns --
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM portfolio_project.dbo.nashville 

ALTER TABLE portfolio_project.dbo.nashville
Add PropertySplitAddress Nvarchar(255);

UPDATE portfolio_project.dbo.nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1); 


ALTER TABLE portfolio_project.dbo.nashville
Add PropertyCity Nvarchar(255);

UPDATE portfolio_project.dbo.nashville
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM portfolio_project.dbo.nashville;

ALTER TABLE portfolio_project.dbo.nashville
ADD OwnerSplitAddress Nvarchar(255);

UPDATE portfolio_project.dbo.nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE portfolio_project.dbo.nashville
ADD OwnerSplitCity Nvarchar(255);

UPDATE portfolio_project.dbo.nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE portfolio_project.dbo.nashville
Add OwnerSplitState Nvarchar(255);

Update portfolio_project.dbo.nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing

--changing Y And to yes and no in the SoldAsVacant column--
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From portfolio_project.dbo.nashville
Group by SoldAsVacant
order by 2;

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Removing duplicates--
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From portfolio_project.dbo.nashville
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;

-- removing unused columns--
ALTER TABLE portfolio_project.dbo.nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
