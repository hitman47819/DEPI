/*-------1----------*/
/*1.1 List all employees hired after January 1, 2012, showing their ID, first name, last name, and hire date, ordered by hire date descending.*/
use [AdventureWorks2022]
select * from [HumanResources].[Employee] 
where Employee.HireDate >'2012-01-01' 
order by Employee.HireDate desc
/*1.2 List products with a list price between $100 and $500, showing product ID, name, list price, and product number, ordered by list price ascending.*/
select ProductID, Name, ListPrice,ProductNumber from [Production].[Product] 
where ListPrice between 100 and 500 order by ListPrice asc
/*1.3 List customers from the cities 'Seattle' or 'Portland', showing customer ID, first name, last name, and city, using appropriate joins.*/
SELECT c.CustomerID, p.FirstName + ' ' + p.LastName AS name,ad.City
FROM [Sales].[Customer] c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN [Person].[StateProvince] sp ON sp.TerritoryID = c.TerritoryID
JOIN [Person].[Address] ad ON ad.StateProvinceID = sp.StateProvinceID
WHERE ad.City IN ('Seattle', 'Portland')
ORDER BY c.CustomerID ASC;
/*1.4 List the top 15 most expensive products currently being sold, showing name, list price, product number, and category name, excluding discontinued products.*/
SELECT TOP 15  p.Name AS ProductName, p.ListPrice, p.ProductNumber,
pc.Name AS CategoryName
FROM [Production].[Product] p
JOIN [Production].[ProductSubcategory] c ON p.ProductSubcategoryID = c.ProductSubcategoryID
JOIN [Production].[ProductCategory] pc ON c.ProductCategoryID = pc.ProductCategoryID
WHERE p.DiscontinuedDate IS NULL
ORDER BY p.ListPrice DESC;
/*------------2---------*/
/*2.1 List products whose name contains 'Mountain' and color is 'Black', showing product ID, name, color, and list price.*/
select ProductID,Color,name,ListPrice from Production.Product where name like '%Mountain%' and color='Black'
/*2.2 List employees born between January 1, 1970, and December 31, 1985, showing full name, birth date, and age in years.*/
SELECT  p.FirstName + ' ' + p.LastName AS fullname,
e.BirthDate, DATEDIFF(YEAR, e.BirthDate, SYSDATETIME()) AS years
FROM  HumanResources.Employee e
JOIN Person.Person p ON p.BusinessEntityID = e.BusinessEntityID
WHERE  e.BirthDate BETWEEN '1970-01-01' AND '1985-12-31';
/*2.3 List orders placed in the fourth quarter of 2013, showing order ID, order date, customer ID, and total due.*/
select [SalesOrderID],[OrderDate], [CustomerID],[TotalDue] from Sales.SalesOrderHeader where OrderDate between '2013-10-1' and '2013-12-31'
/*2.4 List products with a null weight but a non-null size, showing product ID, name, weight, size, and product number.*/
select ProductID,Name,Weight,Size,ProductNumber from Production.Product where Weight is null and size is not null
/*------------3---------*/
/* 3.1 Count the number of products by category, ordered by count descending.*/
select count(productid) as num,c.Name from Production.Product p
join Production.ProductSubcategory sc on sc.ProductSubcategoryID=p.ProductSubcategoryID
join Production.ProductCategory c on c.ProductCategoryID =sc.ProductCategoryID
group by c.Name
order by num desc
/* 3.2 Show the average list price by product subcategory, including only subcategories with more than five products.*/
select AVG(p.ListPrice) as avg_ListPrice,sc.Name from Production.Product p
join Production.ProductSubcategory sc on sc.ProductSubcategoryID=p.ProductSubcategoryID 
group by p.ProductSubcategoryID,sc.Name
having count(p.ProductID)>5
/*3.3 List the top 10 customers by total order count, including customer name.*/
SELECT TOP 10 COUNT(o.SalesOrderID) AS OrderCount,
 p.FirstName + ' ' + p.LastName AS FullName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader o ON o.CustomerID = c.CustomerID
JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
GROUP BY p.FirstName, p.LastName
ORDER BY OrderCount DESC;
/*3.4 Show monthly sales totals for 2013, displaying the month name and total amount.*/
SELECT DATENAME(MONTH, OrderDate) AS MonthName,  SUM(TotalDue) AS TotalAmount
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
GROUP BY DATENAME(MONTH, OrderDate), MONTH(OrderDate)
ORDER BY MONTH(OrderDate)

/*------------4---------*/
/*4.1 Find all products launched in the same year as 'Mountain-100 Black, 42'. Show product ID, name, sell start date, and year.*/
SELECT ProductID, Name, SellStartDate, YEAR(SellStartDate) AS LaunchYear
FROM Production.Product
WHERE YEAR(SellStartDate) = (
    SELECT YEAR(SellStartDate)
    FROM Production.Product
    WHERE Name = 'Mountain-100 Black, 42'
);

/*4.2 Find employees who were hired on the same date as someone else. Show employee names, shared hire date, and the count of employees hired that day.*/
SELECT p.FirstName + ' ' + p.LastName AS EmployeeName,  e.HireDate,  x.EmployeesHiredSameDay
FROM HumanResources.Employee e
JOIN Person.Person p  ON p.BusinessEntityID = e.BusinessEntityID
JOIN (
    SELECT HireDate, COUNT(*) AS EmployeesHiredSameDay
    FROM HumanResources.Employee
    GROUP BY HireDate
    HAVING COUNT(*) > 1
) x ON e.HireDate = x.HireDate
ORDER BY e.HireDate;

/*------------5---------*/
/*5.1 Create a table named Sales.ProductReviews with columns for review ID, product ID, customer ID, rating, review date, review text, verified purchase flag, and helpful votes. Include appropriate primary key, foreign keys, check constraints, defaults, and a unique constraint on product ID and customer ID.*/

CREATE TABLE Sales.ProductReviews (
    review_id INT PRIMARY KEY,   
    product_id INT,            
    customer_id INT,           
    rating INT CHECK (rating BETWEEN 1 AND 5),   
    review_date DATE DEFAULT CAST(GETDATE() AS DATE),   
    review_text TEXT,           
    verified_purchase BIT DEFAULT 0,  -- boolean values (0 for FALSE, 1 for TRUE)
    helpful_votes INT DEFAULT 0,  
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES Production.Product(ProductID),  
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES Sales.Customer(CustomerID),  
    CONSTRAINT unique_product_customer UNIQUE (product_id, customer_id)  
);
/*------------6---------*/

/*6.1 Add a column named LastModifiedDate to the Production.Product table, with a default value of the current date and time.*/
ALTER TABLE Production.Product
ADD LastModifiedDate DATETIME DEFAULT GETDATE();
/*6.2 Create a non-clustered index on the LastName column of the Person.Person table, including FirstName and MiddleName.*/
CREATE NONCLUSTERED INDEX IX_Person_LastName
ON Person.Person (LastName)
INCLUDE (FirstName, MiddleName);
/*6.3 Add a check constraint to the Production.Product table to ensure that ListPrice is greater than StandardCost.*/
alter table Production.Product
add CONSTRAINT checklistprice check(ListPrice>StandardCost)

/*------------7---------*/
/*7.1 Insert three sample records into Sales.ProductReviews using existing product and customer IDs, with varied ratings and meaningful review text. */

INSERT INTO Sales.ProductReviews
    (review_id, product_id, customer_id, rating, review_text, verified_purchase, helpful_votes)
VALUES
    (1, 1, 1, 5,
     'Excellent quality and quick delivery. Perfect fit for my bike!',
     1, 3),

    (2, 2, 2, 4,
     'Very durable bearing ball, works smoothly after weeks of use.',
     1, 2),

    (3, 316, 3, 3,
     'Blade performs well, though sharpening was required before use.',
     0, 1);
/*
7.2 Insert a new product category named 'Electronics' and a corresponding product subcategory named 'Smartphones' under Electronics.
*/
INSERT INTO Production.ProductCategory (Name, rowguid, ModifiedDate)
VALUES (
    'Electronics',
    NEWID(),                
    GETDATE()
);

INSERT INTO Production.ProductSubcategory (ProductCategoryID, Name, rowguid, ModifiedDate)
VALUES (
    (SELECT ProductCategoryID
     FROM Production.ProductCategory
     WHERE Name = 'Electronics'),
    'Smartphones',
    NEWID(),
    GETDATE()
);

/*
7.3 Copy all discontinued products (where SellEndDate is not null) into a new table named Sales.DiscontinuedProducts.
*/ 
SELECT *
INTO Sales.DiscontinuedProducts
FROM Production.Product
WHERE 1 = 0; 

INSERT INTO Sales.DiscontinuedProducts
      (Name, ProductNumber, MakeFlag, FinishedGoodsFlag, Color,
       SafetyStockLevel, ReorderPoint, StandardCost, ListPrice,
       Size, SizeUnitMeasureCode, WeightUnitMeasureCode, Weight,
       DaysToManufacture, ProductLine, Class, Style,
       ProductSubcategoryID, ProductModelID,
       SellStartDate, SellEndDate, DiscontinuedDate,
       rowguid, ModifiedDate)
