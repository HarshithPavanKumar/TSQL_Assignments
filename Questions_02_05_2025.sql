/*
1.	 Lab Activity 1: Creating a View for High-Earning Employees
Objective: Use VIEW to display employees earning above department average.
Steps:
	1.	Create an Employees table with sample data.
	2.	Define a VIEW to filter high-earning employees per department.
	3.	Retrieve data from the view.
Expected Outcome: The view should only return employees whose salaries are above the department average.
Enhancements:
	•	Modify the view to include bonus amounts for high earners.
	•	Create an indexed view for faster retrieval.
*/

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10, 2)
);

INSERT INTO Employees (EmployeeID, FirstName, LastName, Department, Salary) VALUES
(1, 'Nageswara', 'Rao', 'HR', 57000.00),
(2, 'Biswanth', 'ch', 'IT', 51000.00),
(3, 'Niteesh', 'Reddy', 'Finance', 75000.00),
(4, 'Harshith', 'S', 'IT', 63000.00),
(5, 'Dheeraj', 'K', 'Marketing', 46000.00)

CREATE TABLE DepartmentAverages (
    Department VARCHAR(50) PRIMARY KEY,
    AvgSalary DECIMAL(10, 2)
);

INSERT INTO DepartmentAverages (Department, AvgSalary)
SELECT Department, AVG(Salary)
FROM Employees
GROUP BY Department;

CREATE VIEW HighEarningEmployeesIndexed
WITH SCHEMABINDING
AS
SELECT 
    E.EmployeeID, 
    E.FirstName, 
    E.LastName, 
    E.Department, 
    E.Salary, 
    CAST(E.Salary * 0.10 AS DECIMAL(10,2)) AS Bonus
FROM dbo.Employees E
JOIN dbo.DepartmentAverages DA 
    ON E.Department = DA.Department
WHERE E.Salary > DA.AvgSalary;

CREATE UNIQUE CLUSTERED INDEX IX_HighEarningEmployees
ON HighEarningEmployeesIndexed (EmployeeID);

SELECT *FROM HighEarningEmployeesIndexed;



/*
2. Lab Activity 2: Using Correlated Subqueries for Recent Orders
Objective: Use Correlated Subqueries to fetch each customer's latest order details.
Steps:
	1.	Create Customers and Orders tables.
	2.	Use correlated subquery to find the latest order per customer.
	3.	Retrieve customer details along with order date.
🔹 Expected Outcome: Each customer appears only once, showing their most recent order date.
Enhancements:
	•	Modify the query to include order amount.
	•	Optimize query performance with indexing on OrderDate.
*/

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100)
);

INSERT INTO Customers (CustomerID, FirstName, LastName, Email) VALUES
(1, 'Biswanth', 'ch', 'biss@gmail.com'),
(2, 'Nages', 'Rao', 'nagis@gmail.com'),
(3, 'Niteesh', 'R', 'niteesh@gmail.com'),
(4, 'Yashwanth', 'B', 'yash@gmail.com.com')

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    Amount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

INSERT INTO Orders (OrderID, CustomerID, OrderDate, Amount) VALUES
(101, 1, '2024-10-01 10:30:00', 120.50),
(102, 1, '2024-11-15 14:45:00', 89.99),
(103, 2, '2024-12-03 09:00:00', 150.00),
(104, 3, '2024-11-25 12:10:00', 200.75),
(105, 4, '2025-03-20 17:00:00', 75.00);

CREATE INDEX idx_orders_customerid_orderdate
ON Orders (CustomerID, OrderDate DESC);

SELECT C.*, O.OrderDate, O.Amount
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
WHERE O.OrderDate = (
    SELECT MAX(O1.OrderDate)
    FROM Orders O1
    WHERE O1.CustomerID = C.CustomerID
)
ORDER BY C.CustomerID;

/*
3. Lab Activity 3: Creating a Stored Procedure for Dynamic Sales Reports
Objective: Create a Stored Procedure that fetches total sales for a given year.
Steps:
	1.	Accept @Year INT as an input parameter.
	2.	Aggregate sales based on product and year.
	3.	Execute stored procedure with dynamic inputs.
🔹 Expected Outcome: Running stored procedure should return total sales for the year 2022.
Enhancements:
	•	Modify procedure to fetch sales per region.
	•	Use TRY…CATCH for error handling in invalid year inputs.
*/

CREATE TABLE SalesReport (
    SaleID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Region VARCHAR(50),
    SalesYear INT,
    Amount DECIMAL(10, 2)
);

