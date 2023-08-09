-- Create the DW schema if it doesn't exist
-- CREATE SCHEMA DW;
-- CREATE OR ALTER VIEW DW.FactSales AS
-- SELECT SalesOrderID, CustomerID,Produ FROM [SalesLT].[SalesOrderHeader] s
-- SELECT TOP 100 * FROM [SalesLT].[SalesOrderHeader]

SELECT TOP (3)
    c.[CustomerID], c.[FirstName], c.[LastName], c.[CompanyName]
    ,SUM(s.[TotalDue]) AS total_sales
FROM [SalesLT].[SalesOrderHeader] s
LEFT JOIN [SalesLT].[Customer] c ON c.CustomerID = s.CustomerID
GROUP BY
    c.[CustomerID], c.FirstName, c.LastName, c.CompanyName
ORDER BY
    total_sales DESC


SELECT TOP (5)
c.[CustomerID], c.[FirstName], c.[LastName]
,SUM(s.[TotalDue]) AS total_sales
,(SUM(s.[TotalDue]) - SUM(s.[TotalDue])*0.1) AS total_sales_discounted
FROM [SalesLT].[SalesOrderHeader] s
LEFT JOIN [SalesLT].[Customer] c ON c.CustomerID = s.CustomerID
GROUP BY
c.[CustomerID], c.FirstName, c.LastName, c.CompanyName
ORDER BY
total_sales DESC

SELECT TOP (5)
c.[CustomerID]
FROM [SalesLT].[SalesOrderHeader] s
LEFT JOIN [SalesLT].[Customer] c ON c.CustomerID = s.CustomerID
GROUP BY
c.[CustomerID], c.FirstName, c.LastName, c.CompanyName
ORDER BY
SUM(s.[TotalDue]) DESC


-- Step 1: Identify the top 5 customers based on sales before discounts
WITH Top5Customers AS (
    SELECT TOP (5)
        c.[CustomerID]
    FROM [SalesLT].[SalesOrderHeader] s
    LEFT JOIN [SalesLT].[Customer] c ON c.CustomerID = s.CustomerID
    GROUP BY
        c.[CustomerID], c.FirstName, c.LastName, c.CompanyName
    ORDER BY 
        SUM(s.[TotalDue]) DESC
)
-- Step 2: Update the SubTotal with a 10% discount for top customers
UPDATE soh
SET TotalDue = TotalDue - (TotalDue*0.1)
FROM [SalesLT].[SalesOrderHeader] soh
JOIN Top5Customers tc ON soh.CustomerID = tc.CustomerID



SELECT TOP (3)
    c.[CustomerID], c.[FirstName], c.[LastName], c.[CompanyName]
    ,SUM(s1.[LineTotal]) AS total_sales
FROM [SalesLT].[SalesOrderDetail] s1
LEFT JOIN [SalesLT].[SalesOrderHeader] s2 ON s2.SalesOrderID = s1.SalesOrderID
LEFT JOIN [SalesLT].[Customer] c ON c.CustomerID = s2.CustomerID
GROUP BY
    c.[CustomerID], c.FirstName, c.LastName, c.CompanyName
ORDER BY
    total_sales DESC


SELECT TOP (5)
    c.[CustomerID], c.[FirstName], c.[LastName]
    ,SUM(s1.[LineTotal]) AS total_sales
    ,(SUM(s1.[LineTotal]) - SUM(s1.[LineTotal])*0.1) AS total_sales_discounted
FROM [SalesLT].[SalesOrderDetail] s1
LEFT JOIN [SalesLT].[SalesOrderHeader] s2 ON s2.SalesOrderID = s1.SalesOrderID
LEFT JOIN [SalesLT].[Customer] c ON c.CustomerID = s2.CustomerID
GROUP BY
    c.[CustomerID], c.FirstName, c.LastName, c.CompanyName
ORDER BY
total_sales DESC



SELECT TOP (5)
    s2.[CustomerID]
FROM [SalesLT].[SalesOrderDetail] s1
LEFT JOIN [SalesLT].[SalesOrderHeader] s2 ON s2.SalesOrderID = s1.SalesOrderID
GROUP BY
    s2.[CustomerID]
ORDER BY
    SUM(s1.[LineTotal]) DESC


-- Step 1: Identify the top 5 customers based on sales before discounts
WITH Top5Customers AS (
    SELECT TOP (5)
        s2.[CustomerID]
    FROM [SalesLT].[SalesOrderDetail] s1
    LEFT JOIN [SalesLT].[SalesOrderHeader] s2 ON s2.SalesOrderID = s1.SalesOrderID
    GROUP BY
        s2.[CustomerID]
    ORDER BY
        SUM(s1.[LineTotal]) DESC
)
-- Step 2: Update the SubTotal with a 10% discount for top customers
UPDATE sod
SET LineTotal = LineTotal - (LineTotal*0.1)
FROM [SalesLT].[SalesOrderDetail] sod
LEFT JOIN [SalesLT].[SalesOrderHeader] s2 ON s2.SalesOrderID = sod.SalesOrderID
JOIN Top5Customers tc ON s2.CustomerID = tc.CustomerID





CREATE SCHEMA DW;

CREATE OR ALTER VIEW DW.FactSales AS 
    SELECT s1.SalesOrderID, s2.CustomerID, s1.ProductID, s1.LineTotal
    FROM [SalesLT].[SalesOrderDetail] s1
    LEFT JOIN [SalesLT].[SalesOrderHeader] s2 ON s2.SalesOrderID = s1.SalesOrderID;

CREATE OR ALTER VIEW DW.DimSales AS 
    SELECT s1.SalesOrderID, s1.SalesOrderDetailID, s2.SalesOrderNumber
    FROM [SalesLT].[SalesOrderDetail] s1
    LEFT JOIN [SalesLT].[SalesOrderHeader] s2 ON s2.SalesOrderID = s1.SalesOrderID;


CREATE OR ALTER VIEW DW.DimProducts AS 
    SELECT p.ProductID, p.Name
    FROM [SalesLT].[Product] p;
               
CREATE OR ALTER VIEW DW.DimCustomers AS 
    SELECT c.CustomerID, c.FirstName, c.LastName
    FROM [SalesLT].[Customer] c;
               

CREATE OR ALTER VIEW DW.DimTime AS
    SELECT 
    ABS(CONVERT(INT, CONVERT(VARBINARY(4), HASHBYTES('SHA1', CONVERT(VARCHAR(19), t.OrderDate, 120))))) AS time_key,
    CONVERT(VARCHAR(10), t.OrderDate, 23) AS formatted_date,
    DATEPART(WEEKDAY, t.OrderDate) AS day_of_week,
    DATENAME(month, t.OrderDate) AS month_name
    FROM [SalesLT].[SalesOrderHeader] t;



