										--- WALLMART SALES DATA ---
USE Wallmart;


--- Check data ---

SELECT *
FROM features;

SELECT *
FROM stores;

SELECT *
FROM test;

SELECT *
FROM train;

--- Check to see if dates match ---

SELECT MIN(date), MAX(date)
FROM features;

SELECT MIN(date), MAX(date)
FROM test;

SELECT MIN(date), MAX(date)
FROM train;



SELECT DISTINCT t.date
FROM train t
INNER JOIN test Te ON T.Date = Te.Date; --- No match --- 

SELECT DISTINCT t.date
FROM train t
INNER JOIN features f ON t.date = f.date
ORDER BY date; --- Some matches but not all ---

-----------------------------------------------------------------------------------------------------------------------------


--- 1. Distribution of stores ---

SELECT *
FROM stores;


--- Count of each type of store --- 
SELECT Type, COUNT(*) AS Store_Count
FROM Stores
GROUP BY Type;

--- Min and Max size of stores --- 

SELECT MIN(Size) AS Min_Size, 
       MAX(Size) AS Max_Size, 
       AVG(Size) AS Avg_Size
FROM Stores;


--- Showing Q1, Median, Q3, Min, Max --- 
WITH SummaryStats AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Size) OVER() AS Q1,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Size) OVER() AS Median,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Size) OVER() AS Q3,
        MIN(Size) OVER() AS Min_Size,
        MAX(Size) OVER() AS Max_Size
    FROM Stores
)
SELECT TOP 1 * FROM SummaryStats;


--- Store count for different size ranges ---  
SELECT Size_Range, COUNT(*) AS Store_Count
FROM (
    SELECT FLOOR(Size/10000)*10000 AS Size_Range
    FROM Stores
) AS SizeRanges
GROUP BY Size_Range
ORDER BY Size_Range;

-----------------------------------------------------------------------------------------------------------------------------

--- 2. Sales analysis ---

SELECT *
FROM train;

--- Weekly sales trend ---

SELECT Date, ROUND(Weekly_Sales, 2) AS Weekly_Sales
FROM train;

--- Monthly Sales --- 

SELECT YEAR(Date) AS Year,
       MONTH(Date) AS Month,
       ROUND(SUM(Weekly_Sales), 2) AS Total_Sales
FROM Train
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY Year, Month;


--- Seasonal Index ---
WITH SalesByMonth AS (
    SELECT YEAR(Date) AS Year,
           MONTH(Date) AS Month,
           ROUND(SUM(Weekly_Sales), 2) AS Total_Sales
    FROM Train
    GROUP BY YEAR(Date), MONTH(Date)
)
SELECT Year,
       Month,
       Total_Sales,
       ROUND(Total_Sales / AVG(Total_Sales) OVER(PARTITION BY MONTH), 2) AS Seasonal_Index
FROM SalesByMonth
ORDER BY Year, Month;

--- Holiday sales analysis ---

SELECT 'Holiday' AS Week_Type,
       ROUND(AVG(Weekly_Sales), 2) AS Avg_Weekly_Sales
FROM Train
WHERE IsHoliday = 1

UNION ALL

SELECT 'Non-Holiday' AS Week_Type,
       ROUND(AVG(Weekly_Sales), 2) AS Avg_Weekly_Sales
FROM Train
WHERE IsHoliday = 0;


--- Sales by Department ---

SELECT Dept,
       ROUND(SUM(Weekly_Sales), 2) AS Total_Sales
FROM Train
GROUP BY Dept
ORDER BY Dept;

--- Sales vs Temperature ---

SELECT t.Date, t.Weekly_Sales, f.Temperature
FROM train t
JOIN features f 
				ON f.Date = t.Date;

--- Segmenting Temperature --- 

SELECT
    CASE
        WHEN f.Temperature < 50 THEN 'Cold'
        WHEN f.Temperature >= 50 AND f.Temperature < 75 THEN 'Mild'
        WHEN f.Temperature >= 75 THEN 'Hot'
        ELSE 'Unknown'
    END AS Temperature_Range,
    SUM(t.Weekly_Sales) AS Total_Sales
FROM
    features f
JOIN
    train t ON f.Date = t.Date 
GROUP BY
    CASE
        WHEN f.Temperature < 50 THEN 'Cold'
        WHEN f.Temperature >= 50 AND f.Temperature < 75 THEN 'Mild'
        WHEN f.Temperature >= 75 THEN 'Hot'
        ELSE 'Unknown'
    END;

--- Sales based on seasons --- 

SELECT
    CASE
        WHEN MONTH(Date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(Date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(Date) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(Date) IN (9, 10, 11) THEN 'Fall'
        ELSE 'Unknown'
    END AS Season,
    SUM(Weekly_Sales) AS Total_Sales
FROM
    train
GROUP BY
    CASE
        WHEN MONTH(Date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(Date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(Date) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(Date) IN (9, 10, 11) THEN 'Fall'
        ELSE 'Unknown'
    END;


--- Sales vs Fuel_Price 

SELECT t.Date, f.Fuel_Price, t.Weekly_Sales
FROM train t
JOIN features f
				ON f.Date = t.Date;

--- CPI analysis --- 

SELECT Date, CPI 
FROM features;

---------------------------------------------------------------------------------------------------------------------------

--- 3. Unemployment analysis --- 

SELECT Date, Unemployment 
FROM features;
				













