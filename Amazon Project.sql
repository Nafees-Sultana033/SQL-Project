-- 1. What is the count of distinct cities in the dataset?
select count(distinct city) as count_of_cities from amazon;

-- 2. For each branch, what is the corresponding city?
select distinct branch, city from amazon
order by branch;

-- 3. What is the count of distinct product lines in the dataset?
select count(distinct product_line) as count_of_product_lines from amazon; 

-- 4. Which payment method occurs most frequently?
select payment, count(*) as payment_method from amazon
group by payment;

-- 5. Which product line has the highest sales?
select product_line, count(*) as highest_sales from amazon
group by product_line
order by highest_sales desc;

-- 6. How much revenue is generated each month?
select monthname(str_to_date(date, '%c/%e/%Y')) as Month, round(sum(total)) as revenue from amazon
group by month
order by revenue desc;

-- 7.  In which month did the cost of goods sold reach its peak?
select monthname(str_to_date(date, '%c/%e/%Y')) as Month, ceiling(sum(cogs)) as total_COGS from amazon
group by Month
order by total_COGS desc;

-- 8. Which product line generated the highest revenue?
select product_line, ceiling(sum(total)) as revenue from amazon
group by product_line
order by revenue desc;

-- 9. In which city was the highest revenue recorded?
with highest_revenue as
(select city, round(sum(total)) as revenue from amazon
group by city)
select city, revenue from highest_revenue
order by revenue desc
limit 1;

-- 10. Which product line incurred the highest Value Added Tax?
select product_line, highest_VAT from (select product_line, round(sum(tax), 1) as highest_VAT from amazon
group by product_line) as VAt 
order by highest_VAT desc
limit 1;

-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad." 
select product_line, round(sum(total)) as total_sales, 
case
when round(sum(total)) > (select avg(total_sales)
from (select product_line, round(sum(total)) as total_sales from amazon group by product_line) as subquery)
then 'Good'
else 'Bad'
end as sales_growth
from amazon
group by product_line
order by total_sales desc;

-- 12. Identify the branch that exceeded the average number of products sold. 
select branch, sum(quantity) as products_sold, floor(avg(Quantity)) as avg_products_sold
from amazon
group by branch
having sum(quantity) > avg(quantity);

-- 13.  Which product line is most frequently associated with each gender?
select product_line, gender, count(gender) as frequency from amazon
group by Product_line, gender
order by frequency desc
limit 1;

-- 14.  Calculate the average rating for each product line.
select product_line, avg(rating) from amazon
group by Product_line
order by avg(rating) desc;

-- 15.  Count the sales occurrences for each time of day on every weekday. 
select dayname(str_to_date(date, '%c/%e/%Y')) as weekday, count(cogs) as Sales_Occurance,
case 
when time between '06:30:00' and '11:59:00' then 'Morning'
when time between '12:00:00' and '18:00:00' then 'Afternoon'
else 'Evening'
end as time_of_day
from amazon
where dayname(str_to_date(date, '%c/%e/%Y')) not in ('Saturday', 'Sunday')
group by time_of_day, weekday
order by Sales_Occurance desc;

-- 16.  Identify the customer type contributing the highest revenue.
select customer_type, sum(total) as revenue
from amazon
group by customer_type
order by revenue desc limit 1;

-- 17.  Determine the city with the highest VAT percentage. 
select city, round(sum(tax)) as highest_vat, round(sum(total), 1) as total_sales, 
ceiling((sum(tax) / sum(total)) * 100) as percentage
from amazon
group by city
order by percentage desc;

-- 18.  Identify the customer type with the highest VAT payments. 
select customer_type, sum(tax) as highest_vat
from amazon
group by customer_type;

-- 19.  What is the count of distinct customer types in the dataset?
select count(distinct customer_type) as distinct_customer from amazon;

-- 20.  What is the count of distinct payment methods in the dataset?
select count(distinct payment) as payment_methods from amazon;

-- 21. Which customer type occurs most frequently? 
select customer_type, count(customer_type) as most_frequent from amazon
group by customer_type
order by most_frequent desc
limit 1;

-- 22. Identify the customer type with the highest purchase frequency. 
select customer_type, count(*) as highest_purchase 
from amazon 
group by customer_type 
order by highest_purchase desc 
limit 1;

-- 23. Determine the predominant gender among customers. 
select gender, predominant_gender from
(select gender, count(gender) as predominant_gender,
rank() over(order by count(gender) desc) as rnk 
from amazon group by gender) as ranked
where rnk=1;

-- 24. Examine the distribution of genders within each branch. 
select branch, gender, count(*) as gender_count from amazon
group by branch, gender with rollup
having branch is not null and gender is not null
order by gender_count desc;

-- 25. Identify the time of day when customers provide the most ratings. 
select count(rating) as count_of_rating,
case 
when time between '06:30:00' and '11:59:00' then 'Morning'
when time between '12:00:00' and '18:00:00' then 'Afternoon'
else 'Evening'
end as time_of_day
from amazon
group by time_of_day
order by count_of_rating desc;

-- 26. Determine the time of day with the highest customer ratings for each branch. 
select branch, round(avg(rating), 1) as avg_rating,
case 
when time between '06:30:00' and '11:59:00' then 'Morning'
when time between '12:00:00' and '18:00:00' then 'Afternoon'
else 'Evening'
end as time_of_day
from amazon
group by branch, time_of_day
order by avg_rating desc;

-- 27. Identify the day of the week with the highest average ratings. 
select dayname(str_to_date(date, '%c/%e/%Y')) as day_of_week, round(avg(rating), 1) as highest_rating from amazon
group by day_of_week
order by highest_rating desc limit 1;

-- 28. Determine the day of the week with the highest average ratings for each branch. 
with CTE as
(select branch, dayname(str_to_date(date, '%c/%e/%Y')) as day_of_week, round(avg(rating), 2) as highest_rating,
row_number() over (partition by branch order by round(avg(rating), 2) desc) as rnk
from amazon
group by  branch, day_of_week)
select branch, day_of_week, highest_rating
from CTE
where rnk = 1;