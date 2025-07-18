USE StoreDB
GO
-- 1
DECLARE @CustomerID INT = 1;
DECLARE @TotalSpent DECIMAL(10,2);

SELECT @TotalSpent = SUM(oi.quantity * oi.list_price * (1 - oi.discount))
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.customer_id = @CustomerID;

IF @TotalSpent > 5000
    PRINT 'Customer ID ' + CAST(@CustomerID AS VARCHAR) + ' is a VIP customer. Total spent: $' + CAST(@TotalSpent AS VARCHAR);
ELSE
    PRINT 'Customer ID ' + CAST(@CustomerID AS VARCHAR) + ' is a regular customer. Total spent: $' + CAST(@TotalSpent AS VARCHAR);
-- 2
 DECLARE @ThresholdPrice DECIMAL(10,2) = 1500;
DECLARE @ProductCount INT;

SELECT @ProductCount = COUNT(*) 
FROM production.products
WHERE list_price > @ThresholdPrice;

PRINT 'Threshold Price: $' + CAST(@ThresholdPrice AS VARCHAR);
PRINT 'Number of products above threshold: ' + CAST(@ProductCount AS VARCHAR);

-- 3
DECLARE @StaffID INT = 2;
DECLARE @Year INT = 2017;
DECLARE @TotalSales DECIMAL(10,2);

SELECT @TotalSales = SUM(oi.quantity * oi.list_price * (1 - oi.discount))
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.staff_id = @StaffID
  AND YEAR(o.order_date) = @Year;

PRINT 'Staff ID: ' + CAST(@StaffID AS VARCHAR);
PRINT 'Year: ' + CAST(@Year AS VARCHAR);
PRINT 'Total Sales: $' + CAST(@TotalSales AS VARCHAR);
-- 4
SELECT TOP 10 * FROM sales.orders;

PRINT 'Server Name: ' + @@SERVERNAME;
PRINT 'SQL Server Version: ' + @@VERSION;
PRINT 'Rows affected by last statement: ' + CAST(@@ROWCOUNT AS VARCHAR);
-- 5
DECLARE @ProductID INT = 1;
DECLARE @StoreID INT = 1;
DECLARE @Quantity INT;

SELECT @Quantity = quantity
FROM production.stocks
WHERE product_id = @ProductID AND store_id = @StoreID;

IF @Quantity > 20
    PRINT 'Well stocked';
ELSE IF @Quantity BETWEEN 10 AND 20
    PRINT 'Moderate stock';
ELSE
    PRINT 'Low stock - reorder needed';
-- 6
DECLARE @BatchSize INT = 3;
DECLARE @UpdatedCount INT = 0;
DECLARE @ProductID INT;
DECLARE @StoreID INT;

WHILE EXISTS (
    SELECT 1 FROM production.stocks
    WHERE quantity < 5
)
BEGIN
    -- Use a CTE or temp table to isolate the top 3 rows
    WITH Batch AS (
        SELECT TOP (@BatchSize) store_id, product_id
        FROM production.stocks
        WHERE quantity < 5
        ORDER BY store_id, product_id
    )
    UPDATE s
    SET quantity = quantity + 10
    FROM production.stocks s
    INNER JOIN Batch b
        ON s.store_id = b.store_id AND s.product_id = b.product_id;

    SET @UpdatedCount = @UpdatedCount + @@ROWCOUNT;

    PRINT 'Updated batch of ' + CAST(@BatchSize AS VARCHAR) + ' products. Total updated so far: ' + CAST(@UpdatedCount AS VARCHAR);
END
-- 7
SELECT 
    product_id,
    product_name,
    list_price,
    CASE
        WHEN list_price < 300 THEN 'Budget'
        WHEN list_price BETWEEN 300 AND 800 THEN 'Mid-Range'
        WHEN list_price BETWEEN 801 AND 2000 THEN 'Premium'
        ELSE 'Luxury'
    END AS price_category
FROM production.products;
-- 8
DECLARE @CustomerID2 INT = 5;

IF EXISTS (SELECT 1 FROM sales.customers WHERE customer_id = @CustomerID2)
BEGIN
    SELECT 
        COUNT(*) AS order_count
    FROM sales.orders
    WHERE customer_id = @CustomerID2;
END
ELSE
BEGIN
    PRINT 'Customer ID ' + CAST(@CustomerID2 AS VARCHAR) + ' does not exist in the database.';