INSERT INTO SalesReport (SaleID, ProductName, Region, SalesYear, Amount) VALUES
(1, 'Laptop', 'North', 2022, 1200.00),
(2, 'Laptop', 'South', 2022, 1150.00),
(3, 'Mouse', 'East', 2022, 25.00),
(4, 'Keyboard', 'West', 2022, 45.00),
(5, 'Monitor', 'North', 2022, 300.00),
(6, 'Laptop', 'North', 2021, 1100.00),
(7, 'Keyboard', 'South', 2022, 50.00),
(8, 'Mouse', 'East', 2021, 20.00),
(9, 'Monitor', 'West', 2022, 280.00),
(10, 'Laptop', 'South', 2022, 1250.00),
(11, 'Mouse', 'North', 2023, 30.00),
(12, 'Monitor', 'East', 2022, 295.00),
(13, 'Keyboard', 'North', 2022, 55.00),
(14, 'Laptop', 'West', 2022, 1300.00),
(15, 'Monitor', 'South', 2023, 310.00);

CREATE PROCEDURE GetSalesByYear
    @Year INT
AS
    BEGIN TRY
        -- Validate if data for the input year exists
        IF NOT EXISTS (SELECT 1 FROM SalesReport WHERE SalesYear = @Year)
        BEGIN
            THROW 50001, 'Invalid year input: No sales data found for the given year.', 1;
        END

        -- Return total sales aggregated by Product and Region for the given year
        SELECT 
            ProductName,
            Region,
            SUM(Amount) AS TotalSales
        FROM SalesReport
        WHERE SalesYear = @Year
        GROUP BY ProductName, Region, SalesYear
        ORDER BY ProductName, Region;
    END TRY
    BEGIN CATCH
        -- Catch block returns error details
        SELECT
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine;
    END CATCH

EXEC GetSalesByYear @Year = 2021;
EXEC GetSalesByYear @Year = 2022;
EXEC GetSalesByYear @Year = 2023;
EXEC GetSalesByYear @Year = 2019;


/*
4. Stored Procedures: Dynamic Query Execution & Performance Tuning
Stored Procedure for Employee Bonus Calculation
Activity: Create a stored procedure that calculates bonus percentages dynamically.
Steps:
	1.	Accept @BaseSalary and @PerformanceRating as input parameters.
	2.	Determine bonus based on salary range.
	3.	Return final bonus amount.
 
🔹 Expected Outcome: Calling stored procedure should return a calculated bonus amount based on salary and rating.
*/

CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    Department VARCHAR(50),
    BaseSalary DECIMAL(10, 2),
    PerformanceRating INT  -- Assume rating is between 1 and 5
);

INSERT INTO Employee (EmployeeID, Name, Department, BaseSalary, PerformanceRating) VALUES
(1, 'Biswanth', 'HR', 50000.00, 5),
(2, 'Nageswara rao', 'Finance', 60000.00, 4),
(3, 'Niteesh', 'IT', 55000.00, 3);

CREATE PROCEDURE CalculateEmployeeBonus
    @BaseSalary DECIMAL(10,2),
    @PerformanceRating INT,
    @BonusPercentage DECIMAL(5,2) OUTPUT,
    @BonusAmount DECIMAL(10,2) OUTPUT,
    @EmpName VARCHAR(100) OUTPUT,
    @EmpID INT OUTPUT
AS
BEGIN
    DECLARE @BonusRate DECIMAL(5,2)

    -- Determine Bonus Rate
    SET @BonusRate = 
        CASE @PerformanceRating
            WHEN 5 THEN 0.20
            WHEN 4 THEN 0.15
            WHEN 3 THEN 0.10
            WHEN 2 THEN 0.05
            WHEN 1 THEN 0.02
            ELSE NULL
        END

    IF @BonusRate IS NULL
        THROW 50002, 'Invalid Performance Rating. Must be between 1 and 5.', 1;

    -- Set Output Values
    SET @BonusPercentage = @BonusRate * 100
    SET @BonusAmount = @BaseSalary * @BonusRate

    -- For demo purposes (since no table is linked), assign dummy values
    SET @EmpID = 101
    SET @EmpName = 'Biswanth'
END

-- Declare all OUTPUT variables before using them
DECLARE @BonusPct DECIMAL(5,2);   -- Assuming bonus percentage is like 10.50%
DECLARE @BonusAmt MONEY;          -- Bonus amount in currency
DECLARE @EmpName NVARCHAR(100);   -- Employee name
DECLARE @EmpID INT;               -- Employee ID

-- Execute the stored procedure
EXEC CalculateEmployeeBonus 
    @BaseSalary = 60000, 
    @PerformanceRating = 4,
    @BonusPercentage = @BonusPct OUTPUT,
    @BonusAmount = @BonusAmt OUTPUT,
    @EmpName = @EmpName OUTPUT,
    @EmpID = @EmpID OUTPUT;

-- Display the output
SELECT 
    @EmpID AS EmployeeID,
    @EmpName AS EmployeeName,
    @BonusPct AS BonusPercentage,
    @BonusAmt AS BonusAmount;