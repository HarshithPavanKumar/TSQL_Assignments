use QUES_01_05;
/*
1. PIVOT
Objective: Transform row data into columns using PIVOT.
Task:
	1.	Create a table named Sales with the columns: Region, Product, Year, and SalesAmount.
	2.	Populate the table with sample data for multiple regions, products, and years.
	3.	Write a query to display the total SalesAmount for each Product, with each Year as a column.
	4.	Add a query to reverse the PIVOT using the UNPIVOT operator.
*/

CREATE TABLE Sales (
    Region VARCHAR(50),
    Product VARCHAR(50),
    Year INT,
    SalesAmount INT
);

INSERT INTO Sales (Region, Product, Year, SalesAmount) VALUES
('North', 'Laptop', 2022, 1000),
('South', 'Mouse', 2022, 200),
('South', 'Laptop', 2022, 800),
('North', 'Mouse', 2023, 350),
('East', 'Laptop', 2023, 1100),
('West', 'Laptop', 2022, 950),
('East', 'Mouse', 2023, 270),
('West', 'Mouse', 2023, 320);

SELECT Product, [2022] AS Sales_2022, [2023] AS Sales_2023
FROM (
    SELECT Product, Year, SalesAmount
    FROM Sales
) AS SourceTable
PIVOT (
    SUM(SalesAmount) FOR Year IN ([2022], [2023])
) AS PivotTable;

SELECT Product, Year, SalesAmount
FROM (
    SELECT Product, [2022], [2023]
    FROM (
        SELECT Product, Year, SalesAmount
        FROM Sales
    ) AS SourceTable
    PIVOT (
        SUM(SalesAmount) FOR Year IN ([2022], [2023])
    ) AS Pivoted
) AS PivotResult
UNPIVOT (
    SalesAmount FOR Year IN ([2022], [2023])
) AS Unpivoted;

/*
2. SELECT INTO
Objective: Create a new table from an existing table.
Task:
	1.	Create a table named Employees with columns: EmployeeID, Name, Department, and Salary.
	2.	Insert sample data into the Employees table.
	3.	Use SELECT INTO to create a new table HighSalaryEmployees that stores data for employees earning above 60,000.
	4.	Verify the new table's structure and data.
*/

-- Create Employees Table
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(50),
    Department VARCHAR(50),
    Salary INT
);

-- Insert Sample Data
INSERT INTO Employees (EmployeeID, Name, Department, Salary) VALUES
(1, 'Biswanth', 'HR', 55000),
(2, 'Nagis', 'Finance', 72000),
(3, 'Harshith', 'IT', 67000),
(4, 'Niteesh', 'Marketing', 45000),
(5, 'Dheeraj', 'IT', 88000),
(6, 'Yashwanth', 'Support', 39000),
(7, 'Maynikanta', 'HR', 61000);

-- Create HighSalaryEmployees Table Using SELECT INTO
SELECT * 
INTO HighSalaryEmployees
FROM Employees
WHERE Salary > 60000;

-- View Data in HighSalaryEmployees
SELECT * FROM HighSalaryEmployees;

/*
3. CASE
Objective: Use CASE statements for conditional logic in queries.
Task:
	1.	Use the Employees table from the previous task.
	2.	Write a query to classify employees into salary ranges:
	◦	"Low" for salary < 40,000
	◦	"Medium" for salary between 40,000 and 60,000
	◦	"High" for salary > 60,000
	3.	Add a column named SalaryRange in your query, which uses CASE logic for classification.
*/

SELECT 
    EmployeeID,Name,Department,Salary,
    CASE 
        WHEN Salary < 40000 THEN 'Low'
        WHEN Salary BETWEEN 40000 AND 60000 THEN 'Medium'
		WHEN Salary IS NULL THEN 'Its Null'
        ELSE 'High'
    END AS SalaryRange
FROM Employees;