END
-- 9
GO
CREATE FUNCTION dbo.CalculateShipping (@OrderTotal DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN 
    DECLARE @ShippingCost DECIMAL(10,2);

    SET @ShippingCost = 
        CASE 
            WHEN @OrderTotal > 100 THEN 0.00
            WHEN @OrderTotal >= 50 AND @OrderTotal < 100 THEN 5.99
            ELSE 12.99
        END;

    RETURN @ShippingCost;
END
GO

-- 10
CREATE FUNCTION dbo.GetProductsByPriceRange (
    @MinPrice DECIMAL(10,2),
    @MaxPrice DECIMAL(10,2)
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        p.product_id,
        p.product_name,
        p.list_price,
        b.brand_name,
        c.category_name
    FROM production.products p
    JOIN production.brands b ON p.brand_id = b.brand_id
    JOIN production.categories c ON p.category_id = c.category_id
    WHERE p.list_price BETWEEN @MinPrice AND @MaxPrice
);
GO
-- 11
CREATE FUNCTION dbo.GetCustomerYearlySummary (@CustomerID INT)
RETURNS @YearlySummary TABLE (
    OrderYear INT,
    TotalOrders INT,
    TotalSpent DECIMAL(18,2),
    AvgOrderValue DECIMAL(18,2)
)
AS
BEGIN
    INSERT INTO @YearlySummary
    SELECT 
        YEAR(o.order_date) AS OrderYear,
        COUNT(DISTINCT o.order_id) AS TotalOrders,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS TotalSpent,
        AVG(oi.quantity * oi.list_price * (1 - oi.discount)) AS AvgOrderValue
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @CustomerID
    GROUP BY YEAR(o.order_date);

    RETURN;
END
GO
-- 12
CREATE FUNCTION dbo.CalculateBulkDiscount (@Quantity INT)
RETURNS DECIMAL(4,2)
AS
BEGIN
    DECLARE @Discount DECIMAL(4,2);

    SET @Discount =
        CASE
            WHEN @Quantity BETWEEN 1 AND 2 THEN 0.00
            WHEN @Quantity BETWEEN 3 AND 5 THEN 0.05
            WHEN @Quantity BETWEEN 6 AND 9 THEN 0.10
            ELSE 0.15
        END;

    RETURN @Discount;
END
GO
-- 13
CREATE PROCEDURE sp_GetCustomerOrderHistory
    @CustomerID INT,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        o.order_id,
        o.order_date,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS OrderTotal
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @CustomerID
        AND (@StartDate IS NULL OR o.order_date >= @StartDate)
        AND (@EndDate IS NULL OR o.order_date <= @EndDate)
    GROUP BY o.order_id, o.order_date
    ORDER BY o.order_date;
END
GO
-- 14
CREATE PROCEDURE sp_RestockProduct
    @StoreID INT,
    @ProductID INT,
    @RestockQty INT,
    @OldQty INT OUTPUT,
    @NewQty INT OUTPUT,
    @Success BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Success = 0;

    BEGIN TRY
        SELECT @OldQty = quantity
        FROM production.stocks
        WHERE store_id = @StoreID AND product_id = @ProductID;

        UPDATE production.stocks
        SET quantity = quantity + @RestockQty
        WHERE store_id = @StoreID AND product_id = @ProductID;

        SELECT @NewQty = quantity
        FROM production.stocks
        WHERE store_id = @StoreID AND product_id = @ProductID;

        SET @Success = 1;
    END TRY
    BEGIN CATCH
        SET @Success = 0;
    END CATCH
END
GO
 -- 15
CREATE PROCEDURE sp_ProcessNewOrder
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT,
    @StoreID INT,
    @OrderID INT OUTPUT,
    @Success BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Success = 0;

    DECLARE @StaffID INT, @OrderDate DATE = GETDATE(), @ListPrice DECIMAL(10,2), @Discount DECIMAL(4,2) = 0.00;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Get any staff member from the store
        SELECT TOP 1 @StaffID = staff_id
        FROM sales.staffs
        WHERE store_id = @StoreID;

        -- Get product price
        SELECT @ListPrice = list_price
        FROM production.products
        WHERE product_id = @ProductID;

        -- Insert new order
        INSERT INTO sales.orders (customer_id, order_status, order_date, required_date, store_id, staff_id)
        VALUES (@CustomerID, 1, @OrderDate, DATEADD(DAY, 7, @OrderDate), @StoreID, @StaffID);

        SET @OrderID = SCOPE_IDENTITY();

        -- Insert order item
        INSERT INTO sales.order_items (order_id, item_id, product_id, quantity, list_price, discount)
        VALUES (@OrderID, 1, @ProductID, @Quantity, @ListPrice, @Discount);

        -- Deduct from stock
        UPDATE production.stocks
        SET quantity = quantity - @Quantity
        WHERE store_id = @StoreID AND product_id = @ProductID;

        COMMIT TRANSACTION;
        SET @Success = 1;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @Success = 0;
    END CATCH
END
GO
-- 16
CREATE PROCEDURE sp_SearchProducts
    @SearchTerm VARCHAR(255) = NULL,
    @CategoryID INT = NULL,
    @MinPrice DECIMAL(10,2) = NULL,
    @MaxPrice DECIMAL(10,2) = NULL,
    @SortColumn VARCHAR(50) = 'list_price'
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX) = '
    SELECT p.product_id, p.product_name, p.list_price, c.category_name
    FROM production.products p
    JOIN production.categories c ON p.category_id = c.category_id
    WHERE 1 = 1';

    IF @SearchTerm IS NOT NULL
        SET @SQL += ' AND p.product_name LIKE ''%' + @SearchTerm + '%''';
    IF @CategoryID IS NOT NULL
        SET @SQL += ' AND p.category_id = ' + CAST(@CategoryID AS VARCHAR);
    IF @MinPrice IS NOT NULL
        SET @SQL += ' AND p.list_price >= ' + CAST(@MinPrice AS VARCHAR);
    IF @MaxPrice IS NOT NULL
        SET @SQL += ' AND p.list_price <= ' + CAST(@MaxPrice AS VARCHAR);

    -- Safe dynamic ORDER BY
    SET @SQL += ' ORDER BY ' + QUOTENAME(@SortColumn);

    EXEC sp_executesql @SQL;
