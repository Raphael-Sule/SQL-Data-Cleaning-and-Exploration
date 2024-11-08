-- Calculating hypothetical number of workers per company
ALTER TABLE layoff_edit2 
ADD number_of_workers INT;

UPDATE layoff_edit2
SET number_of_workers = (total_laid_off * (100/percentage_laid_off))
WHERE percentage_laid_off IS NOT NULL AND
TOTAL_LAID_OFF IS NOT NULL; 


-- Total layoffs by Country
SELECT country, SUM(total_laid_off) total_layoffs
FROM layoff_edit2
GROUP BY country
ORDER BY total_layoffs DESC;


-- Each company's share of total layoffs
WITH cte as
(
SELECT company,
total_laid_off,
SUM(total_laid_off) OVER() all_layoffs
FROM layoff_edit2
GROUP BY company, total_laid_off
)
SELECT t1.*,
(t2.total_laid_off/t2.all_layoffs) * 100 share_of_layoffs
FROM layoff_edit2 t1
JOIN cte t2
	ON t1.company = t2.company AND
    t1.total_laid_off = t2.total_laid_off
ORDER BY share_of_layoffs DESC;

-- Layoffs by month
UPDATE layoff_edit2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT SUBSTRING(`date`,1,7) `month`, SUM(total_laid_off)
FROM layoff_edit2
GROUP BY `month`;

-- Stored Procedures
CALL top_n_company_layoffs_by_country_and_industry('United States','HR','6');
CALL top_n_company_layoffs_by_country('United States','6');
CALL top_n_company_layoffs_by_industry('HR', 6);