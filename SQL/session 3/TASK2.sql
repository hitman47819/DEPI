use StoreDB
GO
select * from production.products WHERE list_price> 1000
SELECT * FROM sales.customers WHERE STATE IN('CA', 'NY')
SELECT * FROM SALES.orders WHERE order_date BETWEEN '2022-01-01' AND '2023-12-31'
SELECT * FROM sales.customers WHERE email LIKE '%@gmail.com'
select * from sales.staffs where active =0 -- inactive staff
select top 5 * from production.products ORDER BY list_price
select top 10 * from sales.orders ORDER BY order_date DESC
SELECT top 3 * FROM sales.customers ORDER by last_name ASC
select * from sales.customers where phone IS NULL
select * from sales.staffs where manager_id is not NULL -- staffs with managers
select count (category_id) as 'Number of products', category_id from production.products GROUP by category_id
select count(customer_id) as 'Number of customers',state from sales.customers GROUP by state
select avg(list_price) as 'Average Price',brand_id from production.products GROUP by brand_id
SELECT COUNT(order_id) AS 'Number of Orders', staff_id FROM sales.orders GROUP BY staff_id
select customer_id, count(customer_id) as NUM_OF_ORDERS from sales.orders group by customer_id having count(customer_id) > 2 -- customers with more than 2 orders
select * from production.products where list_price between 500 and 1500
select * from sales.customers where city LIKE 'S%'
select * from sales.ORDERs where order_status =2 or order_status = 4 
select * from production.products where category_id  in(1, 2, 3) 
select * from sales.staffs where  store_id=1 or phone is null 