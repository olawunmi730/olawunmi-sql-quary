
-- Olawunmi seun
--Use the AdventureWorks Data Dictionary to come up with your own questions.
--Write at least 15 queries.
--Queries must be strictly based on JOINs and Subqueries.

-- 1. Customers and their orders in the 'Northwest' territory
SELECT 
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS CustomerName,
    st.Name AS Territory,
    soh.SalesOrderID,
    soh.OrderDate
FROM Sales.Customer c
JOIN Person.Person p 
    ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh 
    ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesTerritory st
    ON soh.TerritoryID = st.TerritoryID
WHERE st.Name = 'Northwest'
ORDER BY soh.OrderDate DESC;

-- 2. Show each customer’s name and the salesperson who handled their orders
SELECT
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS CustomerName,
    sp.FirstName + ' ' + sp.LastName AS SalesPersonName
FROM Sales.Customer c
JOIN Person.Person p 
    ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh 
    ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesPerson s
    ON soh.SalesPersonID = s.BusinessEntityID
JOIN Person.Person sp
    ON s.BusinessEntityID = sp.BusinessEntityID;

-- 3. Find the top 5 customers with the highest total order amount
SELECT TOP 5
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS CustomerName,
    SUM(soh.TotalDue) AS TotalSpent
FROM Sales.Customer c
JOIN Person.Person p 
    ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh 
    ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY TotalSpent DESC;

-- 4. Customers who have never placed an order
SELECT 
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS CustomerName
FROM Sales.Customer c
JOIN Person.Person p 
    ON c.PersonID = p.BusinessEntityID
WHERE NOT EXISTS (
    SELECT 1 
    FROM Sales.SalesOrderHeader soh
    WHERE soh.CustomerID = c.CustomerID
);

-- 5. Customers and total number of orders
SELECT 
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS CustomerName,
    COUNT(soh.SalesOrderID) AS TotalOrders
FROM Sales.Customer c
JOIN Person.Person p 
    ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.SalesOrderHeader soh 
    ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY TotalOrders DESC;

-- 6. Products with category
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    pc.Name AS CategoryName
FROM Production.Product p
JOIN Production.ProductSubcategory ps 
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc 
    ON ps.ProductCategoryID = pc.ProductCategoryID;

-- 7. Top 10 products more expensive than average
SELECT TOP 10
    ProductID,
    Name AS ProductName,
    ListPrice
FROM Production.Product
WHERE ListPrice > (
    SELECT AVG(ListPrice) 
    FROM Production.Product
)
ORDER BY ListPrice DESC;

-- 8. Products never ordered
SELECT 
    p.ProductID,
    p.Name AS ProductName
FROM Production.Product p
WHERE p.ProductID NOT IN (
    SELECT DISTINCT ProductID 
    FROM Sales.SalesOrderDetail
);

-- 9. Average price per category
SELECT 
    pc.Name AS CategoryName,
    AVG(p.ListPrice) AS AvgPrice
FROM Production.Product p
JOIN Production.ProductSubcategory ps 
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc 
    ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY AvgPrice DESC;

-- 10. Products with standard cost above average
SELECT 
    ProductID,
    Name AS ProductName,
    StandardCost
FROM Production.Product
WHERE StandardCost > (
    SELECT AVG(StandardCost) 
    FROM Production.Product
)
ORDER BY StandardCost DESC;

-- 11. Employees with their department
SELECT 
    e.BusinessEntityID AS EmployeeID,
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    edh.DepartmentID,
    ed.Name AS DepartmentName,
    e.JobTitle
FROM HumanResources.Employee e
JOIN Person.Person p 
    ON e.BusinessEntityID = p.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory edh
    ON e.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department ed
    ON edh.DepartmentID = ed.DepartmentID;

-- 12. Employees who are salespeople
SELECT 
    e.BusinessEntityID AS EmployeeID,
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    s.SalesQuota
FROM HumanResources.Employee e
JOIN Sales.SalesPerson s 
    ON e.BusinessEntityID = s.BusinessEntityID
JOIN Person.Person p 
    ON e.BusinessEntityID = p.BusinessEntityID;

-- 13. Top 3 salespeople by total sales
SELECT TOP 3
    sp.BusinessEntityID AS SalesPersonID,
    p.FirstName + ' ' + p.LastName AS SalesPersonName,
    SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesPerson sp
JOIN Person.Person p 
    ON sp.BusinessEntityID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh 
    ON sp.BusinessEntityID = soh.SalesPersonID
GROUP BY sp.BusinessEntityID, p.FirstName, p.LastName
ORDER BY TotalSales DESC;

-- 14. Number of orders per salesperson
SELECT 
    sp.BusinessEntityID AS SalesPersonID,
    p.FirstName + ' ' + p.LastName AS SalesPersonName,
    COUNT(soh.SalesOrderID) AS OrdersHandled
FROM Sales.SalesPerson sp
JOIN Person.Person p 
    ON sp.BusinessEntityID = p.BusinessEntityID
LEFT JOIN Sales.SalesOrderHeader soh 
    ON sp.BusinessEntityID = soh.SalesPersonID
GROUP BY sp.BusinessEntityID, p.FirstName, p.LastName
ORDER BY OrdersHandled DESC;

-- 15. Salespeople with zero sales
SELECT 
    sp.BusinessEntityID AS SalesPersonID,
    p.FirstName + ' ' + p.LastName AS SalesPersonName,
    ISNULL(SUM(soh.TotalDue), 0) AS TotalSales
FROM Sales.SalesPerson sp
JOIN Person.Person p 
    ON sp.BusinessEntityID = p.BusinessEntityID
LEFT JOIN Sales.SalesOrderHeader soh 
    ON sp.BusinessEntityID = soh.SalesPersonID
GROUP BY sp.BusinessEntityID, p.FirstName, p.LastName
HAVING SUM(soh.TotalDue) IS NULL OR SUM(soh.TotalDue) = 0;
