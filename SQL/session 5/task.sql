USE StoreDB
GO
-- 1
SELECT *, 
case
when list_price BETWEEN 300 and 999 then'Standard'
when list_price BETWEEN 1000 and 2499 then 'Premium'
when list_price >=2500  then'Luxury' else 'Economy'  
END AS price_category 
from production.products 
-- 2
SELECT *,
case 
when order_status =4  then'Order Delivered' 
when order_status =3  then 'Order Cancelled'
when order_status =2  then'In Preparation'
else 'Order Received'   
END AS price_category,
case 
WHEN order_status = 1 AND DATEDIFF(DAY, order_date, CURRENT_TIMESTAMP) = 5 THEN 'URGENT'
WHEN order_status = 2 AND DATEDIFF(DAY, order_date, CURRENT_TIMESTAMP) = 3 THEN 'HIGH'
else 'NORMAL'   
END AS order_priority
from sales.orders 
 -- 3
SELECT staff.staff_id,
CASE 
WHEN COUNT(orders.order_id) = 0 THEN 'New Staff'
WHEN COUNT(orders.order_id) BETWEEN 1 AND 10 THEN 'Junior Staff'
WHEN COUNT(orders.order_id) BETWEEN 11 AND 25 THEN 'Senior Staff'
WHEN COUNT(orders.order_id) >= 26 THEN 'Expert Staff'
END AS staff_category
FROM sales.staffs AS staff
LEFT JOIN sales.orders AS orders ON orders.staff_id = staff.staff_id
GROUP BY staff.staff_id;
 -- 4
select customer_id, first_name, last_name, ISNULL(phone, 'Phone Not Available') AS phone,
 COALESCE(phone, email, 'No Contact Method') AS preferred_contact, email, street, city, state, zip_code
from sales.customers
-- 5

SELECT 
    store.store_id, store.product_id,  product.product_name,  store.quantity, product.list_price,
    ISNULL(product.list_price / NULLIF(store.quantity, 0), 0) AS price_per_unit,
    CASE 
        WHEN store.quantity > 0 THEN 'In Stock'
        ELSE 'Out of Stock'
    END AS stock_status
FROM 
    production.stocks store
JOIN 
    production.products product ON store.product_id = product.product_id
WHERE 
    store.store_id = 1;
-- 6
SELECT 
    customer_id,
    first_name,
    last_name,
    COALESCE(street, '') + 
        CASE WHEN street IS NOT NULL THEN ', ' ELSE '' END +
    COALESCE(city, '') + 
        CASE WHEN city IS NOT NULL THEN ', ' ELSE '' END +
    COALESCE(state, '') + 
        CASE WHEN state IS NOT NULL THEN ' ' ELSE '' END +
    COALESCE(zip_code, '') AS formatted_address
FROM 
    sales.customers;
-- 7
WITH CustomerSpending AS (
    SELECT 
        o.customer_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
    FROM 
        sales.orders o
    JOIN 
        sales.order_items oi ON o.order_id = oi.order_id
    WHERE 
        o.customer_id IS NOT NULL
    GROUP BY 
        o.customer_id
    HAVING 
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) > 1500
)

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    cs.total_spent
FROM 
    CustomerSpending cs
JOIN 
    sales.customers c ON cs.customer_id = c.customer_id
ORDER BY 
    cs.total_spent DESC;

-- 8
wITH CategoryRevenue AS (
    SELECT 
        p.category_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM 
        sales.order_items oi
    JOIN 
        production.products p ON oi.product_id = p.product_id
    GROUP BY 
        p.category_id
),

CategoryAOV AS (
    SELECT 
        category_order_totals.category_id,
        AVG(order_total) AS avg_order_value
    FROM (
        SELECT 
            o.order_id,
            p.category_id,
            SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS order_total
        FROM 
            sales.orders o
        JOIN 
            sales.order_items oi ON o.order_id = oi.order_id
        JOIN 
            production.products p ON oi.product_id = p.product_id
        GROUP BY 
            o.order_id, p.category_id
    ) AS category_order_totals
    GROUP BY 
        category_order_totals.category_id
)

