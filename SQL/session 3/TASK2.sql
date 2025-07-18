use StoreDB
GO
--1
select * from production.products WHERE list_price> 1000
--2
SELECT * FROM sales.customers WHERE STATE IN('CA', 'NY')
--3
SELECT * FROM SALES.orders WHERE order_date BETWEEN '2022-01-01' AND '2023-12-31'
--4
SELECT * FROM sales.customers WHERE email LIKE '%@gmail.com'
--5
select * from sales.staffs where active =0 -- inactive staff
--6
select top 5 * from production.products ORDER BY list_price
--7
select top 10 * from sales.orders ORDER BY order_date DESC
--8
SELECT top 3 * FROM sales.customers ORDER by last_name ASC
--9
select * from sales.customers where phone IS NULL
--10
select * from sales.staffs where manager_id is not NULL -- staffs with managers
--11
select count (category_id) as 'Number of products', category_id from production.products GROUP by category_id
--12
select count(customer_id) as 'Number of customers',state from sales.customers GROUP by state
--13
select avg(list_price) as 'Average Price',brand_id from production.products GROUP by brand_id
--14
SELECT COUNT(order_id) AS 'Number of Orders', staff_id FROM sales.orders GROUP BY staff_id
--15
select customer_id, count(customer_id) as NUM_OF_ORDERS from sales.orders group by customer_id having count(customer_id) > 2 -- customers with more than 2 orders
--16
select * from production.products where list_price between 500 and 1500
--17
select * from sales.customers where city LIKE 'S%'
--18
select * from sales.ORDERs where order_status =2 or order_status = 4 
--19
select * from production.products where category_id  in(1, 2, 3) 
--20
select * from sales.staffs where  store_id=1 or phone is null 