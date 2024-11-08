-- Goals:
-- 1: Delete duplicates
-- 2: Standardize data
-- 3: Explore Null values


-- 0: Creating a duplicate table from which I can edit data
CREATE TABLE layoff_edit
LIKE layoffs;

SELECT *
FROM layoff_edit;

INSERT INTO layoff_edit
SELECT *
FROM layoffs;


-- 1: Delete duplicates

WITH duplicate_row_num AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) row_num
FROM layoff_edit
)
SELECT *
FROM duplicate_row_num
WHERE row_num > 1;
-- verifying duplicates

CREATE TABLE layoff_edit2
SELECT DISTINCT * FROM layoff_edit;

WITH duplicate_row_num2 AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) row_num
FROM layoff_edit2
)
SELECT *
FROM duplicate_row_num2
WHERE row_num > 1;
-- selecting only distinct rows from layoff, ensuring duplicates are gone


-- 2. Standardizing data

-- Company, Location, and Country Updates
UPDATE layoff_edit2
SET company = TRIM(company);

SELECT company
FROM layoff_edit2
GROUP BY company
ORDER BY company ASC;

UPDATE layoff_edit2
SET company = TRIM(company);

UPDATE layoff_edit2
SET country = TRIM(TRAILING '.' FROM country);

SELECT country
FROM layoff_edit2
GROUP BY country
ORDER BY country ASC;

-- Industry updates
UPDATE layoff_edit2
SET industry = NULL
WHERE industry = '';

UPDATE layoff_edit2 t1
JOIN layoff_edit2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- 3: Exploring null values
-- (Deleting all rows with null values for both layoff values)

UPDATE layoff_edit2
SET total_laid_off = NULL
WHERE total_laid_off = '';
UPDATE layoff_edit2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '';

SELECT *
FROM layoff_edit2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE
FROM layoff_edit2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;



