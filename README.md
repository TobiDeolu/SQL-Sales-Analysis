## SQL-Sales-Analysis

## Overview
This analysis project was done to understand the sales trend in a manufacturing company. The business is more focused in understanding how each of their product categiry is doing in terms of sales. This project also includes customer's analysis as well as product details analysis. Activities such as database creation, connection, data cleaning, and exploratory data analysis were all carried out to solve this business problem.

## Project Objectives:
  - Set up sales database and connect it: The sales database to be set up in MySQL and the sales dataset received was used to update the database.
  - Data Cleaning: Extensive data cleaning process to include Checking and removing duplicates, dealing with null values, standardizing the data type, etc.
  - Exploratory Data Analysis (EDA): Perform exploratory data analysis to understand the datasets
  - Business Analysis: Analyse the dataset to solve various business problems.

## Project Structure:

### 1. Database Creation
  - "Retail_db" Database was created for this project analysis
  - The "Sales" table was created in the "Retail_sales" db
  - The dataset received was imported into the sales table
  
        CREATE DATABASE retail_db;
        USE retail_db;

        CREATE TABLE sales
        (
        transactions_id INT PRIMARY KEY,
        sale_date DATE,	
        sale_time TIME,
        customer_id INT,	
        gender VARCHAR(10),
        age INT,
        category VARCHAR(35),
        quantity INT,
        price_per_unit FLOAT,	
        cogs FLOAT,
        total_sale FLOAT
        );

### 2. Data Cleaning Processes
  -  Standardizing of data types like the Sales_date column from text to Date data type

          UPDATE sales 
          SET sale_date = STR_TO_DATE(sale_date, '%Y-%m-%d');
  
  -  Renaming the columns with the wrong column names like the transactions_id and the quantity column

          ALTER TABLE sales 
          CHANGE COLUMN transaction_id transactions_id INT;

          ALTER TABLE sales
          CHANGE COLUMN quantiy quantity INT;

  -  Checking for duplicates and removing it

          SELECT transactions_id, sale_date, sale_time, gender, age, category, quantity, price_per_unit, cogs, total_sale, count(*) AS duplicates
          FROM sales
          GROUP BY transactions_id, sale_date, sale_time, gender, age, category, quantity, price_per_unit, cogs, total_sale
          HAVING count(*) > 1;

  -  Checking for NULL/Missing values and dealing with it

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

### 3.  Data Analysis & Findings
  The following SQL queries were developed to answer specific business questions:

  #### 1.  Retrieve all columns for sales made on '2022-11-05'
          SELECT *
          FROM sales
          WHERE sale_date = "2022-11-05";
<img width="533" alt="image" src="https://github.com/user-attachments/assets/ac943d0f-8290-4230-879f-790214f2dbe3">

  #### 2.  Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
          SELECT *
          FROM sales
          WHERE category = "clothing"
	        AND quantity > 10
          AND sale_date LIKE "2022-11%";

  
  #### 3.  Calculate the total sales (total_sale) for each category.
          SELECT category, SUM(quantity * price_per_unit) AS Total_Sales
          FROM sales
          GROUP BY category
          ORDER BY SUM(quantity * price_per_unit) DESC;  
<img width="113" alt="image" src="https://github.com/user-attachments/assets/32b6ef8b-34d7-4e16-b293-8bf63423ecd1">

  
  #### 4.  Find the average age of customers who purchased items from the 'Beauty' category.
          SELECT Category, ROUND(AVG(age), 2) AS Customers_Avg_Age
          FROM sales
          WHERE category = "beauty";	
<img width="138" alt="image" src="https://github.com/user-attachments/assets/9e60b291-5c50-4860-a62d-72c0dffb3f0d">

  
  #### 5.  Find all transactions where the total_sale is greater than 1000
          SELECT transactions_id, category, SUM(total_sale) AS Sum_of_sales
          FROM sales
          WHERE total_sale > 1000
          GROUP BY transactions_id, category
          ORDER BY SUM(total_sale);
