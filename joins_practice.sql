--- Find employees who have no department ---

SELECT e.employee_id, e.first_name, e.last_name, e.department_id FROM employeesjoin e
LEFT JOIN departmentsjoin d
ON e.department_id = d.department_id
WHERE e.department_id IS NULL

--- SELF JOIN (Employee Manager) ---

SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, m.employee_id, m.first_name, m.last_name FROM employeesjoin e
LEFT JOIN employeesjoin m
ON e.manager_id = m.employee_id

--- Join 3 Tables ---

SELECT l.*, c.country_name, r.region_name FROM locationsjoin l
INNER JOIN countriesjoin c
ON l.country_id = c.country_id
INNER JOIN regionsjoin r
ON c.region_id = r.region_id

--- Latest order per customer ---

SELECT c.CustomerID, c.FirstName, c.LastName, o.last_order FROM Customers c
INNER JOIN (
SELECT CustomerID , MAX(OrderDate) AS last_order FROM Orders
GROUP BY CustomerID
) o
ON c.CustomerID = o.CustomerID


--- CROSS APPLY (return top order per customer)

SELECT c.CustomerID,c.FirstName, c.LastName, o.*
FROM Customers c
CROSS APPLY (
    SELECT TOP 1 *
    FROM Orders o
    WHERE o.CustomerID = c.CustomerID
	ORDER BY Sales DESC
) o

--- Outer apply with no orders  (Keeps customers even if they have 0 orders)


SELECT c.CustomerID, c.FirstName, c.LastName, o.*
FROM Customers c
OUTER APPLY (
    SELECT TOP 1 * FROM Orders o
    WHERE o.CustomerID = c.CustomerID
    ORDER BY Sales DESC
) o


--- Find the N'th top sales order for each customer if N'th rank is not avaiable then show top avaiable rank

;WITH sales_ranking AS 
(
SELECT c.CustomerID, c.FirstName, c.LastName,o.Sales, o.OrderID , 
ROW_NUMBER() OVER (PARTITION BY c.customerID ORDER BY o.Sales DESC) AS rank_top_sales 
FROM Customers c
INNER JOIN Orders o
ON c.CustomerID = o.CustomerID
) ,
best_sales_rank AS
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY customerID ORDER BY rank_top_sales DESC) AS best_ranking
FROM sales_ranking
)
SELECT * FROM best_sales_rank
WHERE best_ranking = 1

--- Find departments where: Headcount > 5 , Total payroll > 80,000, Average salary > 3,000

SELECT department_id, 
COUNT(*) as total_count, 
SUM(salary) as total_salary, 
CAST(AVG(salary) as decimal (10,2)) as avg_salary
FROM employeesjoin
where department_id IS NOT NULL
group by department_id
having COUNT(*) > 5
AND SUM(salary) > 80000
AND CAST(AVG(salary) as decimal (10,2)) > 3000