SELECT  Name, ProductNumber, MakeFlag, FinishedGoodsFlag, Color,
        SafetyStockLevel, ReorderPoint, StandardCost, ListPrice,
        Size, SizeUnitMeasureCode, WeightUnitMeasureCode, Weight,
        DaysToManufacture, ProductLine, Class, Style,
        ProductSubcategoryID, ProductModelID,
        SellStartDate, SellEndDate, DiscontinuedDate,
        rowguid, ModifiedDate
FROM Production.Product
WHERE SellEndDate IS NOT NULL;

/*------------8---------*/
/* Update the ModifiedDate to the current date for all products where ListPrice is greater than $1000 and SellEndDate is null */
UPDATE Production.Product
SET ModifiedDate = GETDATE()
WHERE ListPrice > 1000 AND SellEndDate IS NULL;

/* Increase the ListPrice by 15% for all products in the 'Bikes' category and update the ModifiedDate */

UPDATE Production.Product 
SET ListPrice = ListPrice + ListPrice / 100 * 15
FROM Production.Product 
WHERE ProductSubcategoryID IN (
SELECT ProductSubcategoryID
FROM Production.ProductSubcategory
WHERE ProductCategoryID = 1)
/* Update the JobTitle to 'Senior' plus the existing job title for employees hired before January 1, 2010 */
update HumanResources.Employee
set JobTitle='Senior '+JobTitle
FROM HumanResources.Employee
where HireDate<'2010-01-01'
/*------------9---------*/
/* Delete all product reviews with a rating of 1 and helpful votes equal to 0 */
DELETE FROM Sales.ProductReviews
WHERE Rating = 1 AND helpful_votes = 0;

/* Delete products that have never been ordered, using a NOT EXISTS condition with Sales.SalesOrderDetail */

 DELETE FROM Production.ProductListPriceHistory
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS SOD
    WHERE SOD.ProductID =  Production.ProductListPriceHistory.ProductID
);
 DELETE FROM Production.ProductCostHistory
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS SOD
    WHERE SOD.ProductID =  Production.ProductCostHistory.ProductID
);
 DELETE FROM Sales.SpecialOfferProduct
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS SOD
    WHERE SOD.ProductID =  Sales.SpecialOfferProduct.ProductID
);
 DELETE FROM Production.BillOfMaterials
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS SOD
    WHERE SOD.ProductID = Production.BillOfMaterials.ProductAssemblyID
);
 DELETE FROM Production.ProductDocument
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS SOD
    WHERE SOD.ProductID = Production.ProductDocument.ProductID
);
 DELETE FROM Purchasing.ProductVendor 
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS SOD
    WHERE SOD.ProductID = Purchasing.ProductVendor.ProductID
);
DELETE FROM Purchasing.PurchaseOrderDetail 
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS SOD
    WHERE SOD.ProductID = Purchasing.PurchaseOrderDetail.ProductID
);
DELETE FROM Production.TransactionHistory
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS SOD
    WHERE SOD.ProductID = Production.TransactionHistory.ProductID
);
DELETE FROM Production.BillOfMaterials
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS SOD
    WHERE SOD.ProductID = Production.BillOfMaterials.ComponentID
);
DELETE FROM Sales.ProductReviews
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS SOD
    WHERE SOD.ProductID = Sales.ProductReviews.product_id
);
DELETE FROM Production.WorkOrderRouting
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS SOD
    WHERE SOD.ProductID = Production.WorkOrderRouting.ProductID
);
 
DELETE FROM Production.WorkOrder
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS SOD
    WHERE SOD.ProductID = Production.WorkOrder.ProductID
);
 DELETE FROM Production.Product  
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail AS SOD
    WHERE SOD.ProductID = Production.Product.ProductID
);
/* Delete all purchase orders from vendors that are no longer active */
DELETE FROM Purchasing.PurchaseOrderHeader
WHERE VendorID IN (
    SELECT V.BusinessEntityID
    FROM Purchasing.Vendor AS V
    WHERE V.ActiveFlag = 0
);

/*------------10---------*/
/* Calculate the total sales amount by year from 2011 to 2014, showing year, total sales, average order value, and order count */
SELECT
    YEAR(SOH.OrderDate) AS SalesYear,
    SUM(SOH.TotalDue)   AS TotalSales,
    AVG(SOH.TotalDue)   AS AvgOrderValue,
    COUNT(*)            AS OrderCount
FROM Sales.SalesOrderHeader AS SOH
WHERE YEAR(SOH.OrderDate) BETWEEN 2011 AND 2014
GROUP BY YEAR(SOH.OrderDate)
ORDER BY SalesYear;

/* For each customer, show customer ID, total orders, total amount, average order value, first order date, and last order date */
SELECT
    SOH.CustomerID,
    COUNT(*)               AS TotalOrders,
    SUM(SOH.TotalDue)      AS TotalAmount,
    AVG(SOH.TotalDue)      AS AvgOrderValue,
    MIN(SOH.OrderDate)     AS FirstOrderDate,
    MAX(SOH.OrderDate)     AS LastOrderDate
FROM Sales.SalesOrderHeader AS SOH
GROUP BY SOH.CustomerID
ORDER BY TotalAmount DESC;  

/* List the top 20 products by total sales amount, including product name, category, total quantity sold, and total revenue */
SELECT TOP 20
    P.Name                              AS ProductName,
    PC.Name                             AS Category,
    SUM(SOD.OrderQty)                    AS TotalQuantitySold,
    SUM(SOD.LineTotal)                   AS TotalRevenue
FROM Sales.SalesOrderDetail  AS SOD
JOIN Production.Product      AS P  ON P.ProductID = SOD.ProductID
JOIN Production.ProductSubcategory AS PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
JOIN Production.ProductCategory   AS PC  ON PSC.ProductCategoryID   = PC.ProductCategoryID
GROUP BY P.Name, PC.Name
ORDER BY TotalRevenue DESC;

/* Show sales amount by month for 2013, displaying the month name, sales amount, and percentage of the yearly total */
WITH MonthlySales AS (
    SELECT
        DATENAME(MONTH, SOH.OrderDate) AS MonthName,
        MONTH(SOH.OrderDate)           AS MonthNumber,
        SUM(SOH.TotalDue)              AS MonthlyTotal
    FROM Sales.SalesOrderHeader AS SOH
    WHERE YEAR(SOH.OrderDate) = 2013
    GROUP BY DATENAME(MONTH, SOH.OrderDate), MONTH(SOH.OrderDate)
),
YearTotal AS (
    SELECT SUM(MonthlyTotal) AS YearlyTotal
    FROM MonthlySales
)
SELECT
    M.MonthName,
    M.MonthlyTotal,
    CAST(M.MonthlyTotal * 100.0 / Y.YearlyTotal AS DECIMAL(5,2)) AS PctOfYear
FROM MonthlySales AS M
CROSS JOIN YearTotal AS Y
ORDER BY M.MonthNumber;

/*------------11---------*/
/* Show employees with their full name, age in years, years of service, hire date formatted as 'Mon DD, YYYY', and birth month name */
SELECT
    P.FirstName + ' ' + ISNULL(P.MiddleName + ' ', '') + P.LastName AS FullName,
    DATEDIFF(YEAR, E.BirthDate, GETDATE())                          AS AgeYears,
    DATEDIFF(YEAR, E.HireDate,  GETDATE())                           AS YearsOfService,
    FORMAT(E.HireDate, 'MMM dd, yyyy')                               AS HireDateFormatted,
    DATENAME(MONTH,E.BirthDate)                                     AS BirthMonth
FROM HumanResources.Employee AS E
JOIN Person.Person AS P
     ON E.BusinessEntityID = P.BusinessEntityID;

/* Format customer names as 'LAST, First M.' (with middle initial), extract the email domain, and apply proper case formatting */
SELECT
    UPPER(P.LastName) + ', ' +
    CONCAT(
        UPPER(LEFT(P.FirstName,1)), LOWER(SUBSTRING(P.FirstName,2,LEN(P.FirstName)))
    ) + ' ' +
    CASE WHEN P.MiddleName IS NOT NULL
         THEN UPPER(LEFT(P.MiddleName,1)) + '.'
         ELSE ''
    END    AS FormattedName,
    RIGHT(EmailAddress, LEN(EmailAddress) - CHARINDEX('@', EmailAddress)) AS EmailDomain
FROM Person.Person AS P
JOIN Person.EmailAddress AS EA
     ON P.BusinessEntityID = EA.BusinessEntityID;

/* For each product, show name, weight rounded to one decimal, weight in pounds (converted from grams), and price per pound */
SELECT
    P.Name,
    ROUND(P.Weight, 1)                         AS Weight_Grams,
    ROUND(P.Weight / 453.59237, 2)             AS Weight_Pounds,
    CASE WHEN P.Weight IS NOT NULL AND P.Weight > 0
         THEN P.ListPrice / (P.Weight / 453.59237)
         ELSE NULL
    END   AS PricePerPound
