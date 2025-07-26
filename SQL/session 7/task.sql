USE StoreDB
GO
--prerequisites
-- Customer activity log
CREATE TABLE sales.customer_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    action VARCHAR(50),
    log_date DATETIME DEFAULT GETDATE()
);

-- Price history tracking
CREATE TABLE production.price_history (
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    change_date DATETIME DEFAULT GETDATE(),
    changed_by VARCHAR(100)
);

-- Order audit trail
CREATE TABLE sales.order_audit (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    customer_id INT,
    store_id INT,
    staff_id INT,
    order_date DATE,
    audit_timestamp DATETIME DEFAULT GETDATE()
);
GO
-- 1
CREATE NONCLUSTERED INDEX NIX_Customers_Email
ON sales.customers (email);
-- 2
CREATE NONCLUSTERED INDEX NIX_Products_Category_Brand
ON production.products (category_id, brand_id);

-- 3
CREATE NONCLUSTERED INDEX NIX_Orders_OrderDate
ON sales.orders (order_date)
INCLUDE (customer_id, store_id, order_status);
-- 4
CREATE TRIGGER customer_welcome
ON sales.customers
AFTER INSERT
AS
BEGIN
    INSERT INTO sales.customer_log (customer_id, action)
    SELECT customer_id, 'Welcome'
    FROM inserted;
END;
GO
-- 5
CREATE TRIGGER price_change
ON production.products
AFTER UPDATE
AS
BEGIN
    IF UPDATE(list_price)
    BEGIN
        DECLARE @old_price DECIMAL(10,2);
        DECLARE @new_price DECIMAL(10,2);
        DECLARE @product_id INT;

        SELECT @old_price = list_price FROM deleted;
        SELECT @new_price = list_price, @product_id = product_id FROM inserted;

        INSERT INTO production.price_history (product_id, old_price, new_price, change_date, changed_by)
        VALUES (@product_id, @old_price, @new_price, GETDATE(), USER_NAME());
    END
END;
GO
-- 6
CREATE TRIGGER prevent_category_deletion
ON production.categories
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM production.products WHERE category_id IN (SELECT category_id FROM deleted))
    BEGIN
        RAISERROR('Cannot delete category because there are associated products.', 16, 1);
    END
    ELSE
    BEGIN
        DELETE FROM production.categories WHERE category_id IN (SELECT category_id FROM deleted);
    END
END;
GO
-- 7
CREATE TRIGGER trg_update_stock_quantity
ON sales.order_items
AFTER INSERT
AS
BEGIN
    DECLARE @product_id INT;
    DECLARE @quantity INT;

    SELECT @product_id = product_id, @quantity = quantity FROM inserted;

    UPDATE production.stocks
    SET  quantity =  quantity - @quantity
    WHERE product_id = @product_id;
END;
GO
-- 8
CREATE TRIGGER trg_log_new_orders
ON sales.orders
AFTER INSERT
AS
BEGIN
    INSERT INTO sales.order_audit (order_id, customer_id, store_id, staff_id, order_date)
    SELECT order_id, customer_id, store_id, staff_id, order_date
    FROM inserted;
END;
GO
