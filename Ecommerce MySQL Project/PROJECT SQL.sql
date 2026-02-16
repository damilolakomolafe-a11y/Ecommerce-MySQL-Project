use ecommerce;
show tables;

select * from categories;
select * from customers;
select * from employees;
select * from orderdetails;
select * from orders;
select * from products;
select * from shippers;
select * from suppliers;
 
-- 1. Total Sales by Employee: 
-- Write a query to calculate the total sales (in dollars) made by each employee, considering the quantity and unit price of products sold.

SELECT 
e.EmployeeID,
e.LastName,
e.FirstName,
SUM(od.Quantity) AS total_quantity,
SUM(od.UnitPrice * od.Quantity) AS total_sales
FROM Employees e
LEFT JOIN Orders o ON e.EmployeeID = o.EmployeeID
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY e.EmployeeID, e.LastName, e.FirstName
ORDER BY total_sales DESC;


-- 2. Top 5 Customers by Sales:
-- Identify the top 5 customers who have generated the most revenue. Show the customer’s name and the total amount they’ve spent.
SELECT
 c.customerid, customername , SUM(unitprice * quantity) total_sales_$ 
FROM customers c 
LEFT JOIN  orders o on(c.customerid = o.customerid) 
INNER JOIN orderdetails od on (o.orderid = od.orderid)
 GROUP BY c.customerid 
 ORDER BY total_sales_$ desc limit 5 ;

-- 3. Monthly Sales Trend:
-- Write a query to display the total sales amount for each month in the year 1997.

SELECT 
YEAR(o.OrderDate) AS Sales_Year,
MONTH(o.OrderDate) AS Sales_Month,
SUM(od.Quantity * od.UnitPrice) AS Total_Sales
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = 1997
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
ORDER BY Sales_Month;


-- 4. Order Fulfilment Time:
-- Calculate the average time (in days) taken to fulfil an order for each employee.
--  Assuming shipping takes 3 or 5 days respectively depending on if the item was ordered in 1996 or 1997.
SELECT 
EmployeeID,
AVG(
CASE
WHEN YEAR(OrderDate)=1996 THEN 3
WHEN YEAR(OrderDate)=1997 THEN 5
END
) AS avg_fulfilment_days
FROM Orders
GROUP BY EmployeeID;

-- 5. Products by Category with No Sales:
-- List the customers operating in London and total sales for each.
SELECT
 c.customerid, customername,city, sum(unitprice * quantity) total_sales_$ 
FROM customers c JOIN orders o ON (c.customerid = o.customerid)
JOIN orderdetails od on (o.orderid = od.orderid) WHERE LOWER(city) = 'london'
 GROUP BY c.customerid ORDER BY total_sales_$ desc;
 
-- 6. Customers with Multiple Orders on the Same Date:
-- Write a query to find customers who have placed more than one order on the same date.
SELECT 
CustomerID,
OrderDate,
COUNT(OrderID) AS order_count
FROM Orders
GROUP BY CustomerID, OrderDate
HAVING COUNT(OrderID) > 1;

-- 7. Average Discount per Product:
-- Calculate the average discount given per product across all orders. Round to 2 decimal places.
SELECT p.productid, productname, round( avg(discount),2) 'Average Discount'
 FROM products P 
JOIN orderdetails OD
 ON (p.productid = od.productid)  
 GROUP BY p.productid;

-- 8. Products Ordered by Each Customer:
-- For each customer, list the products they have ordered along with the total quantity of each product ordered.
SELECT
C.customerid, customername, productname, quantity 
FROM customers C 
LEFT JOIN orders O ON (c.customerid = o.customerid) JOIN orderdetails OD on
(o.orderid =od.orderid) 
JOIN products P on (od.productid = p.productid) 
ORDER BY customername asc;

-- 9. Employee Sales Ranking:
-- Rank employees based on their total sales. Show the employeename, total sales, and their rank.
SELECT
   e.employeeid,e.lastname,e.firstname,
    SUM(od.unitprice * od.quantity) AS total_sales,
    RANK() OVER (ORDER BY SUM(od.unitprice * od.quantity) DESC) AS sales_rank
FROM employees e JOIN orders o ON e.employeeid = o.employeeid
JOIN orderdetails od ON o.orderid = od.orderid
GROUP BY e.EmployeeID, e.LastName, e.FirstName;

-- 10. Sales by Country and Category:
-- Write a query to display the total sales amount for each product category, grouped by country.
SELECT 
c.Country,
ca.CategoryName,
SUM(od.UnitPrice * od.Quantity) AS Total_Sales
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories ca ON p.CategoryID = ca.CategoryID
GROUP BY c.Country, ca.CategoryName;

-- 11. Year-over-Year Sales Growth:
-- Calculate the percentage growth in sales from one year to the next for each product.
SELECT p.productid,ProductName, sum(quantity * unitprice) "Sales $" , round((sum(quantity * unitprice))/100 ,2)  "Sales Percentage (%)",
 year(orderdate)  YEAR from orders o
LEFT JOIN orderdetails od on (o.orderid = od.orderid) JOIN Products P on (od.productid=p.productid) 
GROUP BY productid,year(orderdate) order by year asc; 

-- 12. Order Quantity Percentile:
-- Calculate the percentile rank of each order based on the total quantity of products in the order.
 SELECT 
OrderID,
SUM(Quantity) AS total_quantity,
PERCENT_RANK() OVER (ORDER BY SUM(Quantity)) AS percentile_rank
FROM OrderDetails
GROUP BY OrderID;

-- 13. Products Never Reordered:
-- Identify products that have been sold but have never been reordered (ordered only once). 
SELECT p.productid, productname, count(orderid) total_orders 
FROM products P 
JOIN orderdetails OD on
(p.productid = od.productid)  
GROUP BY p.productid, productname  
HAVING count(orderid)= 1;

-- 14. Most Valuable Product by Revenue:
-- Write a query to find the product that has generated the most revenue in each category.
SELECT *
FROM (
SELECT 
ca.CategoryName,
p.ProductName,
SUM(od.UnitPrice * od.Quantity) AS revenue,
RANK() OVER(PARTITION BY ca.CategoryName ORDER BY SUM(od.UnitPrice * od.Quantity) DESC) AS rnk
FROM Categories ca
JOIN Products p ON ca.CategoryID = p.CategoryID
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY ca.CategoryName, p.ProductName
) t
WHERE rnk = 1;

-- 15. Complex Order Details:
-- Identify orders where the total price of all items exceeds $100 and
-- contains at least one product with a discount of 5% or more.
SELECT 
orderid,
sum(quantity) Quantity, sum(unitprice * quantity) AS total_sales,
TRUNCATE(avg(discount), 2) Discount 
FROM orderdetails OD  
GROUP BY orderid
HAVING sum(unitprice * quantity) > 100 AND avg(discount) >= 0.05
ORDER BY total_sales desc ; 