FROM Production.Product AS P
WHERE P.Weight IS NOT NULL;

/*------------12---------*/
/* List product name, category, subcategory, and vendor name for products that have been purchased from vendors */
SELECT
    PR.Name                    AS ProductName,
    PC.Name                    AS Category,
    PSC.Name                   AS SubCategory,
    V.Name                     AS VendorName
FROM Production.Product               AS PR
JOIN Production.ProductSubcategory    AS PSC ON PR.ProductSubcategoryID = PSC.ProductSubcategoryID
JOIN Production.ProductCategory       AS PC  ON PSC.ProductCategoryID   = PC.ProductCategoryID
JOIN Purchasing.ProductVendor         AS PV  ON PR.ProductID            = PV.ProductID
JOIN Purchasing.Vendor                AS V   ON PV.BusinessEntityID     = V.BusinessEntityID;

/* Show order details including order ID, customer name, salesperson name, territory name, product name, quantity, and line total */
SELECT
    SOH.SalesOrderID,
    CUST.PersonID,
    CP.FirstName + ' ' + CP.LastName           AS CustomerName,
    SP.FirstName + ' ' + SP.LastName           AS SalesPersonName,
    ST.Name                                    AS TerritoryName,
    PR.Name                                       AS ProductName,
    SOD.OrderQty,
    SOD.LineTotal
FROM Sales.SalesOrderHeader  AS SOH
JOIN Sales.Customer          AS CUST ON SOH.CustomerID   = CUST.CustomerID
JOIN Person.Person           AS CP   ON CUST.PersonID    = CP.BusinessEntityID
JOIN Sales.SalesPerson       AS SPN  ON SOH.SalesPersonID = SPN.BusinessEntityID
JOIN Person.Person           AS SP   ON SPN.BusinessEntityID = SP.BusinessEntityID
JOIN Sales.SalesTerritory    AS ST   ON SOH.TerritoryID  = ST.TerritoryID
JOIN Sales.SalesOrderDetail  AS SOD  ON SOH.SalesOrderID = SOD.SalesOrderID
JOIN Production.Product      AS PR   ON SOD.ProductID    = PR.ProductID;

/* List employees with their sales territories, including employee name, job title, territory name, territory group, and sales year-to-date */
SELECT
    P.FirstName + ' ' + P.LastName AS EmployeeName,
    E.JobTitle,
    ST.Name                        AS TerritoryName,
    ST.[Group]                     AS TerritoryGroup,
    SP.SalesYTD
FROM Sales.SalesPerson        AS SP
JOIN HumanResources.Employee  AS E ON SP.BusinessEntityID = E.BusinessEntityID
JOIN Person.Person            AS P ON E.BusinessEntityID = P.BusinessEntityID
JOIN Sales.SalesTerritory     AS ST ON SP.TerritoryID    = ST.TerritoryID;

/*------------13---------*/
/* List all products with their total sales, including those never sold. Show product name, category, total quantity sold (zero if never sold), and total revenue (zero if never sold) */
SELECT
    P.Name                              AS ProductName,
    PC.Name                             AS Category,
    ISNULL(SUM(SOD.OrderQty), 0)        AS TotalQuantitySold,
    ISNULL(SUM(SOD.LineTotal), 0.0)     AS TotalRevenue
FROM Production.Product            AS P
LEFT JOIN Production.ProductSubcategory AS PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
LEFT JOIN Production.ProductCategory   AS PC  ON PSC.ProductCategoryID   = PC.ProductCategoryID
LEFT JOIN Sales.SalesOrderDetail       AS SOD ON P.ProductID            = SOD.ProductID
GROUP BY P.Name, PC.Name
ORDER BY TotalRevenue DESC;

/* Show all sales territories with their assigned employees, including unassigned territories. Show territory name, employee name (null if unassigned), and sales year-to-date */
SELECT
    ST.Name                                   AS TerritoryName,
    P.FirstName + ' ' + P.LastName            AS EmployeeName,
    SP.SalesYTD
FROM Sales.SalesTerritory AS ST
LEFT JOIN Sales.SalesPerson AS SP
       ON ST.TerritoryID = SP.TerritoryID
LEFT JOIN Person.Person AS P
       ON SP.BusinessEntityID = P.BusinessEntityID
ORDER BY TerritoryName;

/* Show the relationship between vendors and product categories, including vendors with no products and categories with no vendors */
SELECT
    V.Name        AS VendorName,
    VC.CategoryName
FROM Purchasing.Vendor AS V
FULL OUTER JOIN (
    SELECT DISTINCT
        PV.BusinessEntityID,
        PC.Name AS CategoryName
    FROM Purchasing.ProductVendor AS PV
    JOIN Production.Product              AS P   ON PV.ProductID = P.ProductID
    JOIN Production.ProductSubcategory   AS PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory      AS PC  ON PSC.ProductCategoryID   = PC.ProductCategoryID
) AS VC
    ON V.BusinessEntityID = VC.BusinessEntityID
ORDER BY VendorName, VC.CategoryName;


/*------------14---------*/
/* List products with above-average list price, showing product ID, name, list price, and price difference from the average */
SELECT
    ProductID,
    Name,
    ListPrice,
    ListPrice - (SELECT AVG(ListPrice) FROM Production.Product) AS PriceDifference
FROM Production.Product
WHERE ListPrice > (SELECT AVG(ListPrice) FROM Production.Product);

/* List customers who bought products from the 'Mountain' category, showing customer name, total orders, and total amount spent */
SELECT
    C.CustomerID,
    P.FirstName + ' ' + P.LastName              AS CustomerName,
    COUNT(DISTINCT SOH.SalesOrderID)            AS TotalOrders,
    SUM(SOD.LineTotal)                           AS TotalAmountSpent
FROM Sales.SalesOrderHeader  AS SOH
JOIN Sales.Customer          AS C   ON SOH.CustomerID = C.CustomerID
JOIN Person.Person           AS P   ON C.PersonID     = P.BusinessEntityID
JOIN Sales.SalesOrderDetail  AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
JOIN Production.Product      AS PR  ON SOD.ProductID  = PR.ProductID
JOIN Production.ProductSubcategory PSC ON PR.ProductSubcategoryID = PSC.ProductSubcategoryID
JOIN Production.ProductCategory   PC  ON PSC.ProductCategoryID   = PC.ProductCategoryID
WHERE PC.Name = 'Mountain'
GROUP BY C.CustomerID, P.FirstName, P.LastName
ORDER BY TotalAmountSpent DESC;

/* List products that have been ordered by more than 100 different customers, showing product name, category, and unique customer count */
SELECT
    PR.Name            AS ProductName,
    PC.Name            AS Category,
    COUNT(DISTINCT SOH.CustomerID) AS UniqueCustomerCount
FROM Sales.SalesOrderDetail  AS SOD
JOIN Production.Product      AS PR  ON SOD.ProductID = PR.ProductID
JOIN Production.ProductSubcategory PSC ON PR.ProductSubcategoryID = PSC.ProductSubcategoryID
JOIN Production.ProductCategory   PC  ON PSC.ProductCategoryID   = PC.ProductCategoryID
JOIN Sales.SalesOrderHeader SOH   ON SOD.SalesOrderID = SOH.SalesOrderID
GROUP BY PR.Name, PC.Name
HAVING COUNT(DISTINCT SOH.CustomerID) > 100
ORDER BY UniqueCustomerCount DESC;

/* For each customer, show their order count and their rank among all customers */
SELECT
    C.CustomerID,
    P.FirstName + ' ' + P.LastName     AS CustomerName,
    COUNT(SOH.SalesOrderID)            AS OrderCount,
    RANK() OVER (ORDER BY COUNT(SOH.SalesOrderID) DESC) AS CustomerRank
FROM Sales.Customer        AS C
JOIN Person.Person         AS P   ON C.PersonID = P.BusinessEntityID
JOIN Sales.SalesOrderHeader AS SOH ON C.CustomerID = SOH.CustomerID
GROUP BY C.CustomerID, P.FirstName, P.LastName
ORDER BY CustomerRank;

/*------------15---------*/
/* Create a view named vw_ProductCatalog with product ID, name, product number, category, subcategory, list price, standard cost, profit margin percentage, inventory level, and status (active/discontinued) */
CREATE VIEW vw_ProductCatalog AS
SELECT
    P.ProductID,
    P.Name,
    P.ProductNumber,
    PC.Name AS Category,
    PSC.Name AS SubCategory,
    P.ListPrice,
    P.StandardCost,
    CASE WHEN P.ListPrice > 0
         THEN ROUND((P.ListPrice - P.StandardCost) / P.ListPrice * 100, 2)
         ELSE NULL
    END AS ProfitMarginPct,
    ISNULL(PI.Quantity, 0) AS InventoryLevel,
    CASE WHEN P.DiscontinuedDate IS NULL THEN 'Active' ELSE 'Discontinued' END AS Status