/*
4. COALESCE
Objective: Handle NULL values with COALESCE.
Task:
	1.	Create a table named Orders with columns: OrderID, CustomerName, OrderDate, and ShippedDate.
	2.	Insert some sample data, ensuring ShippedDate has some NULL values.
	3.	Write a query that replaces NULL in ShippedDate with the string "Not Shipped" using COALESCE.
	4.	Include a column named DeliveryStatus with the logic:
	◦	"Delivered" if ShippedDate is not NULL.
	◦	"Pending" if ShippedDate is NULL.
*/

-- Create the Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    OrderDate DATE,
    ShippedDate DATE
);

-- Insert sample data (some ShippedDate values are NULL)
INSERT INTO Orders (OrderID, CustomerName, OrderDate, ShippedDate) VALUES
(1, 'Biswanth', '2025-05-12', '2025-04-05'),
(2, 'nagi', '2025-04-27', NULL),
(3, 'Harshith', '2025-06-15', '2025-04-06'),
(4, 'Niteesh', '2025-04-06', NULL),
(5, 'Dheeraj', '2025-04-07', '2025-04-09');

-- Query with COALESCE and conditional column
SELECT 
    OrderID,
    CustomerName,
    OrderDate,
    COALESCE(CONVERT(VARCHAR, ShippedDate, 23), 'Not Shipped') AS ShippedStatus,
    CASE 
        WHEN ShippedDate IS NOT NULL THEN 'Delivered'
        ELSE 'Pending'
    END AS DeliveryStatus
FROM Orders;


/*
5. NULLIF
Objective: Use NULLIF for handling division errors.
Task:
	1.	Create a table named Scores with columns: StudentID, Subject, MarksObtained, and MaximumMarks.
	2.	Write a query to calculate Percentage as (MarksObtained * 100) / MaximumMarks.
	3.	Use NULLIF to handle cases where MaximumMarks is zero, preventing a division-by-zero error.
*/

-- Create the Scores table
CREATE TABLE Scores (
    StudentID INT,
    Subject VARCHAR(50),
    MarksObtained INT,
    MaximumMarks INT
);

-- Insert sample data (including a zero in MaximumMarks)
INSERT INTO Scores (StudentID, Subject, MarksObtained, MaximumMarks) VALUES
(1, 'social', 70, 100),
(2, 'biology', 90, 100),
(3, 'History', 70, 0),     
(4, 'English', 90, 100),
(5, 'Telugu', 95, 0);         

-- Query using NULLIF to prevent division by zero
SELECT 
    StudentID,
    Subject,
    MarksObtained,
    MaximumMarks,
    (MarksObtained * 100.0) / NULLIF(MaximumMarks, 0) AS Percentage
FROM Scores;

/*
6. DDL Statements with Constraints
Objective: Explore constraints such as UNIQUE, CHECK, NOT NULL, and FOREIGN KEY.
Task:
	1.	Create a table named Departments with columns: DepartmentID (Primary Key), DepartmentName (UNIQUE).
	2.	Create a table named Staff with columns:
	◦	StaffID (Primary Key)
	◦	StaffName (NOT NULL)
	◦	DepartmentID (FOREIGN KEY) referencing Departments
	◦	Age with a CHECK constraint ensuring Age > 18.
	3.	Insert valid data into both tables, and attempt to insert invalid data to test constraints.
*/


-- Create Departments table with constraints
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) UNIQUE
);
-- Create Staff table with constraints
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    StaffName VARCHAR(100) NOT NULL,
    DepartmentID INT,
    Age INT CHECK (Age > 18),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
-- Insert valid data into Departments
INSERT INTO Departments (DepartmentID, DepartmentName) VALUES
(1, 'Cloud labs'),
(2, 'saasify'),
(3, 'C3');

-- Insert valid data into Staff
INSERT INTO Staff (StaffID, StaffName, DepartmentID, Age) VALUES
(101, 'Biss', 1, 45),
(102, 'Nag', 2, 90),
(103, 'Niteesh', 3, 25); 

