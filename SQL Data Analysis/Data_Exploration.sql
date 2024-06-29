-- Exploratory Data Analysis -- 

USE world_layoffs;

select * from layoffs_staging2;

-- Using percentage to determine the size of these layoffs --
select MAX(total_laid_off),MAX(percentage_laid_off)
from layoffs_staging2;

-- Which businesses had one employee laid off, or nearly all of them? --
-- Upon sorting by funcs_raised_millions, the size of some of these businesses becomes apparent --
select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;


-- Companies with the most Total Layoffs --
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- From to Recent dates -- 
select min(date),max(date)
from layoffs_staging2;

-- According to Industry --
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- Countries with most Most layoffs --
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- According to Year --
select year(date), sum(total_laid_off)
from layoffs_staging2
group by year(date)
order by 1 desc;

-- According to Stage --
select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

-- Average Percentage Layoff --
select company, avg(percentage_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- Now Using CTE's

-- Ranking --
WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;


-- Rolling Total --
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;