FROM Production.Product P
LEFT JOIN Production.ProductSubcategory PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
LEFT JOIN Production.ProductCategory   PC  ON PSC.ProductCategoryID   = PC.ProductCategoryID
LEFT JOIN Production.ProductInventory  PI  ON P.ProductID = PI.ProductID;
   
/* Create a view named vw_SalesAnalysis with year, month, territory, total sales, order count, average order value, and top product name */
CREATE OR ALTER VIEW vw_SalesAnalysis AS
WITH Base AS (
    SELECT
        YEAR(SOH.OrderDate)  AS SalesYear,
        MONTH(SOH.OrderDate) AS SalesMonth,
        SOH.TerritoryID,
        SOD.ProductID,
        SUM(SOD.LineTotal)   AS ProductSales
    FROM Sales.SalesOrderHeader AS SOH
    JOIN Sales.SalesOrderDetail AS SOD
        ON SOH.SalesOrderID = SOD.SalesOrderID
    GROUP BY YEAR(SOH.OrderDate), MONTH(SOH.OrderDate),
             SOH.TerritoryID, SOD.ProductID
),
TopProduct AS (
    SELECT *
    FROM (
        SELECT
            b.SalesYear,
            b.SalesMonth,
            b.TerritoryID,
            b.ProductID,
            ROW_NUMBER() OVER (
                PARTITION BY b.SalesYear, b.SalesMonth, b.TerritoryID
                ORDER BY b.ProductSales DESC
            ) AS rn
        FROM Base b
    ) t
    WHERE rn = 1
),
Totals AS (
    SELECT
        YEAR(SOH.OrderDate)  AS SalesYear,
        MONTH(SOH.OrderDate) AS SalesMonth,
        SOH.TerritoryID,
        SUM(SOD.LineTotal)   AS TotalSales,
        COUNT(DISTINCT SOH.SalesOrderID) AS OrderCount,
        AVG(SOH.TotalDue)    AS AvgOrderValue
    FROM Sales.SalesOrderHeader AS SOH
    JOIN Sales.SalesOrderDetail AS SOD
        ON SOH.SalesOrderID = SOD.SalesOrderID
    GROUP BY YEAR(SOH.OrderDate), MONTH(SOH.OrderDate), SOH.TerritoryID
)
SELECT
    t.SalesYear,
    t.SalesMonth,
    st.Name           AS Territory,
    tot.TotalSales,
    tot.OrderCount,
    tot.AvgOrderValue,
    p.Name            AS TopProductName
FROM Totals tot
JOIN TopProduct t
     ON  t.SalesYear   = tot.SalesYear
     AND t.SalesMonth  = tot.SalesMonth
     AND t.TerritoryID = tot.TerritoryID
JOIN Production.Product p
     ON p.ProductID   = t.ProductID
JOIN Sales.SalesTerritory st
     ON st.TerritoryID = tot.TerritoryID; 

/* Create a view named vw_EmployeeDirectory with full name, job title, department, manager name, hire date, years of service, email, and phone */
CREATE VIEW vw_EmployeeDirectory AS
SELECT
    P.FirstName + ' ' + ISNULL(P.MiddleName + ' ', '') + P.LastName AS FullName,
    E.JobTitle,
    D.Name AS Department,
    Mgr.FirstName + ' ' + Mgr.LastName AS ManagerName,
    E.HireDate,
    DATEDIFF(YEAR, E.HireDate, GETDATE()) AS YearsOfService,
    EA.EmailAddress,
    PP.PhoneNumber
FROM HumanResources.Employee E
JOIN Person.Person P           ON E.BusinessEntityID = P.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory EDH ON E.BusinessEntityID = EDH.BusinessEntityID AND EDH.EndDate IS NULL
JOIN HumanResources.Department D    ON EDH.DepartmentID = D.DepartmentID
LEFT JOIN HumanResources.Employee M ON E.OrganizationNode.GetAncestor(1) = M.OrganizationNode
LEFT JOIN Person.Person Mgr         ON M.BusinessEntityID = Mgr.BusinessEntityID
LEFT JOIN Person.EmailAddress EA    ON P.BusinessEntityID = EA.BusinessEntityID
LEFT JOIN Person.PersonPhone PP     ON P.BusinessEntityID = PP.BusinessEntityID;

/* Write three different queries using the views you created, demonstrating practical business scenarios */


SELECT Name, ListPrice, ProfitMarginPct
FROM vw_ProductCatalog
WHERE ProfitMarginPct > 40
ORDER BY ProfitMarginPct DESC;


SELECT SalesMonth, TotalSales
FROM vw_SalesAnalysis
WHERE SalesYear = 2011  AND Territory = 'Northwest'
ORDER BY SalesMonth;

SELECT FullName, Department, HireDate, YearsOfService
FROM vw_EmployeeDirectory
WHERE YearsOfService >= 10
ORDER BY YearsOfService DESC;

/*------------16---------*/
/* Classify products by price as 'Premium' (greater than $500), 'Standard' ($100 to $500), or 'Budget' (less than $100), and show the count and average price for each category */
SELECT
  PriceClass,
  COUNT(*)       AS ProductCount,
  ROUND(AVG(ListPrice),2) AS AvgPrice
FROM (
  SELECT
    ProductID,
    ListPrice,
    CASE
      WHEN ListPrice > 500 THEN 'Premium'
      WHEN ListPrice >= 100 THEN 'Standard'
      ELSE 'Budget'
    END AS PriceClass
  FROM Production.Product
) AS x
GROUP BY PriceClass
ORDER BY 
  CASE PriceClass WHEN 'Premium' THEN 1 WHEN 'Standard' THEN 2 WHEN 'Budget' THEN 3 END;

/* Classify employees by years of service as 'Veteran' (10+ years), 'Experienced' (5-10 years), 'Regular' (2-5 years), or 'New' (less than 2 years), and show salary statistics for each group */
SELECT
    ServiceClass,
    COUNT(*) AS EmployeeCount,
    MIN(PayRate) AS MinSalary,
    MAX(PayRate) AS MaxSalary,
    ROUND(AVG(CAST(PayRate AS DECIMAL(18,2))),2) AS AvgSalary
FROM (
    SELECT
        e.BusinessEntityID,
        e.HireDate,
        DATEDIFF(YEAR, e.HireDate, GETDATE()) AS YearsService,
        ep.Rate AS PayRate,   
        CASE
            WHEN DATEDIFF(YEAR, e.HireDate, GETDATE()) >= 10 THEN 'Veteran'
            WHEN DATEDIFF(YEAR, e.HireDate, GETDATE()) >= 5  THEN 'Experienced'
            WHEN DATEDIFF(YEAR, e.HireDate, GETDATE()) >= 2  THEN 'Regular'
            ELSE 'New'
        END AS ServiceClass
    FROM HumanResources.Employee AS e
    INNER JOIN (
        SELECT eph.BusinessEntityID, eph.Rate
        FROM HumanResources.EmployeePayHistory AS eph
        WHERE eph.RateChangeDate = (
            SELECT MAX(RateChangeDate)
            FROM HumanResources.EmployeePayHistory
            WHERE BusinessEntityID = eph.BusinessEntityID
        )
    ) AS ep ON e.BusinessEntityID = ep.BusinessEntityID
) AS t
GROUP BY ServiceClass
ORDER BY 
    CASE ServiceClass 
         WHEN 'Veteran' THEN 1 
         WHEN 'Experienced' THEN 2 
         WHEN 'Regular' THEN 3 
         WHEN 'New' THEN 4 
    END;

/* Classify orders by size as 'Large' (greater than $5000), 'Medium' ($1000 to $5000), or 'Small' (less than $1000), and show the percentage distribution */
WITH Orders AS (
  SELECT
    SalesOrderID,
    TotalDue,
    CASE
      WHEN TotalDue > 5000 THEN 'Large'
      WHEN TotalDue >= 1000 THEN 'Medium'
      ELSE 'Small'
    END AS SizeClass
  FROM Sales.SalesOrderHeader
)
SELECT
  SizeClass,
  COUNT(*) AS OrderCount,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS PctOfOrders
FROM Orders
GROUP BY SizeClass
ORDER BY 
  CASE SizeClass WHEN 'Large' THEN 1 WHEN 'Medium' THEN 2 WHEN 'Small' THEN 3 END;

/*------------17---------*/
/* Show products with name, weight (display 'Not Specified' if null), size (display 'Standard' if null), and color (display 'Natural' if null) */
SELECT
  p.ProductID,
  p.Name,
  CASE WHEN p.Weight IS NULL THEN 'Not Specified' ELSE CAST(p.Weight AS VARCHAR(50)) END AS Weight,
  ISNULL(NULLIF(p.Size,''), 'Standard') AS Size,
  ISNULL(NULLIF(p.Color,''), 'Natural') AS Color
FROM Production.Product p;

