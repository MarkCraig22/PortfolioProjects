											  --- Data Cleaning --- 
USE world_layoffs
SELECT *
FROM layoffs;

-- Steps:
-- 1. Remove duplicates
-- 2. Standardize data
-- 3. Blank and NUll values
-- 4. Remove columns

----------------------------------------------------------------------------------------------------------------------------

-- Create staging table 

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-----------------------------------------------------------------------------------------------------------------------------

										--- 1. Removing Duplicates ---

SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`  -- Partitioning criteria
		ORDER BY (SELECT NULL)  -- Dummy ORDER BY clause - don't need specific ordering
	) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions  -- Partitioning criteria
		ORDER BY (SELECT NULL)  -- Dummy ORDER BY clause - don't need specific ordering
	) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1; 


ALTER TABLE layoffs_staging
DROP COLUMN MyUnknownColumn; -- Deleted an extra column that I created in CSV somehow


CREATE TABLE `layoffs_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci; -- Copied create statement from clipboard

SELECT * 
FROM layoffs_staging3;

INSERT INTO layoffs_staging3
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions  -- Partitioning criteria
		ORDER BY (SELECT NULL)  -- Dummy ORDER BY clause - don't need specific ordering
	) AS row_num
FROM layoffs_staging;

SET sql_safe_updates = 0; -- Allow myself to delete 

DELETE
FROM layoffs_staging3
WHERE row_num > 1; -- Delete the duplicates

SELECT *
FROM layoffs_staging3
WHERE row_num > 1;

-----------------------------------------------------------------------------------------------------------------------------

-										--- 2. Standardizing Data ---
SELECT company, TRIM(company)
FROM layoffs_staging3;

UPDATE layoffs_staging3
SET company = TRIM(company);

SELECT *
FROM layoffs_staging3
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging3
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT(country)
FROM layoffs_staging3
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging3
WHERE country LIKE 'United State%';

UPDATE layoffs_staging3
SET country = 'United States'
WHERE country LIKE 'United State%';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging3;

UPDATE layoffs_staging3
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging3;

ALTER TABLE layoffs_staging3
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging3;

-----------------------------------------------------------------------------------------------------------------------------

										--- 3. NUll and Blank Values ---
SELECT *
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging3
SET industry = NULL 
WHERE industry = '';

SELECT *
FROM layoffs_staging3
WHERE industry IS NULL 
OR industry = '';

SELECT *
FROM layoffs_staging3
WHERE company LIKE 'Bally%';


SELECT *
FROM layoffs_staging3 t1
JOIN layoffs_staging3 t2 
	ON t1.company = t2.company
	AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging3 t1
JOIN layoffs_staging3 t2 
	ON t1.company = t2.company
SET t1.industry = t2.industry 
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

----------------------------------------------------------------------------------------------------------------------------

									--- 4. Remove Columns or Rows ---

SELECT *
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging3;

ALTER TABLE layoffs_staging3
DROP COLUMN row_num;

-----------------------------------------------------------------------------------------------------------------------------


									--- Exploratory Data Analysis ---

SELECT *
FROM layoffs_staging3;

--- Maximum Layoffs and Layoff Percentage ---

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging3;

--- Companies with 100% Layoffs Sorted by Funds Raised ---

SELECT *
FROM layoffs_staging3
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions desc;

--- Total Layoffs by Company ---

SELECT company, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company
ORDER BY 2 DESC;

--- Date Range of Layoff Data ---

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging3;

--- Annual Layoff Totals ---

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

--- Total Layoffs by Company Stage ---

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY stage
ORDER BY 2 DESC;

--- Monthly Layoff Totals ---

SELECT substring(`date`,1,7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging3
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC;

--- Rolling Total of Monthly Layoffs ---

WITH Rolling_Total AS 
(
SELECT substring(`date`,1,7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging3
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT `month`, total_off,
SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_Total;

--- Total Layoffs by Company ---

SELECT company, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company
ORDER BY 2 DESC;

--- Total Layoffs by Company and Year ---

SELECT company, YEAR(`date`) AS `year`, SUM(total_laid_off) AS total_off
FROM layoffs_staging3
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

--- Top 5 Companies by Yearly Layoffs ---

WITH company_year AS
(
SELECT company, YEAR(`date`) AS `year`, SUM(total_laid_off) AS total_off
FROM layoffs_staging3
GROUP BY company, YEAR(`date`)
), company_year_rank AS
(
SELECT *, DENSE_RANK () OVER(partition by `year` ORDER BY total_off DESC) AS ranking
FROM company_year
WHERE `year` IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;