SELECT 
    c.category_id,
    c.category_name,
    cr.total_revenue,
    ca.avg_order_value,
    CASE 
        WHEN cr.total_revenue > 50000 THEN 'Excellent'
        WHEN cr.total_revenue > 20000 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS performance_rating
FROM 
    CategoryRevenue cr
JOIN 
    CategoryAOV ca ON cr.category_id = ca.category_id
JOIN 
    production.categories c ON cr.category_id = c.category_id
ORDER BY 
    cr.total_revenue DESC;
-- 9
WITH MonthlySales AS (
    SELECT 
        FORMAT(o.order_date, 'yyyy-MM') AS sales_month,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM 
        sales.orders o
    JOIN 
        sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY 
        FORMAT(o.order_date, 'yyyy-MM')
),

MonthlyComparison AS (
    SELECT 
        sales_month,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY sales_month) AS prev_month_revenue
    FROM 
        MonthlySales
)

SELECT 
    sales_month,
    total_revenue,
    prev_month_revenue,
    CASE 
        WHEN prev_month_revenue IS NULL THEN NULL
        WHEN prev_month_revenue = 0 THEN NULL
        ELSE ROUND(((total_revenue - prev_month_revenue) / prev_month_revenue) * 100, 2)
    END AS growth_percentage
FROM 
    MonthlyComparison
ORDER BY 
    sales_month;
-- 10
WITH RankedProducts AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        p.list_price,
        
         ROW_NUMBER() OVER (PARTITION BY p.category_id ORDER BY p.list_price DESC) AS row_num,
        RANK()       OVER (PARTITION BY p.category_id ORDER BY p.list_price DESC) AS price_rank,
        DENSE_RANK() OVER (PARTITION BY p.category_id ORDER BY p.list_price DESC) AS dense_rank
    FROM 
        production.products p
)

SELECT 
    product_id,
    product_name,
    category_id,
    list_price,
    row_num,
    price_rank,
    dense_rank
FROM 
    RankedProducts
WHERE 
    row_num <= 3
ORDER BY 
    category_id,
    row_num;

-- 11
WITH CustomerSpending AS (
    SELECT 
        o.customer_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
    FROM 
        sales.orders o
    JOIN 
        sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY 
        o.customer_id
),

RankedCustomers AS (
    SELECT 
        cs.customer_id,
        cs.total_spent,
        RANK() OVER (ORDER BY cs.total_spent DESC) AS customer_rank,
        NTILE(5) OVER (ORDER BY cs.total_spent DESC) AS spending_group
    FROM 
        CustomerSpending cs
)

SELECT 
    rc.customer_id,
    rc.total_spent,
    rc.customer_rank,
    rc.spending_group,
    CASE 
        WHEN rc.spending_group = 1 THEN 'VIP'
        WHEN rc.spending_group = 2 THEN 'Gold'
        WHEN rc.spending_group = 3 THEN 'Silver'
        WHEN rc.spending_group = 4 THEN 'Bronze'
        WHEN rc.spending_group = 5 THEN 'Standard'
    END AS tier
FROM 
    RankedCustomers rc
ORDER BY 
    rc.customer_rank;

-- 12
WITH StorePerformance AS (
    SELECT 
        o.store_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS num_orders
    FROM 
        sales.orders o
    JOIN 
        sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY 
        o.store_id
),

RankedStores AS (
    SELECT 
        sp.store_id,
        sp.total_revenue,
        sp.num_orders,
        RANK() OVER (ORDER BY sp.total_revenue DESC) AS revenue_rank,
        RANK() OVER (ORDER BY sp.num_orders DESC) AS order_rank,
        PERCENT_RANK() OVER (ORDER BY sp.total_revenue DESC) AS revenue_percentile,
        PERCENT_RANK() OVER (ORDER BY sp.num_orders DESC) AS order_percentile
    FROM 
        StorePerformance sp
)