/* For each customer, display the best available contact method, prioritizing email address, then phone, then address line */
SELECT
  c.CustomerID,
  per.FirstName + ' ' + per.LastName AS CustomerName,
  COALESCE(ea.EmailAddress,
           pp.PhoneNumber,
           addr.AddressLine1 + ISNULL(', ' + addr.City, '')
  ) AS BestContact,
  CASE 
    WHEN ea.EmailAddress IS NOT NULL THEN 'Email'
    WHEN pp.PhoneNumber IS NOT NULL THEN 'Phone'
    ELSE 'Address'
  END AS ContactType
FROM Sales.Customer c
JOIN Person.Person per ON c.PersonID = per.BusinessEntityID
LEFT JOIN (
  SELECT BusinessEntityID, MIN(EmailAddress) AS EmailAddress
  FROM Person.EmailAddress GROUP BY BusinessEntityID
) ea ON per.BusinessEntityID = ea.BusinessEntityID
LEFT JOIN (
  SELECT BusinessEntityID, MIN(PhoneNumber) AS PhoneNumber
  FROM Person.PersonPhone GROUP BY BusinessEntityID
) pp ON per.BusinessEntityID = pp.BusinessEntityID
LEFT JOIN Person.BusinessEntityAddress bea ON per.BusinessEntityID = bea.BusinessEntityID
LEFT JOIN Person.Address addr ON bea.AddressID = addr.AddressID;


/* Find products where weight is null but size is not null, and also find products where both weight and size are null. Discuss the impact on inventory management */
SELECT ProductID, Name FROM Production.Product
WHERE Weight IS NULL AND (Size IS NOT NULL AND Size <> '');

SELECT ProductID, Name FROM Production.Product
WHERE Weight IS NULL AND (Size IS NULL OR Size = '');

/*------------18---------*/
/* Create a recursive query to show the complete employee hierarchy, including employee name, manager name, hierarchy level, and path */
WITH Emp AS
(
    SELECT 
        e.BusinessEntityID,
        p.FirstName + ' ' + p.LastName AS EmpName,
        e.OrganizationNode
    FROM HumanResources.Employee e
    JOIN Person.Person p
        ON e.BusinessEntityID = p.BusinessEntityID
),
Hierarchy AS
(
    SELECT
        BusinessEntityID,
        EmpName,
        OrganizationNode,
        0 AS Level,
        CAST(EmpName AS VARCHAR(MAX)) AS Path
    FROM Emp
    WHERE OrganizationNode.GetLevel() = 0

    UNION ALL

    SELECT
        e.BusinessEntityID,
        e.EmpName,
        e.OrganizationNode,
        h.Level + 1,
        CAST(h.Path + ' > ' + e.EmpName AS VARCHAR(MAX))
    FROM Emp e
    JOIN Hierarchy h
        ON e.OrganizationNode.GetAncestor(1) = h.OrganizationNode
)
SELECT BusinessEntityID, EmpName, Level, Path
FROM Hierarchy
ORDER BY Path;

/* Create a query to compare year-over-year sales for each product, showing product, sales for 2013, sales for 2014, growth percentage, and growth category */
WITH ProdSales AS (
  SELECT
    p.ProductID,
    p.Name AS ProductName,
    YEAR(soh.OrderDate) AS SalesYear,
    SUM(sod.LineTotal) AS SalesAmount
  FROM Sales.SalesOrderHeader soh
  JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
  JOIN Production.Product p ON sod.ProductID = p.ProductID
  WHERE YEAR(soh.OrderDate) IN (2013,2014)
  GROUP BY p.ProductID, p.Name, YEAR(soh.OrderDate)
),
Pivoted AS (
  SELECT
    ProductID,
    ProductName,
    ISNULL(MAX(CASE WHEN SalesYear = 2013 THEN SalesAmount END),0) AS Sales2013,
    ISNULL(MAX(CASE WHEN SalesYear = 2014 THEN SalesAmount END),0) AS Sales2014
  FROM ProdSales
  GROUP BY ProductID, ProductName
)
SELECT
  ProductID,
  ProductName,
  Sales2013,
  Sales2014,
  CASE WHEN Sales2013 = 0 AND Sales2014 = 0 THEN 0
       WHEN Sales2013 = 0 THEN 100.0
       ELSE ROUND( (Sales2014 - Sales2013) * 100.0 / NULLIF(Sales2013,0), 2)
  END AS GrowthPct,
  CASE
    WHEN Sales2014 >= Sales2013 * 1.2 THEN 'Strong Growth'
    WHEN Sales2014 >= Sales2013 THEN 'Moderate Growth'
    WHEN Sales2014 > 0 THEN 'Decline'
    ELSE 'No Sales'
  END AS GrowthCategory
FROM Pivoted
ORDER BY GrowthPct DESC;

/*------------19---------*/
/* Rank products by sales within each category, showing product name, category, sales amount, rank, dense rank, and row number */
WITH ProdCategorySales AS (
  SELECT
    pc.ProductCategoryID,
    pc.Name AS CategoryName,
    p.ProductID,
    p.Name AS ProductName,
    SUM(sod.LineTotal) AS SalesAmount
  FROM Sales.SalesOrderDetail sod
  JOIN Production.Product p ON sod.ProductID = p.ProductID
  LEFT JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
  LEFT JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
  GROUP BY pc.ProductCategoryID, pc.Name, p.ProductID, p.Name
)
SELECT
  CategoryName,
  ProductName,
  SalesAmount,
  RANK()    OVER (PARTITION BY CategoryName ORDER BY SalesAmount DESC) AS RankInCategory,
  DENSE_RANK() OVER (PARTITION BY CategoryName ORDER BY SalesAmount DESC) AS DenseRankInCategory,
  ROW_NUMBER() OVER (PARTITION BY CategoryName ORDER BY SalesAmount DESC) AS RowNumInCategory
FROM ProdCategorySales
ORDER BY CategoryName, SalesAmount DESC;

/* Show the running total of sales by month for 2013, displaying month, monthly sales, running total, and percentage of year-to-date */
WITH Monthly AS (
  SELECT
    MONTH(soh.OrderDate) AS Mth,
    DATENAME(MONTH, soh.OrderDate) AS MonthName,
    SUM(sod.LineTotal) AS MonthlySales
  FROM Sales.SalesOrderHeader soh
  JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
  WHERE YEAR(soh.OrderDate) = 2013
  GROUP BY MONTH(soh.OrderDate), DATENAME(MONTH, soh.OrderDate)
)
SELECT
  Mth,
  MonthName,
  MonthlySales,
  SUM(MonthlySales) OVER (ORDER BY Mth ROWS UNBOUNDED PRECEDING) AS RunningTotal,
  ROUND(100.0 * SUM(MonthlySales) OVER (ORDER BY Mth ROWS UNBOUNDED PRECEDING) / NULLIF(SUM(MonthlySales) OVER (),0), 2) AS PctOfYearToDate
FROM Monthly
ORDER BY Mth;

