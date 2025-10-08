-- none recursive CTE :
-- 1.stand alone cte:
-- Find total sales per 
WITH cte_totalsales AS (
SELECT CustomerID, SUM(Sales) ToalSales FROM Orders GROUP BY CustomerID)
SELECT c.CustomerID,c.FirstName, c.LastName, cts.ToalSales FROM Customers c LEFT JOIN cte_totalsales cts ON cts.CustomerID = c.CustomerID;

 --  cte stored in cash to be used by main query 
 -- we can't use order by in cte
 -- multiple cte :
 -- find last order date for each customer : 
 select * from Orders;
 WITH cte_totalsales AS (
SELECT CustomerID, SUM(Sales) ToalSales FROM Orders GROUP BY CustomerID),
cte_last_order AS (
SELECT CustomerID, MAX(OrderDate) LastOrderDate
FROM Orders GROUP BY CustomerID

)
SELECT c.CustomerID,c.FirstName, c.LastName, cts.ToalSales, cs.LastOrderDate
FROM Customers c LEFT JOIN cte_totalsales cts ON cts.CustomerID = c.CustomerID
                  LEFT JOIN cte_last_order cs on cs.CustomerID = c.CustomerID;


-- Nested CTE :
-- rank customers based on total sales on each customer:


WITH cte_totalsales AS (
    -- CTE 1: Calculates the total sales for each customer
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM
        Orders
    GROUP BY
        CustomerID
),
cte_last_order AS (
    -- CTE 2: Finds the most recent order date for each customer
    SELECT
        CustomerID,
        MAX(OrderDate) AS LastOrderDate
    FROM
        Orders
    GROUP BY
        CustomerID
),
cte_rank_customer AS (
    -- CTE 3: Ranks the customers based on their TotalSales
    SELECT
        CustomerID,
        TotalSales,
        RANK() OVER(ORDER BY TotalSales DESC) AS SalesRank
    FROM
        cte_totalsales
)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    cts.TotalSales,
    clo.LastOrderDate,
    crc.SalesRank -- Select the pre-calculated rank from the third CTE
FROM
    Customers c
LEFT JOIN
    cte_totalsales cts ON cts.CustomerID = c.CustomerID
LEFT JOIN
    cte_last_order clo ON clo.CustomerID = c.CustomerID
LEFT JOIN
    cte_rank_customer crc ON crc.CustomerID = c.CustomerID; -- Join the third CTE;


-- segment customers based their total sales: 



WITH cte_totalsales AS (
    -- CTE 1: Calculates the total sales for each customer
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM
        Orders
    GROUP BY
        CustomerID
),
cte_last_order AS (
    -- CTE 2: Finds the most recent order date for each customer
    SELECT
        CustomerID,
        MAX(OrderDate) AS LastOrderDate
    FROM
        Orders
    GROUP BY
        CustomerID
),
cte_rank_customer AS (
    -- CTE 3: Ranks the customers based on their TotalSales
    SELECT
        CustomerID,
        TotalSales,
        RANK() OVER(ORDER BY TotalSales DESC) AS SalesRank
    FROM
        cte_totalsales
), cte_segment_cust as (
SELECT CustomerID, CASE WHEN TotalSales>100 THEN  'hight'
                   WHEN TotalSales>50 THEN  'MIDUM'
			         ELSE 'Low'
					 END CustomerSegment 

 FROM cte_totalsales
)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    cts.TotalSales,
    clo.LastOrderDate,cc.CustomerSegment,
    crc.SalesRank -- Select the pre-calculated rank from the third CTE
FROM
    Customers c
LEFT JOIN
    cte_totalsales cts ON cts.CustomerID = c.CustomerID
LEFT JOIN
    cte_last_order clo ON clo.CustomerID = c.CustomerID
LEFT JOIN
    cte_rank_customer crc ON crc.CustomerID = c.CustomerID
	LEFT JOIN
   cte_segment_cust cc ON cc.CustomerID = c.CustomerID; -- Join the third CTE;-- Join the third CTE




--Recursive CTE :
-- execute the first query in cte only once 

-- generate a seq of numbers from one to 20


WITH CTE_req AS (
SELECT 1 AS mynumber -- anchor query
-- recursive query
UNION ALL
SELECT mynumber+1  FROM CTE_req WHERE mynumber <20
)
-- main query
SELECT * FROM CTE_req; -- we can use option(maxrecursion 10) to define nb of iterations in the main query
-- also in sql server max nb of iterations is 1000 but using max recursion we can make it more 



-- show the employees hirearchy by displaying each employee level 