

--Cleaning data in MSSQL
SELECT * FROM PortfolioProject.[dbo].[Housing$]


--Standardize data format
SELECT SaleDate, CONVERT(Date,SaleDate) Date FROM PortfolioProject.[dbo].[Housing$]

UPDATE PortfolioProject.[dbo].[Housing$]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProject.[dbo].[Housing$]
ADD SaleDateconverted Date;

UPDATE PortfolioProject.[dbo].[Housing$]
SET SaleDate = CONVERT(Date,SaleDate)


--Populate property address data to get isnull
SELECT * FROM PortfolioProject.[dbo].[Housing$]
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT I.ParcelID, II.ParcelID, I.PropertyAddress, II.PropertyAddress,
ISNULL (I.PropertyAddress, II.PropertyAddress) AS PopulateProperty
FROM PortfolioProject.[dbo].[Housing$]  I
JOIN PortfolioProject.[dbo].[Housing$] II
	ON I.ParcelID = II.ParcelID
	AND I.[UniqueID ]<> II.[UniqueID ]
WHERE I.PropertyAddress IS NULL


UPDATE I
SET PropertyAddress = ISNULL (I.PropertyAddress, II.PropertyAddress) 
FROM PortfolioProject.[dbo].[Housing$]  I
JOIN PortfolioProject.[dbo].[Housing$] II
	ON I.ParcelID = II.ParcelID
	AND I.[UniqueID ]<> II.[UniqueID ]
WHERE I.PropertyAddress IS NULL



--Split propertyaddress column into individual columns i.e address, city and state using CHARINDEX
SELECT PropertyAddress FROM PortfolioProject.[dbo].[Housing$]

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) AS Address, 
SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address 
FROM PortfolioProject.[dbo].[Housing$]


ALTER TABLE PortfolioProject.[dbo].[Housing$]
ADD SplitAddress NVARCHAR (255);

UPDATE PortfolioProject.[dbo].[Housing$]
SET SplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1)


ALTER TABLE PortfolioProject.[dbo].[Housing$]
ADD SplitCity NVARCHAR (255);

UPDATE PortfolioProject.[dbo].[Housing$]
SET SplitCity = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT * FROM PortfolioProject.[dbo].[Housing$]


--Split owner Address using PARSENAME 
SELECT OwnerAddress FROM PortfolioProject.[dbo].[Housing$]

SELECT 
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 3) Address, 
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 2) City,
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 1) Code
FROM PortfolioProject.[dbo].[Housing$]


ALTER TABLE PortfolioProject.[dbo].[Housing$]
ADD OwnSplitAddress NVARCHAR (255);

UPDATE PortfolioProject.[dbo].[Housing$]
SET OwnSplitAddress = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 3) 


ALTER TABLE PortfolioProject.[dbo].[Housing$]
ADD OwnSplitCity NVARCHAR (255);

UPDATE PortfolioProject.[dbo].[Housing$]
SET OwnSplitCity = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 2) 



--Find and replace value i.e y and n to yes and no using CASE STATEMENT
SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant) Sold_Count
FROM PortfolioProject.[dbo].[Housing$]
GROUP BY (SoldAsVacant) 
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant END
FROM PortfolioProject.[dbo].[Housing$]


UPDATE [Housing$]
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant END
FROM PortfolioProject.[dbo].[Housing$]



--Remove duplicates using CTE, ROW_NUMBER, PARTITION BY 
WITH NumCTE AS 
(
   SELECT *,
        ROW_NUMBER() OVER (PARTITION BY 
                UniqueID, 
                ParcelID, 
                PropertyAddress,
				SalePrice,
				SaleDate 
            ORDER BY 
                UniqueID, 
                ParcelID, 
                PropertyAddress,
				SalePrice,
				SaleDate 
        ) row_num
     FROM PortfolioProject.[dbo].[Housing$]
)
DELETE FROM NumCTE
WHERE row_num > 1



--Delete unused columns using DROP
SELECT * FROM PortfolioProject.[dbo].[Housing$]

ALTER TABLE PortfolioProject.[dbo].[Housing$]
DROP COLUMN PropertyAddress, TaxDistrict