END
GO
-- 17
DECLARE @StartDate DATE = '2017-01-01';
DECLARE @EndDate DATE = '2017-03-31'; -- Q1
DECLARE @LowTierBonus DECIMAL(5,2) = 0.02;
DECLARE @MidTierBonus DECIMAL(5,2) = 0.05;
DECLARE @HighTierBonus DECIMAL(5,2) = 0.1;

SELECT 
    s.staff_id,
    s.first_name + ' ' + s.last_name AS staff_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales,
    CASE
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) >= 50000 THEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) * @HighTierBonus
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) >= 20000 THEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) * @MidTierBonus
        ELSE SUM(oi.quantity * oi.list_price * (1 - oi.discount)) * @LowTierBonus
    END AS bonus
FROM sales.staffs s
JOIN sales.orders o ON s.staff_id = o.staff_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.order_date BETWEEN @StartDate AND @EndDate
GROUP BY s.staff_id, s.first_name, s.last_name;

-- 18
SELECT 
    s.store_id,
    s.product_id,
    p.product_name,
    c.category_name,
    s.quantity,
    CASE
        WHEN s.quantity < 5 AND c.category_name = 'Electronics' THEN 'Reorder 30 units'
        WHEN s.quantity < 10 AND c.category_name = 'Clothing' THEN 'Reorder 50 units'
        WHEN s.quantity < 15 THEN 'Reorder 20 units'
        ELSE 'Stock sufficient'
    END AS restock_action
FROM production.stocks s
JOIN production.products p ON s.product_id = p.product_id
JOIN production.categories c ON p.category_id = c.category_id;

-- 19
SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    ISNULL(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 0) AS total_spent,
    CASE 
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) IS NULL THEN 'No Orders'
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) < 1000 THEN 'Bronze'
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) BETWEEN 1000 AND 4999 THEN 'Silver'
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) BETWEEN 5000 AND 9999 THEN 'Gold'
        ELSE 'Platinum'
    END AS loyalty_tier
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name;

GO
-- 20

CREATE PROCEDURE sp_DiscontinueProduct
    @ProductID INT,
    @ReplacementProductID INT = NULL,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PendingOrders INT;

    SELECT @PendingOrders = COUNT(DISTINCT o.order_id)
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE oi.product_id = @ProductID AND o.shipped_date IS NULL;

    IF @PendingOrders > 0 AND @ReplacementProductID IS NULL
    BEGIN
        SET @Message = 'Cannot discontinue: ' + CAST(@PendingOrders AS VARCHAR) + ' unshipped orders exist.';
        RETURN;
    END

    BEGIN TRANSACTION;

    BEGIN TRY
        IF @ReplacementProductID IS NOT NULL
        BEGIN
            UPDATE sales.order_items
            SET product_id = @ReplacementProductID
            WHERE product_id = @ProductID;
        END

        DELETE FROM production.stocks
        WHERE product_id = @ProductID;

        DELETE FROM production.products
        WHERE product_id = @ProductID;

        COMMIT TRANSACTION;
        SET @Message = 'Product discontinued successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @Message = 'Error during product discontinuation.';
    END CATCH
END
GO
