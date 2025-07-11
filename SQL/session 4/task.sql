USE StoreDB
GO
-- 1
SELECT COUNT(product_id) AS TotalProducts from production.products
-- 2
select avg(list_price) as AveragePrice, max(list_price) as maxmimumprice, min(list_price) as minprice from production.products
-- 3
select count(product_id) as TotalProducts , category_id  from production.products group by category_id
-- 4
select count(order_id) as TotalOrders, store_id from sales.orders group by store_id
-- 5
select top 10 * from sales.customers where first_name = UPPER(first_name) and last_name = LOWER(last_name)
-- 6
select top 10 LEN(product_name) as namelength, product_name from production.products order by LEN(product_name) DESC
-- 7
select customer_id, SUBSTRING(phone,1,3) as area_code from sales.customers where customer_id between 1 and 15
-- 8
SELECT  SUBSTRING(CONVERT(VARCHAR, order_date, 112), 1, 4) AS year,  SUBSTRING(CONVERT(VARCHAR, order_date, 112), 5, 2) AS month from sales.orders  where order_id between 1 and 10 ORDER BY order_date
-- 9
SELECT top 10 cat.category_name, prod.product_name
FROM production.categories AS cat
JOIN production.products AS prod ON cat.category_id = prod.category_id 
-- 10
select ord.order_date, cust.first_name, cust.last_name
FROM sales.orders AS ord
JOIN sales.customers AS cust ON ord.customer_id = cust.customer_id
WHERE ord.order_id BETWEEN 1 AND 10
-- 11
select pro.product_name, COALESCE(brand.brand_name, 'No Brand') AS brand_name
FROM production.products AS pro
JOIN production.brands AS brand ON pro.brand_id = brand.brand_id
-- 12
select product_name, list_price from production.products
where list_price > (select avg(list_price) from production.products)
-- 13
SELECT customer_id, first_name
FROM sales.customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM sales.orders
);
-- 14
select first_name, last_name,(select count(order_id) from sales.orders where sales.customers.customer_id = sales.orders.customer_id) as TotalOrders
from sales.customers
 -- 15
CREATE VIEW easy_product_list AS 
SELECT 
    prod.product_name,
    cat.category_name,
    prod.list_price
FROM 
    production.products prod
JOIN 
    production.categories cat ON prod.category_id = cat.category_id;

select * from easy_product_list where list_price > 100

GO
-- 16
CREATE VIEW customer_info  AS 
SELECT 
     cust.first_name,
     cust.last_name,
     cust.customer_id,
     CONCAT(cust.city, ', ', cust.state) AS city_state,
     cust.email
FROM 
    sales.customers AS cust;
GO
 

select * from customer_info where city_state LIKE '%CA'
GO
-- 17
select product_name, list_price
FROM production.products
WHERE 
    list_price  BETWEEN  50 AND 200 order by list_price asc
-- 18
select count(customer_id) as customer_count, state
FROM sales.customers
GROUP BY state
ORDER BY customer_count DESC
-- 19
select TOP 1 max(prod.list_price) as MaximumPrice, cat.category_name, prod.product_name
FROM production.products AS prod
JOIN production.categories AS cat ON prod.category_id = cat.category_id
GROUP by cat.category_name,prod.product_name
ORDER BY MaximumPrice DESC;
-- 20
SELECT  store.store_name, COUNT(ord.order_id) AS TotalOrders, store.city
FROM 
  sales.orders AS ord
JOIN 
    sales.stores AS store ON ord.store_id = store.store_id
GROUP BY 
    store.store_name, store.city;