SELECT 
    rs.store_id,
    rs.total_revenue,
    rs.num_orders,
    rs.revenue_rank,
    rs.order_rank,
    rs.revenue_percentile,
    rs.order_percentile
FROM 
    RankedStores rs
ORDER BY 
    rs.revenue_rank;  

-- 13
SELECT *
FROM (
    SELECT 
        c.category_name,
        b.brand_name,
        p.product_id
    FROM 
        production.products p
    INNER JOIN 
        production.categories c ON p.category_id = c.category_id
    INNER JOIN 
        production.brands b ON p.brand_id = b.brand_id
    WHERE 
        b.brand_name IN ('Electra', 'Haro', 'Trek', 'Surly')
) AS SourceTable
PIVOT (
    COUNT(product_id)
    FOR brand_name IN ([Electra], [Haro], [Trek], [Surly])
) AS PivotTable
ORDER BY category_name;

-- 14
SELECT *
FROM (
    SELECT 
        s.store_name,
        MONTH(o.order_date) AS month,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM 
        sales.orders o
    INNER JOIN 
        sales.order_items oi ON o.order_id = oi.order_id
    INNER JOIN 
        sales.stores s ON o.store_id = s.store_id
    GROUP BY 
        s.store_name, MONTH(o.order_date)
) AS SourceTable
PIVOT (
    SUM(total_revenue)
    FOR month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS PivotTable
ORDER BY store_name;

 -- 15
SELECT *
FROM (
    SELECT 
        s.store_name,
        CASE 
            WHEN o.order_status = 1 THEN 'Pending'
            WHEN o.order_status = 2 THEN 'Processing'
            WHEN o.order_status = 3 THEN 'Completed'
            WHEN o.order_status = 4 THEN 'Rejected'
            ELSE 'Unknown'
        END AS order_status,
        o.order_id
    FROM 
        sales.orders o
    INNER JOIN 
        sales.stores s ON o.store_id = s.store_id
) AS SourceTable
PIVOT (
    COUNT(order_id)
    FOR order_status IN ([Pending], [Processing], [Completed], [Rejected])
) AS PivotTable
ORDER BY store_name;

-- 16
WITH RevenueByBrandYear AS (
    SELECT 
        b.brand_name,
        YEAR(o.order_date) AS year,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM 
        sales.orders o
    INNER JOIN 
        sales.order_items oi ON o.order_id = oi.order_id
    INNER JOIN 
        production.products p ON oi.product_id = p.product_id
    INNER JOIN 
        production.brands b ON p.brand_id = b.brand_id
    WHERE 
        YEAR(o.order_date) IN (2016, 2017, 2018)
    GROUP BY 
        b.brand_name, YEAR(o.order_date)
)
, PivotData AS (
    SELECT *
    FROM (
        SELECT 
            brand_name,
            year,
            total_revenue
        FROM RevenueByBrandYear
    ) AS SourceTable
    PIVOT (
        SUM(total_revenue)
        FOR year IN ([2016], [2017], [2018])
    ) AS PivotTable
)
SELECT 
    brand_name,
    [2016],
    [2017],
    [2018],
    -- Calculating percentage growth between years
    CASE 
        WHEN [2016] > 0 THEN (CAST([2017] AS FLOAT) - [2016]) / [2016] * 100
        ELSE NULL
    END AS growth_2016_2017,
    
    CASE 
        WHEN [2017] > 0 THEN (CAST([2018] AS FLOAT) - [2017]) / [2017] * 100
        ELSE NULL
    END AS growth_2017_2018
FROM PivotData
ORDER BY brand_name;

-- 17
SELECT 
    p.product_id,
    p.product_name,
    'In-stock' AS availability_status
FROM 
    production.products p
INNER JOIN 
    production.stocks s ON p.product_id = s.product_id
WHERE 
    s.quantity > 0

UNION

SELECT 
    p.product_id,
    p.product_name,
    'Out-of-stock' AS availability_status
FROM 
    production.products p
LEFT JOIN 
    production.stocks s ON p.product_id = s.product_id
WHERE 
    (s.quantity = 0 OR s.quantity IS NULL)

UNION

SELECT 
    p.product_id,
    p.product_name,
    'Discontinued' AS availability_status
FROM 
    production.products p
LEFT JOIN 
    production.stocks s ON p.product_id = s.product_id
WHERE 
    s.product_id IS NULL;

-- 18
SELECT 
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS order_count_2017,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spending_2017
FROM 
    sales.orders o
INNER JOIN 
    sales.order_items oi ON o.order_id = oi.order_id
WHERE 
    YEAR(o.order_date) = 2017
GROUP BY 
    o.customer_id

INTERSECT

SELECT 
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS order_count_2018,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spending_2018
FROM 
    sales.orders o
INNER JOIN 
    sales.order_items oi ON o.order_id = oi.order_id
WHERE 
    YEAR(o.order_date) = 2018
GROUP BY 
    o.customer_id
-- 19
SELECT 
    p.product_id, 
    p.product_name,
    'Available in all stores' AS availability_status
FROM 
    production.products p
JOIN 
    production.stocks s1 ON p.product_id = s1.product_id
JOIN 
    production.stocks s2 ON p.product_id = s2.product_id
JOIN 
    production.stocks s3 ON p.product_id = s3.product_id
WHERE 
    s1.store_id = 1
    AND s2.store_id = 2
    AND s3.store_id = 3

INTERSECT

SELECT 
    p.product_id, 
    p.product_name,
    'Available in store 1 but not in store 2' AS availability_status
FROM 
    production.products p
JOIN 
    production.stocks s1 ON p.product_id = s1.product_id
LEFT JOIN 
    production.stocks s2 ON p.product_id = s2.product_id AND s2.store_id = 2
WHERE 
    s1.store_id = 1 
    AND (s2.product_id IS NULL)

UNION

 SELECT 
    p.product_id, 
    p.product_name,
    'Available in all stores' AS availability_status
FROM 
    production.products p
JOIN 
    production.stocks s1 ON p.product_id = s1.product_id
JOIN 
    production.stocks s2 ON p.product_id = s2.product_id
JOIN 
    production.stocks s3 ON p.product_id = s3.product_id
WHERE 
    s1.store_id = 1
    AND s2.store_id = 2
    AND s3.store_id = 3;
-- 20
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    'Lost Customer' AS customer_status
FROM 
    sales.customers c
WHERE 
    c.customer_id IN (
        SELECT DISTINCT o.customer_id
        FROM sales.orders o
        WHERE YEAR(o.order_date) = 2016
    )
    AND c.customer_id NOT IN (
        SELECT DISTINCT o.customer_id
        FROM sales.orders o
        WHERE YEAR(o.order_date) = 2017
    )

UNION ALL

 SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    'New Customer' AS customer_status
FROM 
    sales.customers c
WHERE 
    c.customer_id IN (
        SELECT DISTINCT o.customer_id
        FROM sales.orders o
        WHERE YEAR(o.order_date) = 2017
    )
    AND c.customer_id NOT IN (
        SELECT DISTINCT o.customer_id
        FROM sales.orders o
        WHERE YEAR(o.order_date) = 2016
    )

UNION ALL

 SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    'Retained Customer' AS customer_status
FROM 
    sales.customers c
WHERE 
    c.customer_id IN (
        SELECT DISTINCT o.customer_id
        FROM sales.orders o
        WHERE YEAR(o.order_date) = 2016
    )
    AND c.customer_id IN (
        SELECT DISTINCT o.customer_id
        FROM sales.orders o
        WHERE YEAR(o.order_date) = 2017
    );

