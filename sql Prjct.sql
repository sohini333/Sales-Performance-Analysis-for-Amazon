-- Data Wrangling:
SELECT * FROM sql_projectdb.amazon;
use sql_projectdb;
SELECT * FROM amazon
WHERE `Invoice ID` IS NULL 
    OR `Branch` IS NULL 
    OR `City` IS NULL 
    OR `Customer type` IS NULL 
    OR `Gender` IS NULL 
    OR `Product line` IS NULL 
    OR `Unit price` IS NULL 
    OR `Quantity` IS NULL 
    OR `Tax 5%` IS NULL 
    OR `Total` IS NULL 
    OR `Date` IS NULL 
    OR `Time` IS NULL 
    OR `Payment` IS NULL 
    OR `cogs` IS NULL 
    OR `gross margin percentage` IS NULL 
    OR `gross income` IS NULL 
    OR `Rating` IS NULL;
    
    
    -- Feature Engineering: This will help us generate some new columns from existing ones.
    
    alter table amazon
    rename column `Tax 5%` to VAT;
    
    alter table amazon
    add column timeofday varchar(30);
    
    update amazon
    set timeofday =
    CASE 
        WHEN HOUR(Time) >= 0 AND HOUR(Time) < 12 THEN 'Morning'
        WHEN HOUR(Time) >= 12 AND HOUR(Time) < 18 THEN 'Afternoon'
        ELSE 'Evening'
    END;
    
    
    
    alter table amazon
    add column dayname varchar(30);
    
    update amazon
    set dayname = 
		CASE 
        WHEN DAYOFWEEK(Date) = 1 THEN 'Sun'
        WHEN DAYOFWEEK(Date) = 2 THEN 'Mon'
        WHEN DAYOFWEEK(Date) = 3 THEN 'Tue'
        WHEN DAYOFWEEK(Date) = 4 THEN 'Wed'
        WHEN DAYOFWEEK(Date) = 5 THEN 'Thur'
        WHEN DAYOFWEEK(Date) = 6 THEN 'Fri'
        WHEN DAYOFWEEK(Date) = 7 THEN 'SAT'
    END;
    
    select monthname(Date) from amazon;
    
    alter table amazon
    rename column monthname to mnth_name;
    
    update amazon
    set mnth_name =  monthname(Date);
    
    /* Exploratory Data Analysis (EDA) */
    
 -- 1. What is the count of distinct cities in the dataset?
    select count(distinct city)as city_count from amazon;
    
 -- 2. For each branch, what is the corresponding city?
		select branch,city 
		from amazon 
		group by branch,city
		order by branch;
 
 -- 3. What is the count of distinct product lines in the dataset?
 select count(distinct `Product line`) as total_productLine from amazon;
 
 -- 4. Which payment method occurs most frequently?
	select Payment,count(*)as frequency from amazon
    group by Payment
    order by frequency desc
    limit 1;
    
 -- 5. Which product line has the highest sales?
 select `Product line`, sum(Quantity) as product_sold
 from amazon
 group by `Product line`
 order by product_sold desc
 limit 1;
 
 -- 6.How much revenue is generated each month?
 select  monthname(date) as month_name, sum(total) as revenue from amazon
 group by month_name
 order by revenue desc ;
 
 -- 7. In which month did the cost of goods sold reach its peak?
 select  monthname(date) as month_name, sum(cogs) as total_cost from amazon
 group by month_name
 order by total_cost desc
 limit 1;
 
 -- 8. Which product line generated the highest revenue?
	select `Product line`, sum(total) as revenue from amazon
    group by `Product line`
    order by revenue desc
    limit 1;
    
 -- 9. In which city was the highest revenue recorded?
   select city, sum(total) as revenue from amazon
   group by city
   order by revenue desc;
   
-- 10. Which product line incurred the highest Value Added Tax?
	select `Product line`, sum(VAT) as tax from amazon
    group by `Product line`
    order by tax desc;
    
-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
	select 
    `Product line`,
    case
    when sum(total) > avg(total) then 'Good'
    else 'Bad'
    end as Rating_Type
    From Amazon
    group by `Product line`;
    
