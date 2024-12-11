CREATE DATABASE retail_db;
USE retail_db;

SELECT *
FROM sales;

-- Standadizing the data types --
-- Changing Sales Date, sales time to Date and time format from text --

-- Convert Sale date from text to datetime
UPDATE sales 
SET sale_date = STR_TO_DATE(sale_date, '%Y-%m-%d');

-- Checking if the sale date has been changed from text to date --
SELECT sale_date, YEAR(sale_date) AS sale_year 
FROM sales 
LIMIT 10;

-- Renaming the transactions id column --
ALTER TABLE sales 
CHANGE COLUMN transaction_id transactions_id INT;

ALTER TABLE sales
CHANGE COLUMN quantiy quantity INT;

-- Checking for duplicates --
SELECT transactions_id, sale_date, sale_time, gender, age, category, quantity, 
	   price_per_unit, cogs, total_sale, count(*) AS duplicates
FROM sales
GROUP BY transactions_id, sale_date, sale_time, gender, age, category, quantity, 
	   price_per_unit, cogs, total_sale
HAVING count(*) > 1;
-- Finding shows there are no duplicates value in the dataset --

SELECT *
FROM sales;

-- Removing NULL data --
SELECT * 
FROM sales
WHERE
	transactions_id IS NULL
	OR 
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR 
    customer_id IS NULL
    OR 
    gender IS NULL
    OR 
    age IS NULL
    OR 
    category IS NULL
    OR 
    quantity IS NULL
    OR 
    price_per_unit IS NULL
    OR 
    cogs IS NULL
    OR 
    total_sale IS NULL;
    -- Finding shows there is no NULL values in the data set --
    -- Delete NULL values incase we could not find it --
    DELETE FROM sales
    WHERE
	transactions_id IS NULL
	OR 
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR 
    customer_id IS NULL
    OR 
    gender IS NULL
    OR 
    age IS NULL
    OR 
    category IS NULL
    OR 
    quantity IS NULL
    OR 
    price_per_unit IS NULL
    OR 
    cogs IS NULL
    OR 
    total_sale IS NULL;
    
    -- Data Analysis & Business Key Problems & Answers -- 
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

-- Q1: Retrieve all columns for sales made on '2022-11-05' --
SELECT *
FROM sales
WHERE sale_date = "2022-11-05";

-- Q2: Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022 --
SELECT *
FROM sales
WHERE category = "clothing"
	AND quantity > 10
    AND sale_date LIKE "2022-11%";
    
-- Q3: Calculate the total sales (total_sale) for each category. --
SELECT category, SUM(quantity * price_per_unit) AS Total_Sales
FROM sales
GROUP BY category
ORDER BY SUM(quantity * price_per_unit) DESC;   

-- Q4: Find the average age of customers who purchased items from the 'Beauty' category. --
SELECT Category, ROUND(AVG(age), 2) AS Customers_Avg_Age
FROM sales
WHERE category = "beauty";	

-- Q5: Find all transactions where the total_sale is greater than 1000 --
SELECT transactions_id, category, SUM(total_sale) AS Sum_of_sales
FROM sales
WHERE total_sale > 1000
GROUP BY transactions_id, category
ORDER BY SUM(total_sale);

-- Q6: Find the total number of transactions (transaction_id) made by each gender in each category --
SELECT category, gender, COUNT(transactions_id) AS Transaction_Total
FROM sales
GROUP BY category, gender
ORDER BY COUNT(transactions_id) DESC;

-- Q7: Calculate the average sale for each month. Find out best selling month in each year --
WITH MonthlySales AS (
    SELECT 
        YEAR(sale_date) AS sale_year, 
        MONTH(sale_date) AS sale_month, 
        ROUND(AVG(total_sale), 2) AS Avg_monthly_sales,
        SUM(total_sale) AS Sales_in_month
    FROM sales
    GROUP BY sale_year, sale_month
)
SELECT 
    ms.sale_year, 
    ms.sale_month, 
    ms.Avg_monthly_sales, 
    ms.Sales_in_month,
    CASE 
        WHEN ms.Sales_in_month = (
            SELECT MAX(Sales_in_month) 
            FROM MonthlySales 
            WHERE sale_year = ms.sale_year
        ) THEN 'Best Selling Month'
        ELSE 'Others'
    END AS month_category
FROM MonthlySales AS ms
ORDER BY ms.sale_year, ms.sale_month;

-- Q8: Find the top 5 customers based on the highest total sales --
SELECT customer_id, gender, age, SUM(total_sale) AS Total_Sale
FROM sales
GROUP BY customer_id, gender, age
ORDER BY SUM(total_sale) DESC
LIMIT 5;

-- Q9: Find the number of unique customers who purchased items from each category --
SELECT category, COUNT(DISTINCT customer_id) AS Customer_Number
FROM sales
GROUP BY category;

-- Q10: create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17) --
WITH hourly_sale AS
	(
    SELECT *,
		CASE 
        WHEN EXTRACT(HOUR FROM sale_time) <=12 THEN "Morning"
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN "Afternoon"
        WHEN EXTRACT(HOUR FROM sale_time) >17 THEN "Evening"
        ELSE "Not Available" 
	END AS Shift
    FROM sales
    )
SELECT Shift, COUNT(*) AS Total_Orders
FROM hourly_sale
GROUP BY Shift;

-- End Project --

        