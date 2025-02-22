SELECT * FROM nashvillehousing.`nashville housing data for data cleaning`;

Select SaleDate
FROM nashvillehousing.`nashville housing data for data cleaning`;

-- Standardize Date Form
SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %d, %Y') AS ConvertedSaleDate -- Taking April 4th, 2013 to 2013-04-09.
FROM nashvillehousing.`nashville housing data for data cleaning`;

Alter table nashvillehousing.`nashville housing data for data cleaning` -- Creating ConvertedSaleDate column.
ADD ConvertedSaleDate DATE;

-- Make sure to turn off "Safe Updates." Edit > Preferences > SQL Editor > uncheck Safe Updates.
UPDATE nashvillehousing.`nashville housing data for data cleaning` -- Adding data to ConvertedSaleData column.
SET ConvertedSaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y')


-- Populate Property Address Data
SELECT *
FROM nashvillehousing.`nashville housing data for data cleaning` home1
JOIN nashvillehousing.`nashville housing data for data cleaning` home2
	ON home1.ParcelID = home2.ParcelID
	AND home1.UniqueID <> home2.UniqueID
-- Joining the tables on ParcelID being the same & UniqueID being different

SELECT home1.ParcelID, home1.PropertyAddress, home2.ParcelID, home2.PropertyAddress
FROM nashvillehousing.`nashville housing data for data cleaning` home1
JOIN nashvillehousing.`nashville housing data for data cleaning` home2
	ON home1.ParcelID = home2.ParcelID
	AND home1.UniqueID <> home2.UniqueID
WHERE home1.PropertyAddress is null

SELECT home1.ParcelID, home1.PropertyAddress AS home1_PropertyAddress, home2.ParcelID, home2.PropertyAddress AS home2_PropertyAddress,
    CASE 
        WHEN home1.PropertyAddress IS NULL THEN home2.PropertyAddress 
        ELSE NULL 
    END AS PropertyAddressComparison
FROM 
    nashvillehousing.`nashville housing data for data cleaning` home1
JOIN 
    nashvillehousing.`nashville housing data for data cleaning` home2
    ON home1.ParcelID = home2.ParcelID
    AND home1.UniqueID <> home2.UniqueID
WHERE 
    home1.PropertyAddress IS NULL;
-- Using and If ELSE statement to join tables based on PropertyAddress.
    
UPDATE nashvillehousing.`nashville housing data for data cleaning` home1
JOIN nashvillehousing.`nashville housing data for data cleaning` home2
    ON home1.ParcelID = home2.ParcelID
    AND home1.UniqueID <> home2.UniqueID
SET home1.PropertyAddress = home2.PropertyAddress
WHERE home1.PropertyAddress IS NULL;
-- UPDATE to put the join tables in the tables

-- Breaking out Property Address into individual columns
SELECT PropertyAddress
FROM nashvillehousing.`nashville housing data for data cleaning`

SELECT SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address
FROM nashvillehousing.`nashville housing data for data cleaning`;

SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,  -- Extract first part (before the first comma)
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City -- Extract second part (after the comma)
FROM nashvillehousing.`nashville housing data for data cleaning`;
-- Substring to break up Address.  

ALTER TABLE nashvillehousing.`nashville housing data for data cleaning`
ADD COLUMN Address TEXT;

ALTER TABLE nashvillehousing.`nashville housing data for data cleaning`
ADD COLUMN City TEXT;

UPDATE nashvillehousing.`nashville housing data for data cleaning`
SET Address = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1),
City = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);  
-- Alter Table to add new columns and then update the table to put the data in the columns.

-- Breaking out Owner Address into indivdual columns
SELECT OwnerAddress
FROM nashvillehousing.`nashville housing data for data cleaning`

SELECT
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS ConvertedAddress,    -- Extract first part (before the first comma)
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS ConvertedCity,  -- Extract second part (between the first and second comma)
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS ConvertedState     -- Extract third part (after the last comma)
FROM nashvillehousing.`nashville housing data for data cleaning`;

ALTER TABLE nashvillehousing.`nashville housing data for data cleaning`
	ADD COLUMN ConvertedAddress text,
    ADD COLUMN ConvertedCity text,
    ADD COLUMN ConvertedState text;
-- Add 3 new columns.
    
UPDATE nashvillehousing.`nashville housing data for data cleaning`
SET
	ConvertedAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1),
    ConvertedCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
    ConvertedState = SUBSTRING_INDEX(OwnerAddress, ',', -1); 
-- Set puts the new data in the 3 new columns. 

-- Changing Y & N to Yes & No
SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM nashvillehousing.`nashville housing data for data cleaning`
GROUP BY SoldAsVacant;
-- Count to see how many inputs are in the SoldAsVacant column.  It should only be Yes or No.

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM nashvillehousing.`nashville housing data for data cleaning`
-- Case to convert the Y to Yes and N to No.  Must include the Elses SoldAsVacant for the responses that are already inputed as Yes or No.         

UPDATE nashvillehousing.`nashville housing data for data cleaning`
SET SoldAsVacant = 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
-- Update to make the changes to the data table        
        
-- Remove Duplicates
WITH RowNumberCTE AS (
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
           ORDER BY UniqueID
       ) AS RowNumber
FROM nashvillehousing.`nashville housing data for data cleaning`)

SELECT *
FROM RowNumberCTE
WHERE RowNumber > 1
ORDER BY PropertyAddress;
-- Run this select statement with the CTE statement above.  When RowNumber>1 that means there is a duplicate and can be deleted.

WITH RowNumberCTE AS (
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
           ORDER BY UniqueID
       ) AS RowNumber
FROM nashvillehousing.`nashville housing data for data cleaning`)

DELETE FROM nashvillehousing.`nashville housing data for data cleaning`
WHERE UniqueID IN (
    SELECT UniqueID
    FROM RowNumberCTE
    WHERE RowNumber > 1
);
-- In MySQL you cannot delete duplicates from a CTE or Temp Table.  So make sure that the data you are working with is not the raw data and that you have authorizaiton to do so.


-- Delete Unused Columns
-- Again make sure that the data you are working with is not the raw data and that you have authorization to do so. 

ALTER TABLE nashvillehousing.`nashville housing data for data cleaning`
DROP COLUMN OwnerAddress;

ALTER TABLE nashvillehousing.`nashville housing data for data cleaning`
DROP COLUMN TaxDistrict;

ALTER TABLE nashvillehousing.`nashville housing data for data cleaning`
DROP COLUMN PropertyAddress;

ALTER TABLE nashvillehousing.`nashville housing data for data cleaning`
DROP COLUMN SaleDate;





