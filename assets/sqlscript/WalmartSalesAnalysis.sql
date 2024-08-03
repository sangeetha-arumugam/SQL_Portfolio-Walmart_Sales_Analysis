-- Creating Database for WalmartSaleAnalysis Portfolio
CREATE DATABASE IF NOT EXISTS walmartsaleportfolio;

-- Set as default Schema
USE walmartsaleportfolio;

-- Creating table for Walmart Sales Data
CREATE TABLE IF NOT EXISTS walmart_sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- Exploring Table Data
SELECT * FROM walmart_sales;
-- -----------------------------------------------------------------------------------------------------------

-- -----------------------------------------------Feature Engineering-----------------------------------------
-- ----------------------------Data Cleaning------------------------------------------------------------------
-- Getting time_of_day, day_name, and month_name and creating new column for that data and update corresponding values.
SELECT time, 
CASE
WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning" 
WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
ELSE "Evening" 
END AS time_of_day
FROM walmart_sales;

SELECT date, DAYNAME(date)
FROM walmart_sales;

SELECT date, MONTHNAME(date)
FROM walmart_sales;

ALTER TABLE walmart_sales 
ADD COLUMN time_of_day VARCHAR(30);

ALTER TABLE walmart_sales 
ADD COLUMN day_name VARCHAR(20);

ALTER TABLE walmart_sales 
ADD COLUMN month_name VARCHAR(20);

-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Update statement
UPDATE walmart_sales 
SET time_of_day = CASE
WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning" 
WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
ELSE "Evening" 
END;

UPDATE walmart_sales 
SET day_name = DAYNAME(date);

UPDATE walmart_sales 
SET month_name = MONTHNAME(date);

-- Enable safe update mode
SET SQL_SAFE_UPDATES = 1;
-- ----------------------------------------------------------------------------------------------------------

-- ---------------------------------------------Exploratory Data Analysis (EDA)------------------------------
-- -----------------Generic----------------------------------------------------------------------------------
-- How many unique cities does the data have?
SELECT DISTINCT(city)
FROM walmart_sales;

-- In which city is each branch?
SELECT DISTINCT(city), branch
FROM walmart_sales;
-- ------------------------------------------------------------------------------------------------------------

-- -------------------------------------------List of Analysis------------------------------------------------- 
-- ------1. Product Analysis-----------------------------------------------------------------------------------
SELECT * FROM walmart_sales;

-- How many unique product lines does the data have?
SELECT DISTINCT product_line, COUNT(DISTINCT product_line)
FROM walmart_sales
GROUP BY product_line;

SELECT COUNT(DISTINCT product_line)
FROM walmart_sales;

-- What is the most common payment method?
SELECT payment, COUNT(payment) AS Paymentcount
FROM walmart_sales
GROUP BY payment
ORDER BY Paymentcount DESC; -- LIMIT 1

-- What is the most selling product line?
SELECT product_line, COUNT(quantity) AS salecount
FROM walmart_sales
GROUP BY product_line
ORDER BY salecount DESC; -- Use LIMIT 3 to get the most selling product line


-- What is the total revenue by month? quantity * unit_price
SELECT month_name, SUM(total)  AS revenue
FROM walmart_sales
GROUP BY month_name
ORDER BY revenue DESC;

-- What month had the largest COGS?
SELECT month_name, SUM(cogs) as Maxcogs
FROM walmart_sales
GROUP BY month_name
ORDER BY Maxcogs DESC;

-- What product line had the largest revenue?
SELECT product_line, SUM(total) AS pro_revenue
FROM walmart_sales
GROUP BY product_line
ORDER BY pro_revenue DESC;

-- What is the city with the largest revenue?
SELECT branch, city, SUM(total) AS city_totalrevenue
FROM walmart_sales
GROUP BY city, branch
ORDER BY city_totalrevenue DESC;

-- What product line had the largest VAT(Value-added tax)? VAT = tax_pct
SELECT product_line, AVG(tax_pct) AS Avg_VAT
FROM walmart_sales
GROUP BY product_line
ORDER BY Avg_VAT DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT *, 
CASE
WHEN product_line > Avg_sale THEN "GOOD"
WHEN product_line < Avg_sale THEN "BAD"
END AS productline_rate
FROM
(SELECT product_line,COUNT(quantity) AS totsold, AVG(total) AS Avg_sale
FROM walmart_sales
GROUP BY product_line
ORDER BY Avg_sale DESC) AS T1;
-- or
SELECT product_line,
	AVG(quantity) AS avg_qnty
FROM walmart_sales
GROUP BY product_line;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM walmart_sales
GROUP BY product_line;

-- Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) AS productsold
FROM walmart_sales
GROUP BY branch
ORDER BY productsold DESC;
-- or
SELECT branch, SUM(quantity) AS productsold
FROM walmart_sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity)FROM walmart_sales);

