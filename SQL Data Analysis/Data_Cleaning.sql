-- Data Cleaning --

USE world_layoffs;

-- Checking Table --

select * from layoffs_data;


-- Creating Duplicate Table --

CREATE TABLE layoffs_staging
LIKE layoffs_data;


-- Inserting Values into the table --

Insert layoffs_staging
select * from layoffs_data;

-- Checking Table --

select * from layoffs_staging;


-- Removing duplicates --

with cte as (
select * ,row_number() over (partition by company,location,industry,total_laid_off,percentage_laid_off,date) as row_num
from layoffs_staging
)
select * from cte
where row_num >1;


CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT DEFAULT NULL,
    percentage_laid_off TEXT,
    date TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT DEFAULT NULL,
    row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


Insert layoffs_staging2
select * ,row_number() over (partition by company,location,industry,total_laid_off,percentage_laid_off,date) as row_num
from layoffs_staging;


DELETE from layoffs_staging2
where row_num >1;

select * from layoffs_staging2;

-- Standardize the data -- 

SET SQL_SAFE_UPDATES = 0;

UPDATE layoffs_staging2
SET company = TRIM(company);

SET SQL_SAFE_UPDATES = 1;

select DISTINCT(industry)
from layoffs_staging2
order by 1 asc;

SET SQL_SAFE_UPDATES = 0;

UPDATE layoffs_staging2
SET industry = 'Crypto'
where industry LIKE 'Crypto%';

SET SQL_SAFE_UPDATES = 1;

SELECT DISTINCT country,TRIM(country),TRIM(TRAILING '.' FROM country)
from layoffs_staging2
order by 1;

SET SQL_SAFE_UPDATES = 0;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
where country LIKE 'United States%';

SET SQL_SAFE_UPDATES = 1;

SELECT date,
    STR_TO_DATE(date, '%Y-%m-%d') AS formatted_date
FROM layoffs_staging2;

SET SQL_SAFE_UPDATES = 0;

UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%Y-%m-%d');

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;

-- NULL VALUES --

-- The null values in funds_raised_millions, percentage_laid_off, and total_laid_off appear to be normal --

-- Remove Column/Row if needed

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use

SET SQL_SAFE_UPDATES = 0;

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * 
FROM layoffs_staging2;
