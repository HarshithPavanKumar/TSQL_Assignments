/*Assignment 1: Customer Order Management
Objective: Create and manage a stored procedure for order retrieval and updates in a customer database.
Setup:
Create a table named Customers with columns: CustomerID, FirstName, LastName, Email, PhoneNumber.
Create another table named Orders with columns: OrderID, CustomerID, OrderDate, OrderTotal, OrderStatus.
Task 1: Write a stored procedure GetCustomerOrders that:
Accepts a CustomerID as a parameter.
Returns all orders for the specified customer, including their OrderTotal and OrderStatus.
Task 2: Write a stored procedure UpdateOrderStatus that:
Accepts parameters for OrderID and NewStatus.
Updates the OrderStatus for the given OrderID.
Returns a confirmation message if the update was successful.
Bonus Challenge: Add validation in UpdateOrderStatus to ensure the OrderID exists before updating, and return an error message if it doesn't.*/

use QUES_29_04;
-- Create Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(25),
    LastName VARCHAR(25),
    Email VARCHAR(25),
    PhoneNumber VARCHAR(25)
);

INSERT INTO Customers (CustomerID, FirstName, LastName, Email, PhoneNumber) VALUES
(1, 'Biswanth', 'ch', 'Biss@gmail.com', 8330965896),
(2, 'Nageswara Rao', 'N', 'NN@gmail.com', 7093896106),
(3, 'Harshith', 'S', 'harshith@gmail.com', 8074641549);


-- Create Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate DATE,
    OrderTotal DECIMAL(10, 2),
    OrderStatus VARCHAR(20)
);

INSERT INTO Orders (OrderID, CustomerID, OrderDate, OrderTotal, OrderStatus) VALUES
(101, 1, '2025-09-26', 175.34, 'Pending'),
(102, 1, '2025-09-27', 69.34, 'Shipped'),
(103, 2, '2025-09-28', 120.00, 'Processing'),
(104, 3, '2025-09-29', 45.50, 'Delivered'),
(105, 2, '2025-09-30', 60.00, 'Cancelled');

CREATE PROCEDURE GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT 
        o.OrderID,
        o.OrderDate,
        o.OrderTotal,
        o.OrderStatus
    FROM Orders o
    WHERE o.CustomerID = @CustomerID;
END;

EXEC GetCustomerOrders @CustomerID=1
GO

CREATE PROCEDURE UpdateOrderStatus
    @OrderID INT,
    @NewStatus NVARCHAR(20)
AS
BEGIN
    -- Checking if order exists
    IF EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
    BEGIN
        UPDATE Orders
        SET OrderStatus = @NewStatus
        WHERE OrderID = @OrderID;

        SELECT 'Order status updated successfully.' AS Message;
    END
    ELSE
    BEGIN
        SELECT 'Error: OrderID does not exist.' AS Message;
    END
END;

EXEC UpdateOrderStatus @OrderID = 101, @NewStatus = 'Shipped';
select * from Orders

/*Assignment 2: Inventory Stock Management
Objective: Design stored procedures to track and manage product inventory in a warehouse.
Setup:
Create a table named Products with columns: ProductID, ProductName, Category, StockQuantity, Price.
Task 1: Write a stored procedure GetLowStockProducts that:
Retrieves all products with StockQuantity below a specified threshold.
Accepts the threshold value as a parameter.
Task 2: Write a stored procedure RestockProduct that:
Accepts ProductID and QuantityToAdd as parameters.
Increases the StockQuantity for the specified ProductID.
Returns the updated StockQuantity.
Bonus Challenge: Modify RestockProduct to log the restocking activity into a separate table called RestockLog with columns : LogID, ProductID, RestockDate, QuantityAdded*/


-- Create Products table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category NVARCHAR(50),
    StockQuantity INT,
    Price DECIMAL(10, 2)
);
INSERT INTO Products (ProductID, ProductName, Category, StockQuantity, Price) VALUES
(1, 'Laptop', 'Electronics', 10, 15.99),
(2, 'Smart Phone', 'Electronics', 25, 9.49),
(3, 'Books', 'Stationery', 100, 3.25),
(4, 'Pencil', 'Stationery', 10, 0.99);

CREATE PROCEDURE GetLowStockProducts
@thresholdvalue INT
AS
BEGIN
SELECT * FROM Products WHERE StockQuantity<@thresholdvalue
END

EXEC GetLowStockProducts @thresholdvalue =100;



CREATE TABLE RestockLogg (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    RestockDate DATETIME,
    QuantityAdded INT
);


-- Restock stored procedure
CREATE   PROCEDURE RestockProduct
    @pID INT,
    @QuantityToAdd INT
AS
BEGIN
    -- Check if product exists
    IF EXISTS (SELECT 1 FROM Products WHERE ProductID = @pID)
    BEGIN
        -- Update stock quantity
        UPDATE Products
        SET StockQuantity = StockQuantity + @QuantityToAdd
        WHERE ProductID = @pID;

        -- Insert restock log
        INSERT INTO RestockLogg (ProductID, RestockDate, QuantityAdded)
        VALUES (@pID, GETDATE(), @QuantityToAdd);

        -- Return updated stock
        SELECT 
            ProductID, 
            ProductName, 
            StockQuantity 
        FROM Products 
        WHERE ProductID = @pID;
    END
    ELSE
    BEGIN
        SELECT 'Error: ProductID does not exist.' AS Message;
    END
END;
GO


EXEC RestockProduct @pID = 1, @QuantityToAdd = 100

select * from RestockLogg

select * from Products