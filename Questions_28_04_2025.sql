use QUES_28_04;
/*
1. Create and Execute a Stored Procedure with Parameters
Objective: Learn to create a stored procedure with input parameters and execute it with different values.
Expected Outcome: A dynamic result set displaying employee information specific to the input department.
*/
CREATE TABLE Employees (
    EmployeeID INT,
    Name VARCHAR(100),
    DepartmentID INT,
    Salary DECIMAL(10,2)
);
INSERT INTO Employees (EmployeeID, Name, DepartmentID, Salary)
VALUES
(1, 'Biswanth', 1, 70000),
(2, 'Nageswara Rao', 2, 50000),
(3, 'Dheeraj', 1, 75000),
(4, 'Manikanta', 3, 60000),
(5, 'Yashwanth', 2, 65000);
-- 1.Create a stored procedure that retrieves employee details from an Employees table based on a department ID.
-- Pass the department ID as an input parameter.
CREATE PROCEDURE GetEmployeesByDepartment
    @DepartmentID INT
AS
BEGIN
    SELECT *
    FROM Employees
    WHERE DepartmentID = @DepartmentID;
END;
-- Test the stored procedure by calling it with multiple department IDs.
EXEC GetEmployeesByDepartment @DepartmentID = 1;
EXEC GetEmployeesByDepartment @DepartmentID = 2;

/*
2. Implement Error Handling in Stored Procedures
Objective: Understand how to add error handling in stored procedures using TRY...CATCH.
Task:
Create a stored procedure to insert data into a Products table.
Add error handling to catch primary key or unique constraint violations.
Log any errors into an ErrorLogs table with error details like error message and timestamp.
Expected Outcome: Successful logging of errors without disrupting the execution of other operations.
*/
CREATE TABLE Products (
    ProductID INT,
    ProductName VARCHAR(100),
    Price DECIMAL(10,2),
    Category VARCHAR(50)
);
INSERT INTO Products (ProductID, ProductName, Price, Category)
VALUES
(1, 'Watch', 70000, 'Electronics'),
(2, 'Smartphone', 40000, 'Electronics'),
(3, 'Chair', 50000, 'Furniture'),
(4, 'Speaker', 15000, 'Electronics'),
(5, 'Shirt', 2000, 'Clothing');
select * from Products;
--creating errorlog table
CREATE TABLE ErrorLogs (
    ErrorLogID INT IDENTITY(1,1),
    ErrorMessage VARCHAR(4000),
    ErrorTime DATETIME
);

CREATE PROCEDURE InsertProduct
    @ProductID INT,
    @ProductName VARCHAR(100),
    @Price DECIMAL(10,2)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Products (ProductID, ProductName, Price)
        VALUES (@ProductID, @ProductName, @Price);
    END TRY
    BEGIN CATCH
        INSERT INTO ErrorLogs (ErrorMessage, ErrorTime)
        VALUES (ERROR_MESSAGE(), GETDATE());
    END CATCH
END;
--testing 
EXEC InsertProduct @ProductID = 6, @ProductName = 'Device', @Price = 25000;
--generates error
EXEC InsertProduct @ProductID = 6, @ProductName = 'Another Device', @Price = 20000;
SELECT * FROM ErrorLogs;
SELECT * FROM Products;

/*
3. Stored Procedure for Data Modification
Objective: Practice using stored procedures to modify data in a table.
Task:
Create a stored procedure to update the salary of employees in an Employees table.
The procedure should take EmployeeID and NewSalary as input parameters.
Test the procedure by updating multiple employees’ salaries.
Expected Outcome: Employees’ salaries are updated in the database, and users can confirm via a SELECT query.
*/
CREATE PROC UEmployeeSalary 
    @EmployeeID INT,
    @NewSalary DECIMAL(10, 2)
AS
BEGIN
    -- Displaying the message and employee details before update
    SELECT 'Before update' AS Message;
    SELECT * FROM Employees WHERE EmployeeID = @EmployeeID;

    -- Updating the salary of the employee
    UPDATE Employees 
    SET Salary = @NewSalary 
    WHERE EmployeeID = @EmployeeID;

    -- Displaying the message and employee details after update
    SELECT 'After update' AS Message;
    SELECT * FROM Employees WHERE EmployeeID = @EmployeeID;
END
--testing
EXEC UEmployeeSalary @EmployeeID = 1, @NewSalary = 75000;
EXEC UEmployeeSalary @EmployeeID = 2, @NewSalary = 70000;
SELECT * FROM Employees;

/*
4. Stored Procedure with a Conditional Query
Objective: Use control flow in a stored procedure to return conditional results.
Task:
Create a stored procedure that accepts a category name as an input parameter.
Based on the category, return either all products from a Products table or a "Category not found" message if no products exist in the given category.
Test the procedure with valid and invalid category names.
Expected Outcome: Dynamic results displaying matching products or a custom error message.
*/
CREATE PROC GetProductsByCategory
    @CategoryName VARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT 5 FROM Products WHERE Category = @CategoryName)
        SELECT * FROM Products WHERE Category = @CategoryName;
    ELSE
        SELECT 'Category not found' AS Message;
END
--testing 
EXEC GetProductsByCategory 'Electronics';
EXEC GetProductsByCategory 'Gadgets';

/*
5. Stored Procedure with Output Parameters
Objective: Learn to use output parameters in stored procedures.
Task:
Create a stored procedure to calculate the total sales for a given CustomerID from a Sales table.
Pass the CustomerID as an input parameter and return the total sales amount as an output parameter.
Execute the procedure to retrieve total sales for multiple customers.
Expected Outcome: Accurate calculation of total sales and proper usage of output parameters.
*/
CREATE TABLE Sales (
    SaleID INT,
    CustomerID INT,
    Amount DECIMAL(10,2)
);
INSERT INTO Sales (SaleID, CustomerID, Amount)
VALUES
(1, 101, 10000),
(2, 102, 5000),
(3, 101, 3000),
(4, 103, 6000),
(5, 104, 15000);

CREATE PROCEDURE GetTotalSales
    @CustomerID INT,
    @TotalSales DECIMAL(10,2) OUTPUT
AS
BEGIN
    SELECT @TotalSales = ISNULL(SUM(Amount), 0)
    FROM Sales
    WHERE CustomerID = @CustomerID;
END;
--testing
DECLARE @Total DECIMAL(10, 2);
DECLARE @Customer INT = 101;
EXEC GetTotalSales @Customer,@Total OUTPUT;
SELECT @Total AS TotalSales, @Customer as CustomerID;

DECLARE @TotalSales DECIMAL(10, 2);
EXEC GetTotalSales 102, @TotalSales OUTPUT;
SELECT @TotalSales AS TotalSales;