/* Show the three-month moving average of sales for each territory, displaying territory, month, sales, and moving average */
WITH MonthlyTerritory AS (
  SELECT
    soh.TerritoryID,
    YEAR(soh.OrderDate) AS SalesYear,
    MONTH(soh.OrderDate) AS SalesMonth,
    SUM(sod.LineTotal) AS SalesAmount
  FROM Sales.SalesOrderHeader soh
  JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
  GROUP BY soh.TerritoryID, YEAR(soh.OrderDate), MONTH(soh.OrderDate)
)
SELECT
  st.Name AS Territory,
  mt.SalesYear,
  mt.SalesMonth,
  mt.SalesAmount,
  ROUND(AVG(mt2.SalesAmount) OVER (PARTITION BY mt.TerritoryID, mt.SalesYear ORDER BY mt.SalesMonth ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS MovingAvg3Mo
FROM MonthlyTerritory mt
JOIN Sales.SalesTerritory st ON mt.TerritoryID = st.TerritoryID
LEFT JOIN MonthlyTerritory mt2 ON 1=1 -- used by window; kept for clarity
ORDER BY st.Name, mt.SalesYear, mt.SalesMonth;

/* Show month-over-month sales growth, displaying month, sales, previous month sales, growth amount, and growth percentage */
WITH Monthly AS (
  SELECT
    YEAR(soh.OrderDate) AS SalesYear,
    MONTH(soh.OrderDate) AS SalesMonth,
    SUM(sod.LineTotal) AS SalesAmount
  FROM Sales.SalesOrderHeader soh
  JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
  WHERE YEAR(soh.OrderDate) = 2013
  GROUP BY YEAR(soh.OrderDate), MONTH(soh.OrderDate)
)
SELECT
  m.SalesMonth,
  m.SalesAmount,
  LAG(m.SalesAmount) OVER (ORDER BY m.SalesMonth) AS PrevMonthSales,
  m.SalesAmount - LAG(m.SalesAmount) OVER (ORDER BY m.SalesMonth) AS GrowthAmount,
  ROUND(100.0 * (m.SalesAmount - LAG(m.SalesAmount) OVER (ORDER BY m.SalesMonth)) / NULLIF(LAG(m.SalesAmount) OVER (ORDER BY m.SalesMonth),0),2) AS GrowthPct
FROM Monthly m
ORDER BY m.SalesMonth;

/* Divide customers into four quartiles based on total purchase amount, showing customer name, total purchases, quartile, and quartile average */
WITH CustTotals AS (
    SELECT
        c.CustomerID,
        per.FirstName + ' ' + per.LastName AS CustomerName,
        SUM(soh.TotalDue) AS TotalPurchases
    FROM Sales.Customer c
    JOIN Sales.SalesOrderHeader soh
        ON c.CustomerID = soh.CustomerID
    JOIN Person.Person per
        ON c.PersonID = per.BusinessEntityID
    GROUP BY c.CustomerID, per.FirstName, per.LastName
),
Quartiles AS (
    SELECT
        CustomerID,
        CustomerName,
        TotalPurchases,
        NTILE(4) OVER (ORDER BY TotalPurchases DESC) AS PurchaseQuartile
    FROM CustTotals
)
SELECT
    q.CustomerID,
    q.CustomerName,
    q.TotalPurchases,
    q.PurchaseQuartile,
    ROUND(AVG(q.TotalPurchases) OVER (PARTITION BY q.PurchaseQuartile), 2) AS QuartileAvg
FROM Quartiles AS q
ORDER BY q.TotalPurchases DESC;

/*------------20---------*/
/* Create a pivot table showing product categories as rows and years (2011-2014) as columns, displaying sales amounts with totals */
 SELECT 
    pvt.Category,
    ISNULL([2011],0) AS Sales2011,
    ISNULL([2012],0) AS Sales2012,
    ISNULL([2013],0) AS Sales2013,
    ISNULL([2014],0) AS Sales2014,
    ISNULL([2011],0)+ISNULL([2012],0)+ISNULL([2013],0)+ISNULL([2014],0) AS TotalSales
FROM (
    SELECT 
        pc.Name AS Category,     
        YEAR(soh.OrderDate) AS SalesYear,
        sod.LineTotal AS SalesAmt 
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product p       ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc    ON ps.ProductCategoryID = pc.ProductCategoryID
    WHERE YEAR(soh.OrderDate) BETWEEN 2011 AND 2014
) AS src
PIVOT (
    SUM(SalesAmt) FOR SalesYear IN ([2011],[2012],[2013],[2014])
) AS pvt
ORDER BY Category;
 

/* Create a pivot table showing departments as rows and gender as columns, displaying employee count by department and gender */
SELECT Department,
       ISNULL([M],0) AS MaleCount,
       ISNULL([F],0) AS FemaleCount
FROM (
    SELECT d.Name AS Department,
           e.Gender
    FROM HumanResources.Employee AS e
    JOIN HumanResources.EmployeeDepartmentHistory AS edh
         ON e.BusinessEntityID = edh.BusinessEntityID
        AND edh.EndDate IS NULL
    JOIN HumanResources.Department AS d
         ON edh.DepartmentID = d.DepartmentID
) AS src
PIVOT (
    COUNT(Gender) FOR Gender IN ([M],[F])
) AS pvt
ORDER BY Department;

/* Create a dynamic pivot table for quarterly sales, automatically handling an unknown number of quarters */
DECLARE @cols  NVARCHAR(MAX),
        @sql   NVARCHAR(MAX);

SELECT @cols = STRING_AGG(QUOTENAME(YearQuarter), ',')
FROM (
    SELECT DISTINCT
           CAST(YEAR(OrderDate) AS VARCHAR(4)) + 'Q' +
           CAST(DATEPART(QUARTER, OrderDate) AS VARCHAR(1)) AS YearQuarter
    FROM Sales.SalesOrderHeader
) AS q;

SET @sql = '
SELECT Territory, ' + @cols + '
FROM (
    SELECT t.Name AS Territory,
           CAST(YEAR(soh.OrderDate) AS VARCHAR(4)) + ''Q'' +
           CAST(DATEPART(QUARTER, soh.OrderDate) AS VARCHAR(1)) AS YearQuarter,
           soh.SubTotal AS SalesAmt
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesTerritory AS t ON soh.TerritoryID = t.TerritoryID
) AS src
PIVOT (SUM(SalesAmt) FOR YearQuarter IN (' + @cols + ')) AS pvt
ORDER BY Territory;';
EXEC sp_executesql @sql;

/*------------21---------*/
/* Find products sold in both 2013 and 2014, and combine with products sold only in 2013, showing a complete analysis */
-- Sold in 2013
WITH Sold2013 AS (
    SELECT DISTINCT sod.ProductID
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    WHERE YEAR(soh.OrderDate) = 2013
),
Sold2014 AS (
    SELECT DISTINCT sod.ProductID
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    WHERE YEAR(soh.OrderDate) = 2014
)
SELECT p.Name AS ProductName,
       CASE 
         WHEN p.ProductID IN (SELECT ProductID FROM Sold2013 INTERSECT SELECT ProductID FROM Sold2014)
              THEN 'Sold in 2013 & 2014'
         ELSE 'Sold only in 2013'
       END AS SaleCategory
FROM Production.Product p
WHERE p.ProductID IN (SELECT ProductID FROM Sold2013);

/* Compare product categories with high-value products (greater than $1000) to those with high-volume sales (more than 1000 units sold), using set operations */
-- High-value: any product with ListPrice > 1000
WITH HighValue AS (
    SELECT DISTINCT ps.ProductCategoryID
    FROM Production.Product p
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    WHERE p.ListPrice > 1000
),
HighVolume AS (
    SELECT DISTINCT ps.ProductCategoryID
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    GROUP BY ps.ProductCategoryID
    HAVING SUM(sod.OrderQty) > 1000
)
SELECT c.Name AS Category,
       CASE 
         WHEN c.ProductCategoryID IN (SELECT * FROM HighValue INTERSECT SELECT * FROM HighVolume)
              THEN 'High Value & High Volume'
         WHEN c.ProductCategoryID IN (SELECT * FROM HighValue) THEN 'High Value Only'
         WHEN c.ProductCategoryID IN (SELECT * FROM HighVolume) THEN 'High Volume Only'
         ELSE 'Neither'
       END AS CategoryType
FROM Production.ProductCategory c;

/*------------22---------*/
/* Declare variables for the current year, total sales, and average order value, and display year-to-date statistics with formatted output */
DECLARE @CurYear INT       = YEAR(GETDATE()),
        @TotalSales MONEY,
        @AvgOrder  MONEY;

SELECT @TotalSales = SUM(TotalDue),
       @AvgOrder  = AVG(TotalDue)
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = @CurYear;

PRINT CONCAT('Year: ', @CurYear);
PRINT CONCAT('Total Sales: $', FORMAT(@TotalSales,'N2'));
PRINT CONCAT('Average Order Value: $', FORMAT(@AvgOrder,'N2'));

/* Check if a specific product exists in inventory. If it exists, show details; if not, suggest similar products */
DECLARE @ProdName NVARCHAR(50) = 'Road-150 Red, 44';

IF EXISTS (SELECT 1 FROM Production.Product WHERE Name = @ProdName)
    SELECT * FROM Production.Product WHERE Name = @ProdName;
ELSE
    SELECT TOP 5 * 
    FROM Production.Product
    WHERE Name LIKE '%' + PARSENAME(REPLACE(@ProdName,' ','_'),1) + '%';

/* Generate a monthly sales summary for each month in 2013 using a loop */
DECLARE @m INT = 1;
WHILE @m <= 12
BEGIN
    SELECT @m AS MonthNum,
           SUM(TotalDue) AS MonthlySales
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = 2013
      AND MONTH(OrderDate) = @m;
    SET @m += 1;
END

/* Implement error handling for a product price update operation, including logging errors and rolling back on failure */
BEGIN TRY
    BEGIN TRAN;
    UPDATE Production.Product
    SET ListPrice = ListPrice * 1.10
    WHERE ProductID = 707;   -- example ID

    -- Log success
    INSERT INTO dbo.UpdateLog(ProductID, ActionDate, Note)
    VALUES (707, SYSDATETIME(), 'Price increased 10%');

    COMMIT TRAN;
END TRY
BEGIN CATCH
    ROLLBACK TRAN;
    INSERT INTO dbo.UpdateLog(ProductID, ActionDate, Note)
    VALUES (707, SYSDATETIME(), 
            CONCAT('ERROR: ', ERROR_MESSAGE()));
    THROW;
END CATCH;

/*------------23---------*/
/* Create a scalar function to calculate customer lifetime value, including total amount spent and weighted recent activity, with parameters for date range and activity weight */
CREATE OR ALTER FUNCTION dbo.fnCustomerLifetimeValue
(
    @CustomerID INT,
    @StartDate DATE,
    @EndDate   DATE,
    @RecentWeight DECIMAL(5,2)   -- e.g. 1.2 for 20% weight
)
RETURNS MONEY
AS
BEGIN
    DECLARE @Base MONEY =
        (SELECT SUM(TotalDue)
         FROM Sales.SalesOrderHeader
         WHERE CustomerID = @CustomerID
           AND OrderDate BETWEEN @StartDate AND @EndDate);

    DECLARE @Recent MONEY =
        (SELECT SUM(TotalDue)
         FROM Sales.SalesOrderHeader
         WHERE CustomerID = @CustomerID
           AND OrderDate >= DATEADD(YEAR,-1,@EndDate));

    RETURN ISNULL(@Base,0) + ISNULL(@Recent,0)*(@RecentWeight-1);
END;

/* Create a multi-statement table-valued function to return products by price range and category, including error handling for invalid parameters */
 
/* Create an inline table-valued function to return all employees under a specific manager, including hierarchy level and employee path */
CREATE OR ALTER FUNCTION dbo.fnEmployeesUnderManager(@ManagerID INT)
RETURNS TABLE
AS
RETURN
(
    WITH EmpCTE AS (
        SELECT e.BusinessEntityID,
               p.FirstName + ' ' + p.LastName AS EmpName,
               e.OrganizationNode AS OrgNode
        FROM HumanResources.Employee e
        JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
    )
    SELECT e1.BusinessEntityID,
           e1.EmpName,
           e1.OrgNode.GetLevel() AS HierarchyLevel,
           e1.OrgNode.ToString() AS Path
    FROM EmpCTE e1
    JOIN EmpCTE m ON e1.OrgNode.IsDescendantOf(m.OrgNode) = 1
    WHERE m.BusinessEntityID = @ManagerID
);

/*------------24---------*/
/* Create a stored procedure to get products by category, with parameters for category name, minimum price, and maximum price, including parameter validation and error handling */

CREATE OR ALTER PROCEDURE dbo.usp_GetProductsByCategory
    @CategoryName NVARCHAR(100),
    @MinPrice MONEY = NULL,
    @MaxPrice MONEY = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @CategoryName IS NULL OR LTRIM(RTRIM(@CategoryName)) = ''
            THROW 51000, 'CategoryName must be supplied.', 1;

        IF @MinPrice IS NOT NULL AND @MaxPrice IS NOT NULL AND @MinPrice > @MaxPrice
            THROW 51001, 'MinPrice cannot be greater than MaxPrice.', 1;

        IF NOT EXISTS (
            SELECT 1 FROM Production.ProductCategory pc
            WHERE pc.Name = @CategoryName
        )
            THROW 51002, 'Category not found.', 1;

        SELECT p.ProductID, p.Name, p.ProductNumber, p.ListPrice,
               p.SellStartDate, p.SellEndDate
        FROM Production.Product p
        INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        INNER JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
        WHERE pc.Name = @CategoryName
          AND (@MinPrice IS NULL OR p.ListPrice >= @MinPrice)
          AND (@MaxPrice IS NULL OR p.ListPrice <= @MaxPrice)
        ORDER BY p.Name;
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000)=ERROR_MESSAGE();
        RAISERROR('usp_GetProductsByCategory failed: %s',16,1,@ErrMsg);
    END CATCH
END
GO

/* Create a stored procedure to update product pricing, including an audit trail, business rule validation, and transaction management */
CREATE OR ALTER PROCEDURE dbo.usp_UpdateProductPricing
    @ProductID INT,
    @NewListPrice MONEY,
    @ChangedBy SYSNAME
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @ProductID IS NULL OR @NewListPrice IS NULL OR @ChangedBy IS NULL
    BEGIN
        RAISERROR('ProductID, NewListPrice, and ChangedBy are required.', 16, 1);
        RETURN;
    END
    
    IF @NewListPrice <= 0
    BEGIN
        RAISERROR('Price must be greater than zero.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Production.Product WHERE ProductID = @ProductID)
    BEGIN
        RAISERROR('Product ID does not exist.', 16, 1);
        RETURN;
    END

    DECLARE @OldListPrice MONEY;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @OldListPrice = ListPrice FROM Production.Product WHERE ProductID = @ProductID;

        IF @OldListPrice IS NOT NULL AND @NewListPrice < (@OldListPrice * 0.5)
        BEGIN
            RAISERROR('New price violates business rule (price drop > 50%%).', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE Production.Product
        SET ListPrice = @NewListPrice,
            ModifiedDate = SYSUTCDATETIME()  -- Ensure ModifiedDate is updated
        WHERE ProductID = @ProductID;   

        INSERT INTO dbo.ProductPriceAudit (ProductID, OldPrice, NewPrice, ChangedBy, ChangeDate)
        VALUES (@ProductID, @OldListPrice, @NewListPrice, @ChangedBy, SYSUTCDATETIME());

        COMMIT TRANSACTION;

        PRINT 'Price updated successfully and audit logged.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error occurred: %s', 16, 1, @ErrorMessage);
    END CATCH
END;
GO



/* Create a stored procedure to generate a comprehensive sales report for a given date range and territory, including summary statistics and detailed breakdowns */
GO
CREATE OR ALTER PROCEDURE dbo.usp_sales_report_by_territory
    @startdate  DATE,
    @enddate    DATE,
    @territoryid INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate parameters
    IF @startdate IS NULL OR @enddate IS NULL OR @startdate > @enddate
    BEGIN
        RAISERROR('Invalid date range provided.',16,1);
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Sales.SalesTerritory WHERE TerritoryID = @territoryid)
    BEGIN
        RAISERROR('Invalid territory ID.',16,1);
        RETURN;
    END;

    PRINT '--- Summary Statistics ---';

    SELECT
        t.Name AS territory,
        COUNT(DISTINCT soh.SalesOrderID) AS order_count,
        SUM(soh.TotalDue) AS total_sales,
        AVG(soh.TotalDue) AS avg_order_value
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesTerritory  AS t  ON soh.TerritoryID = t.TerritoryID
    WHERE soh.OrderDate BETWEEN @startdate AND @enddate
      AND soh.TerritoryID = @territoryid
    GROUP BY t.Name;

    PRINT '--- Detailed Breakdown: Sales by Customer and Product ---';

    SELECT
        soh.SalesOrderID,
        soh.OrderDate,
        p.FirstName + ' ' + p.LastName AS customer_name,
        pr.Name AS product_name,
        sod.OrderQty,
        sod.UnitPrice,
        sod.LineTotal
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.Customer       AS c   ON soh.CustomerID   = c.CustomerID
    JOIN Person.Person        AS p   ON c.PersonID      = p.BusinessEntityID
    JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product   AS pr  ON sod.ProductID   = pr.ProductID
    WHERE soh.OrderDate BETWEEN @startdate AND @enddate
      AND soh.TerritoryID = @territoryid
    ORDER BY soh.OrderDate, soh.SalesOrderID;
END;
GO

/* Create a stored procedure to process bulk orders from XML input, including transaction management, validation, error handling, and returning order confirmation details */
GO
CREATE OR ALTER PROCEDURE dbo.usp_process_bulk_orders
    @OrdersXml XML
AS
BEGIN
    SET NOCOUNT ON;

    IF @OrdersXml IS NULL
    BEGIN
        RAISERROR('OrdersXml cannot be NULL.',16,1);
        RETURN;
    END;

    DECLARE @Confirm TABLE
    (
        OrderIndex INT,
        SalesOrderID INT NULL,
        Status NVARCHAR(50),
        Message NVARCHAR(4000)
    );

    ;WITH Orders AS
    (
        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS OrderIndex,
               O.query('.') AS OrderXml
        FROM @OrdersXml.nodes('/Orders/Order') AS T(O)
    )
    SELECT * INTO #OrdersParsed FROM Orders;

    DECLARE @i INT = 1,
            @count INT = (SELECT COUNT(*) FROM #OrdersParsed);

    IF @count = 0
    BEGIN
        INSERT INTO @Confirm VALUES (0,NULL,'Failed','No <Order> elements found.');
        SELECT * FROM @Confirm;
        RETURN;
    END;

    WHILE @i <= @count
    BEGIN
        DECLARE @OrderXml XML = (SELECT OrderXml FROM #OrdersParsed WHERE OrderIndex = @i);
        DECLARE @CustomerID INT,
                @OrderDate  DATETIME = GETDATE(),
                @NewOrderID INT;

        BEGIN TRY
            SELECT
                @CustomerID = X.N.value('(CustomerID/text())[1]','INT'),
                @OrderDate  = X.N.value('(OrderDate/text())[1]','DATETIME')
            FROM (SELECT @OrderXml AS N) AS X;

            IF @CustomerID IS NULL
                RAISERROR('CustomerID missing for order %d.',16,1,@i);

            BEGIN TRAN;

            INSERT INTO Sales.SalesOrderHeader
                (OrderDate, DueDate, Status, OnlineOrderFlag,
                 CustomerID, SubTotal, TaxAmt, Freight, ModifiedDate)
            VALUES
                (@OrderDate, DATEADD(DAY,7,@OrderDate), 1, 1,
                 @CustomerID, 0, 0, 0, SYSDATETIME());

            SET @NewOrderID = SCOPE_IDENTITY();

            DECLARE @Lines TABLE (ProductID INT, Quantity INT, UnitPrice MONEY);
            INSERT INTO @Lines
            SELECT
                L.value('(ProductID/text())[1]','INT'),
                L.value('(Quantity/text())[1]','INT'),
                L.value('(UnitPrice/text())[1]','MONEY')
            FROM @OrderXml.nodes('/Order/OrderLines/Line') AS T(L);

            IF NOT EXISTS (SELECT 1 FROM @Lines)
                RAISERROR('Order %d has no order lines.',16,1,@i);

            -- insert each order line and adjust inventory
            DECLARE @pid INT,@qty INT,@price MONEY;
            DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
                SELECT ProductID, Quantity, UnitPrice FROM @Lines;
            OPEN cur;
            FETCH NEXT FROM cur INTO @pid,@qty,@price;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM Production.Product WHERE ProductID=@pid)
                    RAISERROR('Invalid ProductID %d in order %d.',16,1,@pid,@i);

                UPDATE Production.ProductInventory
                   SET Quantity = Quantity - @qty
                 WHERE ProductID=@pid
                   AND Quantity >= @qty;

                IF @@ROWCOUNT = 0
                    RAISERROR('Insufficient inventory for ProductID %d in order %d.',16,1,@pid,@i);

                INSERT INTO Sales.SalesOrderDetail
                    (SalesOrderID, OrderQty, ProductID, UnitPrice, ModifiedDate)
                VALUES (@NewOrderID, @qty, @pid, @price, SYSDATETIME());

                FETCH NEXT FROM cur INTO @pid,@qty,@price;
            END
            CLOSE cur; DEALLOCATE cur;

            -- update order total
             UPDATE h
            SET SubTotal = (
                  SELECT SUM(LineTotal)
                  FROM Sales.SalesOrderDetail
                  WHERE SalesOrderID = @NewOrderID
            )
            -- TaxAmt and Freight are left as 0 here; you can adjust if needed
            FROM Sales.SalesOrderHeader h
            WHERE SalesOrderID = @NewOrderID;

            COMMIT TRAN;

            INSERT INTO @Confirm VALUES (@i,@NewOrderID,'Success','Order processed successfully.');
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRAN;
            INSERT INTO @Confirm
            VALUES (@i,NULL,'Failed',ERROR_MESSAGE());
        END CATCH;

        SET @i += 1;
    END;

    SELECT * FROM @Confirm ORDER BY OrderIndex;
    DROP TABLE #OrdersParsed;
END;
GO
/* Create a stored procedure to perform flexible product searches with dynamic filtering by name, category, price range, and date range, returning paginated results and total count */
GO
CREATE OR ALTER PROCEDURE dbo.usp_search_products
    @name       NVARCHAR(100) = NULL,
    @category   NVARCHAR(100) = NULL,
    @minPrice   MONEY         = NULL,
    @maxPrice   MONEY         = NULL,
    @startDate  DATE          = NULL,
    @endDate    DATE          = NULL,
    @pageNumber INT           = 1,
    @pageSize   INT           = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @offset INT = (@pageNumber - 1) * @pageSize;

    WITH filtered_products AS
    (
        SELECT 
            p.ProductID,
            p.Name,
            pc.Name AS category,
            p.ListPrice,
            p.SellStartDate,
            p.SellEndDate
        FROM Production.Product p
        JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN Production.ProductCategory   pc ON ps.ProductCategoryID    = pc.ProductCategoryID
        WHERE (@name     IS NULL OR p.Name LIKE '%' + @name + '%')
          AND (@category IS NULL OR pc.Name = @category)
          AND (@minPrice IS NULL OR p.ListPrice >= @minPrice)
          AND (@maxPrice IS NULL OR p.ListPrice <= @maxPrice)
          AND (@startDate IS NULL OR p.SellStartDate >= @startDate)
          AND (@endDate   IS NULL OR (p.SellEndDate IS NOT NULL AND p.SellEndDate <= @endDate))
    )
    SELECT 
        ProductID,
        Name,
        category,
        ListPrice,
        SellStartDate,
        SellEndDate
    FROM filtered_products
    ORDER BY Name
    OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;

    -- Return total count for pagination
    SELECT COUNT(*) AS total_count FROM filtered_products;
END;
GO



/*------------25---------*/
/* Create a trigger on Sales.SalesOrderDetail to update product inventory and maintain sales statistics after insert, including error handling and transaction management */
IF OBJECT_ID('dbo.error_log','U') IS NULL
BEGIN
    CREATE TABLE dbo.error_log
    (
        id            INT IDENTITY PRIMARY KEY,
        errormessage  NVARCHAR(MAX),
        procedure_name SYSNAME,
        error_line    INT,
        log_date      DATETIME DEFAULT SYSDATETIME()
    );
END;
GO
CREATE OR ALTER TRIGGER trg_after_insert_salesorderdetail
ON Sales.SalesOrderDetail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        UPDATE p
        SET p.SafetyStockLevel = p.SafetyStockLevel - i.OrderQty
        FROM Production.Product p
        JOIN inserted i ON p.ProductID = i.ProductID;

        INSERT INTO dbo.sales_order_stats_log (salesorderid, productid, quantity, entrydate)
        SELECT i.SalesOrderID, i.ProductID, i.OrderQty, SYSDATETIME()
        FROM inserted i;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;

        DECLARE @errmsg NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @errproc SYSNAME      = ERROR_PROCEDURE();
        DECLARE @errline INT          = ERROR_LINE();

        INSERT INTO dbo.error_log (errormessage, procedure_name, error_line)
        VALUES (@errmsg, @errproc, @errline);

        THROW;  -- re-raise
    END CATCH;
END;
GO
/* Create a view combining multiple tables and implement an INSTEAD OF trigger for insert operations, handling complex business logic and data distribution */
CREATE OR ALTER VIEW vw_customer_orders AS
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    soh.CustomerID,
    p.FirstName + ' ' + p.LastName AS customer_name,
    sod.ProductID,
    pr.Name AS product_name,
    sod.OrderQty,
    sod.UnitPrice
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Sales.Customer sc          ON soh.CustomerID   = sc.CustomerID
JOIN Person.Person p            ON sc.PersonID      = p.BusinessEntityID
JOIN Production.Product pr      ON sod.ProductID    = pr.ProductID;
GO

CREATE OR ALTER TRIGGER trg_instead_of_insert_vw_customer_orders
ON vw_customer_orders
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted WHERE OrderQty <= 0)
    BEGIN
        RAISERROR('Order quantity must be greater than 0.',16,1);
        ROLLBACK;
        RETURN;
    END;

    DECLARE @output_orderid TABLE (SalesOrderID INT);

    INSERT INTO Sales.SalesOrderHeader
        (OrderDate, CustomerID, SubTotal, TaxAmt, Freight, ModifiedDate)
    OUTPUT inserted.SalesOrderID INTO @output_orderid
    SELECT OrderDate, CustomerID, 0, 0, 0, SYSDATETIME()
    FROM inserted;

    DECLARE @new_orderid INT = (SELECT TOP 1 SalesOrderID FROM @output_orderid);

    INSERT INTO Sales.SalesOrderDetail
        (SalesOrderID, ProductID, OrderQty, UnitPrice, ModifiedDate)
    SELECT @new_orderid, ProductID, OrderQty, UnitPrice, SYSDATETIME()
    FROM inserted;
END;
GO

/* Create an audit trigger for Production.Product price changes, logging old and new values with timestamp and user information */
    IF OBJECT_ID('Production.product_price_audit','U') IS NULL
    BEGIN
        CREATE TABLE Production.product_price_audit
        (
            audit_id  INT IDENTITY(1,1) PRIMARY KEY,
            productid INT,
            old_price MONEY,
            new_price MONEY,
            changed_by SYSNAME,
            changed_at DATETIME DEFAULT SYSDATETIME()
        );
    END;
    GO
    CREATE OR ALTER TRIGGER trg_audit_product_price
    ON Production.Product
    AFTER UPDATE
    AS
    BEGIN
        SET NOCOUNT ON;

        INSERT INTO Production.product_price_audit
            (productid, old_price, new_price, changed_by, changed_at)
        SELECT
            d.ProductID,
            d.ListPrice,
            i.ListPrice,
            SUSER_SNAME(),
            SYSDATETIME()
        FROM deleted d
        JOIN inserted i ON d.ProductID = i.ProductID
        WHERE ISNULL(d.ListPrice,0) <> ISNULL(i.ListPrice,0);
    END;
    GO
/*------------26---------*/
/* Create a filtered index for active products only (SellEndDate IS NULL) and for recent orders (last 2 years), and measure performance impact */
 SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO
CREATE NONCLUSTERED INDEX IX_Active_Products
ON Production.Product (Name)
WHERE SellEndDate IS NULL;
GO
IF COL_LENGTH('Sales.SalesOrderHeader', 'IsRecent') IS NULL
BEGIN
    ALTER TABLE Sales.SalesOrderHeader
    ADD IsRecent AS
        CASE WHEN OrderDate >= DATEADD(YEAR,-2, SYSUTCDATETIME()) THEN 1 ELSE 0 END
        PERSISTED;
END
GO