-- What is the most common product line by gender?
SELECT product_line,gender, COUNT(gender) AS gendercount
FROM walmart_sales
GROUP BY product_line, gender
ORDER BY gendercount DESC;

-- What is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating),2) AS avgrate
FROM walmart_sales
GROUP BY product_line
ORDER BY avgrate DESC;
-- -----------------------------------------------------------------------------------------------------

-- ------------------2. Sales Analysis------------------------------------------------------------------
-- Number of sales made in each time of the day per weekday
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM walmart_sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
 customer_type,
    round (sum(total), 2) as total_revenue
FROM walmart_sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
 city,
    AVG(tax_pct) AS value_added_tax
FROM walmart_sales
GROUP BY city
ORDER BY value_added_tax DESC;

-- Which customer type pays the most in VAT?
SELECT
 customer_type,
    AVG(tax_pct) AS value_added_tax
FROM walmart_sales
GROUP BY customer_type
ORDER BY value_added_tax DESC;
-- -------------------------------------------------------------------------------------------------------

-- -----------3. Customer Analysis------------------------------------------------------------------------
-- How many unique customer types does the data have?
SELECT DISTINCT(customer_type)
FROM walmart_sales;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM walmart_sales;

-- What is the most common customer type?
SELECT
	customer_type,
	COUNT(*) as cuscount
FROM walmart_sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM walmart_sales
GROUP BY customer_type;

-- What is the gender of most of the customers?
SELECT
	gender,
    COUNT(*)
FROM walmart_sales
GROUP BY gender;

-- What is the gender distribution per branch?
SELECT branch, gender, COUNT(*)
FROM walmart_sales
GROUP BY branch, gender
ORDER BY branch;
-- Gender per branch is more or less the same hence, I don't think has an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
SELECT time_of_day, AVG(rating) AS timerating
FROM walmart_sales
GROUP BY time_of_day
ORDER BY timerating DESC;
-- Looks like time of the day does not really affect the rating, its more or less the same rating each time of the day.

-- Which time of the day do customers give most ratings per branch?
SELECT branch, time_of_day, AVG(rating) AS timerating
FROM walmart_sales
GROUP BY branch, time_of_day
ORDER BY branch DESC;
-- or
SELECT branch,
	time_of_day,
	AVG(rating) AS avg_rating
FROM walmart_sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a little more to get better ratings.

-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM walmart_sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?
SELECT
	day_name, COUNT(quantity),
	AVG(rating) AS avg_rating
FROM walmart_sales
GROUP BY day_name 
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT branch, day_name,
	COUNT(day_name) total_sales
FROM walmart_sales
GROUP BY branch, day_name
ORDER BY branch, total_sales DESC;
-- or
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM walmart_sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;
-- ----------------------------------------------------------------------------------------------

-- -----------------------------Revenue And Profit Calculations----------------------------------
-- $ COGS = unitsPrice * quantity $----------------------------------------------------------------
SELECT unit_price* quantity AS COGS
FROM walmart_sales;

-- $ VAT = 5% * COGS $
SELECT ROUND((COGS*0.5)/10,2) AS VAT
FROM(SELECT unit_price* quantity AS COGS
FROM walmart_sales)AS T1;

-- VAT  is added to the and this is what is billed to the customer.
-- $ total(gross_sales) = VAT + COGS $
SELECT VAT + COGS AS total_grass_sales
FROM
(SELECT COGS, ROUND((COGS*0.5)/10,2) AS VAT
FROM(SELECT unit_price* quantity AS COGS
FROM walmart_sales)AS T1)AS T2;

SELECT (TOTAL - COGS) AS grossincom
from(
SELECT COGS, (VAT + COGS) AS TOTAL
FROM
(SELECT COGS, ROUND((COGS*0.5)/10,2) AS VAT
FROM(SELECT unit_price* quantity AS COGS
FROM walmart_sales)AS T1)AS T2)AS T3;

-- Gross Margin is gross profit expressed in percentage of the total(gross profit/revenue)

-- $ \text{Gross Margin} = \frac{\text{gross income}}{\text{total revenue}} $

-- $ \text{Gross Margin Percentage} = \frac{\text{gross income}}{\text{total revenue}}\

-- =\frac{16.0265}{336.5565} = 0.047619\\approx 4.7619% $
SELECT (gross_income/total)*100 AS grossmargin
FROM walmart_sales;
-- or
SELECT (grossincom/TOTAL)*100 AS grossmargin
FROM( SELECT TOTAL, (TOTAL - COGS) AS grossincom
from(
SELECT COGS, (VAT + COGS) AS TOTAL
FROM
(SELECT COGS, ROUND((COGS*0.5)/10,2) AS VAT
FROM(SELECT unit_price* quantity AS COGS
FROM walmart_sales)AS T1)AS T2)AS T3)AS T4;
-- ------------ $ total(gross_sales) 
select
 sum(tax_pct+cogs) as total_grass_sales
from  walmart_sales;
-- ----------------------------------------------------------------------------------------------------------------------
