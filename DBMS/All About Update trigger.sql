CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    Price DECIMAL(10, 2)
);

INSERT INTO Products (ProductID, ProductName, Price)
VALUES (1, 'Laptop', 1200.00),
       (2, 'Smartphone', 800.00),
       (3, 'Tablet', 600.00);

CREATE TABLE ProductAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    OldProductName NVARCHAR(100),
    NewProductName NVARCHAR(100),
    OldPrice DECIMAL(10,2),
    NewPrice DECIMAL(10,2),
    UpdatedBy NVARCHAR(50) DEFAULT SYSTEM_USER,
    UpdateDate DATETIME DEFAULT GETDATE()
);
CREATE TRIGGER LogProductUpdate
ON Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ProductAudit (ProductID, OldProductName, NewProductName, OldPrice, NewPrice, UpdatedBy, UpdateDate)
    SELECT 
        d.ProductID,
        d.ProductName AS OldProductName,
        i.ProductName AS NewProductName,
        d.Price AS OldPrice,
        i.Price AS NewPrice,
        SYSTEM_USER,
        GETDATE()
    FROM deleted d
    INNER JOIN inserted i ON d.ProductID = i.ProductID
    WHERE d.ProductName <> i.ProductName OR d.Price <> i.Price; -- Only log changes
END;

UPDATE Products
SET ProductName = 'Gaming Laptop', Price = 1500.00
WHERE ProductID = 1;

select * from Products


-----------------------------------------------------------------------------------------------------------
-- Problem 8: Automatically Adjust Customer Points After Purchase
-- Problem:
-- Whenever a customer’s purchase amount is updated, automatically adjust their loyalty points in the Customers table. For example, customers earn 1 loyalty point for every $100 spent.


CREATE TRIGGER AdjustCustomerPoints
ON Orders
AFTER UPDATE
AS
BEGIN
    DECLARE @CustomerID INT, @OrderAmount DECIMAL(10, 2), @PointsEarned INT;

    SELECT @CustomerID = CustomerID, @OrderAmount = TotalAmount FROM INSERTED;

    -- Calculate points earned: 1 point for every $100
    SET @PointsEarned = FLOOR(@OrderAmount / 100);

    -- Update the Customer's loyalty points
    UPDATE Customers
    SET LoyaltyPoints = LoyaltyPoints + @PointsEarned
    WHERE CustomerID = @CustomerID;
END;