-- 12. Identify the branch that exceeded the average number of products sold.
SELECT Branch,sum(Quantity)
FROM Amazon
GROUP BY Branch
HAVING SUM(Quantity) > (SELECT AVG(Quantity) FROM Amazon);

-- 13. Which product line is most frequently associated with each gender?                   
	SELECT Gender, `Product line`, Frequency
FROM (
    SELECT Gender, `Product line`, COUNT(*) AS Frequency,
           ROW_NUMBER() OVER(PARTITION BY Gender ORDER BY COUNT(*) DESC) AS rn
    FROM amazon
    GROUP BY Gender, `Product line`
) AS RankedData
WHERE rn = 1;
    
    
    
-- 14. Calculate the average rating for each product line.
	select `Product line`, avg(Rating) from amazon
    group by `Product line`
    order by avg(Rating) desc;
    
-- 15. Count the sales occurrences for each time of day on every weekday.
	SELECT timeofday,dayname,count(*) AS sales_occurrences
    FROM amazon
    WHERE 
    DAYOFWEEK(Date) > 1 AND DAYOFWEEK(Date) < 7
    GROUP BY dayname,timeofday
    order by sales_occurrences desc ;
    
    
-- 16. Identify the customer type contributing the highest revenue.
		select `Customer type` , sum(total) as highest_rev from amazon
        group by `Customer type`
        order by highest_rev desc
         limit 1;
        
-- 17. Determine the city with the highest VAT percentage.
        select city , sum(VAT) as total_vat,SUM(Total) AS Total_Sales,
        (SUM(VAT)/SUM(Total)) AS VAT_Percentage
        from amazon
        group by city
        order by VAT_Percentage desc
         limit 1;
        
-- 18. Identify the customer type with the highest VAT payments.
		select `Customer type` , sum(VAT) as high_vat from amazon
        group by `Customer type`
        order by high_vat desc
        limit 1;
        
-- 19. What is the count of distinct customer types in the dataset?
		select count(distinct `Customer type`) as no_cus_type from amazon;
        
-- 20. What is the count of distinct payment methods in the dataset?
		select count(distinct Payment) as unique_pay from amazon;
        
-- 21. Which customer type occurs most frequently?
		select `Customer type` , count(`Customer type`) as freq from amazon
        group by `Customer type`
        order by freq desc
        limit 1;
        
-- 22. Identify the customer type with the highest purchase frequency.
		select `Customer type` , count(`Product line`) as cnt from amazon
        group by `Customer type`
        order by cnt desc
        limit 1;
        
-- 23. Determine the predominant gender among customers.
		select Gender , count(Gender) as freq from amazon
        group by Gender
        order by freq desc
         limit 1;
         
-- 24. Examine the distribution of genders within each branch.
		select Branch, Gender , count(Gender) as freq from amazon
        group by Gender,Branch
        order by Branch;
	
-- 25. Identify the time of day when customers provide the most ratings.
		SELECT timeofday, COUNT(Rating) AS rating_count
		FROM amazon
		GROUP BY timeofday
		ORDER BY rating_count desc;
        
-- 26. Determine the time of day with the highest customer ratings for each branch.
	WITH Prod AS (
    SELECT 
        Branch,
        timeofday,
        COUNT(Rating) AS rating_count,
        ROW_NUMBER() OVER (PARTITION BY  Branch ORDER BY  COUNT(Rating) DESC) AS rn
    FROM 
        amazon
    GROUP BY 
        Branch, timeofday
)
SELECT 
    Branch,
    timeofday,
    rating_count
FROM 
    Prod
WHERE 
   rn = 1;
   
-- 27. Identify the day of the week with the highest average ratings.
	SELECT dayname, avg(Rating) AS rating_count
		FROM amazon
		GROUP BY dayname
		ORDER BY rating_count desc
        limit 1;
        
-- 28. Determine the day of the week with the highest average ratings for each branch.
		WITH Prod AS (
    SELECT 
        Branch,
        dayname,
        avg(Rating) AS rating_count,
        ROW_NUMBER() OVER (PARTITION BY  Branch ORDER BY avg(Rating) DESC) AS rn
    FROM 
        amazon
    GROUP BY 
        Branch, dayname
)
SELECT 
    Branch,
    dayname,
    rating_count
FROM 
    Prod
WHERE 
   rn = 1;