-- 1. Primary Key Violation (Duplicate StaffID)
INSERT INTO Staff (StaffID, StaffName, DepartmentID, Age)
VALUES (101, 'DuplicateID', 1, 29);

-- 2. UNIQUE Constraint Violation (Duplicate DepartmentName)
INSERT INTO Departments (DepartmentID, DepartmentName)
VALUES (4, 'HR');

-- 3. NOT NULL Violation (NULL StaffName)
INSERT INTO Staff (StaffID, StaffName, DepartmentID, Age)
VALUES (104, NULL, 2, 22);

-- 4. CHECK Constraint Violation (Age <= 18)
INSERT INTO Staff (StaffID, StaffName, DepartmentID, Age)
VALUES (105, 'Biss', 2, 17);

-- 5. FOREIGN KEY Violation (Non-existent DepartmentID)
INSERT INTO Staff (StaffID, StaffName, DepartmentID, Age)
VALUES (106, 'Dheeraj', 99, 27);

/*
7. TRUNCATE and DROP
Objective: Understand the differences between TRUNCATE and DROP.
Task:
	1.	Create a table named TemporaryData with some columns and populate it with test data.
	2.	Use TRUNCATE to remove all rows and verify that the table structure remains intact.
	3.	Use DROP to delete the TemporaryData table completely and verify its removal.
*/

-- Create the TemporaryData table
CREATE TABLE TemporaryData (
    ID INT,
    Name VARCHAR(50)
);


-- Insert some test data
INSERT INTO TemporaryData (ID, Name) VALUES
(1, 'Name1'),
(2, 'Name2'),
(3, 'Name3');


SELECT * FROM TemporaryData;

TRUNCATE TABLE TemporaryData;

SELECT * FROM TemporaryData;  

DROP TABLE TemporaryData;

SELECT * FROM TemporaryData;

/*

8. Data Types
Objective: Experiment with various SQL data types.
Task:
	1.	Create a table named Products with the following columns:
	◦	ProductID (INT, Primary Key)
	◦	ProductName (VARCHAR(50), NOT NULL)
	◦	Price (DECIMAL(10, 2))
	◦	StockQuantity (SMALLINT)
	◦	LaunchDate (DATE).
	2.	Insert data using valid data types.
	3.	Try inserting invalid data (e.g., text in Price, a string in LaunchDate) and observe the errors.
*/

-- Create the Products table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(50) NOT NULL,
    Price DECIMAL(10, 2),
    StockQuantity SMALLINT,
    LaunchDate DATE
);

-- Insert valid data
INSERT INTO Products (ProductID, ProductName, Price, StockQuantity, LaunchDate) VALUES
(1, 'Laptop', 59999.99, 50, '2023-10-01'),
(2, 'Smartphone', 29999.50, 150, '2024-01-15'),
(3, 'Tablet', 19999.00, 80, '2023-12-05');

SELECT * FROM Products;

-- Inserting text into Price (should be DECIMAL)
INSERT INTO Products (ProductID, ProductName, Price, StockQuantity, LaunchDate)
VALUES (4, 'Camera', 'TwentyThousand', 30, '2024-03-10');

-- Inserting string into LaunchDate (should be DATE)
INSERT INTO Products (ProductID, ProductName, Price, StockQuantity, LaunchDate)
VALUES (5, 'Monitor', 8999.99, 60, 'NotADate');

-- ProductName is NOT NULL but value is missing
INSERT INTO Products (ProductID, Price, StockQuantity, LaunchDate)
VALUES (6, 4999.00, 20, '2024-05-01');

-- StockQuantity out of SMALLINT range (-32,768 to 32,767)
INSERT INTO Products (ProductID, ProductName, Price, StockQuantity, LaunchDate)
VALUES (7, 'Heavy Product', 150000.00, 50000, '2024-06-10');