<img width="178" alt="image" src="https://github.com/user-attachments/assets/4badf21f-0cda-442f-8136-2a0d334dedde">


  #### 6.  Find the total number of transactions (transaction_id) made by each gender in each category --
          SELECT category, gender, COUNT(transactions_id) AS Transaction_Total
          FROM sales
          GROUP BY category, gender
          ORDER BY COUNT(transactions_id) DESC;
<img width="169" alt="image" src="https://github.com/user-attachments/assets/6dec546b-5cf9-4bb0-a58b-1b53d46cae1e">


  #### 7.  Calculate the average sale for each month. Find out best selling month in each year --
        WITH MonthlySales AS (
                SELECT 
                      YEAR(sale_date) AS sale_year, 
                      MONTH(sale_date) AS sale_month, 
                      ROUND(AVG(total_sale), 2) AS Avg_monthly_sales,
                      SUM(total_sale) AS Sales_in_month
              FROM sales
              GROUP BY sale_year, sale_month
              )
        SELECT ms.sale_year, ms.sale_month, ms.Avg_monthly_sales, ms.Sales_in_month,
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
<img width="331" alt="image" src="https://github.com/user-attachments/assets/6f58ab20-768b-4c4b-975f-abf17e99b057">


  #### 8.  Find the top 5 customers based on the highest total sales
          SELECT customer_id, gender, age, SUM(total_sale) AS Total_Sale
          FROM sales
          GROUP BY customer_id, gender, age
          ORDER BY SUM(total_sale) DESC
          LIMIT 5;
<img width="174" alt="image" src="https://github.com/user-attachments/assets/1277bbfb-e90e-413d-98e8-41f1cc582d0b">


  #### 9.  Find the number of unique customers who purchased items from each category
          SELECT category, COUNT(DISTINCT customer_id) AS Customer_Number
          FROM sales
          GROUP BY category;
<img width="132" alt="image" src="https://github.com/user-attachments/assets/6b3df89b-8cf6-46c7-ae86-5c68a430194c">


  #### 10.  create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17) --
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
<img width="113" alt="image" src="https://github.com/user-attachments/assets/8172bf16-4abc-4000-97b4-5a43e2dca8dd">


## Findings
  - No duplicates and null values were detected in the dataset
  - It was discovered that November 2022 has no sales that is above 10 orders in the clothing category
  - The analysis let us understand that the Electronics category has the highest total sales amount of $311,445, followed by the Clothing category ($309,995) while the          beauty category recorded the  least sales in value ($286,790)
  - It was discovered that the business recorded lots of transactions on products with price amount of $1000 and above.
  - The clothing category has more products sold in terms of units (351 & 347) to male and female customers respectively. This is followed by Electronics (343 & 335), and       Beauty (330 & 281)
  - The Bestselling month for both years 2022 and 2023 is December with $71,880 & $69,145 total sales recorded respectively
  - The clothing category has more customer count/patronage (149), with electronics at 144, and beauty at 141
  - It was discovered that the "Evening Shift" is the most productive shift of the business day the business as it recorded the highest sales in terms of number of          orders (1062) compared to the  morning shift (577), and the afternoon shift (348).

## Conclusion and Recommendations
  -  The business does not have a pricing issue as the majority of its customers can afford their product
  -  More promotional and marketing efforts should be dedicated to the electronics category as it can impact the financial book. However, attention should also be given to      the least-selling product category (beauty) to get more out of the product.
  -  December being the last month of the year happens to be the best-selling month for the business. This could be a result of so many factors such as promotional        sales, discounted sales, intensive end-of-the-year marketing campaigns, black Friday sales, etc. It is recommended that the business marketing department translate          what is been done in December into other months of the year to have a more financially stable business
  -  The evening shift is the most active business period for the business and it should be joked with. More attention should be giving to staff that will be on duty during this period as it requires more expertise and professional staff to attend to customers.
