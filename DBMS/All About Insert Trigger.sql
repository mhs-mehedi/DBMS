Create TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID varchar(6) unique,
    OrderAmount DECIMAL(10, 2),
    OrderDate DATETIME DEFAULT GETDATE()
);
drop table Auditlog
CREATE TABLE AuditLog (
    OrderID INT primary key,
    CustomerID varchar(6) , constraint chk foreign key(CustomerID) references Orders(CustomerID),
    OrderAmount DECIMAL(10, 2),
    InsertTimestamp DATETIME
);
go
CREATE TRIGGER LogOrderInsertion
ON Orders
AFTER INSERT
AS
BEGIN
    -- Declare a variable to hold the inserted order amount
    DECLARE @OrderAmount DECIMAL(10, 2);
    DECLARE @CustomerID varchar(6);
    DECLARE @OrderID INT;

    -- Get the inserted order's values (assuming only one row is inserted at a time)
    SELECT @OrderID = OrderID, @CustomerID = CustomerID, @OrderAmount = OrderAmount
    FROM INSERTED;

    -- Check if the order amount is less than $100 and prevent insertion if true
    IF @OrderAmount < 100
    BEGIN
        -- Rollback the insert if the amount is too low
		SET NOCOUNT ON
        RAISERROR('Order amount must be greater than or equal to $100', 16, 1);
        ROLLBACK;
        RETURN;
    END

    -- Insert a log entry into the AuditLog table
    INSERT INTO AuditLog (OrderID, CustomerID, OrderAmount, InsertTimestamp)
    VALUES (@OrderID, @CustomerID, @OrderAmount, GETDATE());
    
END;
select * from Auditlog
drop trigger LogOrderInsertion
INSERT INTO Orders (OrderID, CustomerID, OrderAmount, OrderDate)
VALUES 
(1, 'C00001', 150.75, '2025-01-10');

INSERT INTO Orders (OrderID, CustomerID, OrderAmount, OrderDate)
VALUES 
(4, 'C00004', 169.75, '2025-01-10');

-------------------------------------------------------------------------------------
-- Decrese the stock

CREATE TRIGGER UpdateInventory
ON Orders
AFTER INSERT
AS
BEGIN
    DECLARE @OrderID INT, @ProductID VARCHAR(6), @OrderQuantity INT;

    -- Get the inserted values from the INSERTED table
    SELECT @OrderID = OrderID, @ProductID = ProductID, @OrderQuantity = OrderQuantity
    FROM INSERTED;

    -- Update the product stock in the Products table
    UPDATE Products
    SET ProductQuantity = ProductQuantity - @OrderQuantity
    WHERE ProductID = @ProductID;
END;

-----------------------------------------------------------------------------------
-- Preventing duplicate inserts
CREATE TRIGGER PreventDuplicateOrder
ON Orders
AFTER INSERT
AS
BEGIN
    DECLARE @OrderID INT;

    -- Get the inserted OrderID
    SELECT @OrderID = OrderID FROM INSERTED;

    -- Check if the OrderID already exists in the table
    IF EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
    BEGIN
        RAISERROR('Duplicate OrderID detected. Insertion aborted.', 16, 1);
        ROLLBACK;
    END;
END;
--------------------------------------------------------------------------------
-- Modifying inserted data
CREATE TRIGGER FixProductIDFormat
ON Orders
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @ProductID VARCHAR(6);

    -- Get the inserted ProductID
    SELECT @ProductID = ProductID FROM INSERTED;

    -- Add leading zero if missing
    IF LEN(@ProductID) = 5
    BEGIN
        SET @ProductID = '0' + @ProductID;
    END

    -- Insert the corrected data
    INSERT INTO Orders (OrderID, ProductID, OrderQuantity)
    SELECT OrderID, @ProductID, OrderQuantity FROM INSERTED;
END;
------------------------------------------------------------------------------------------
-- Keep track of the differeneces/changes
CREATE TRIGGER LogPriceChange
ON Orders
AFTER INSERT
AS
BEGIN
    DECLARE @OrderID INT, @OldPrice DECIMAL(10,2), @NewPrice DECIMAL(10,2);

    -- Get the old and new prices from the DELETED and INSERTED tables
    SELECT @OldPrice = OrderAmount FROM DELETED;
    SELECT @NewPrice = OrderAmount FROM INSERTED;

    -- If there's a price change, log it in the PriceChangeLog
    IF @OldPrice <> @NewPrice
    BEGIN
        INSERT INTO PriceChangeLog (OrderID, OldPrice, NewPrice, ChangeDate)
        VALUES (@OrderID, @OldPrice, @NewPrice, GETDATE());
    END
END;
-------------------------------------------------------------------------------------------
-- Working with Multiple Row Inserts/iterate through the each row
CREATE TRIGGER UpdateInventoryMultipleOrders
ON Orders
AFTER INSERT
AS
BEGIN
    DECLARE @ProductID VARCHAR(6), @OrderQuantity INT;

    -- Loop through the inserted rows
    DECLARE order_cursor CURSOR FOR
    SELECT ProductID, OrderQuantity FROM INSERTED;

    OPEN order_cursor;
    FETCH NEXT FROM order_cursor INTO @ProductID, @OrderQuantity;

    -- Loop through each order and update the inventory
    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE Products
        SET ProductQuantity = ProductQuantity - @OrderQuantity
        WHERE ProductID = @ProductID;

        FETCH NEXT FROM order_cursor INTO @ProductID, @OrderQuantity;
    END;

    CLOSE order_cursor;
    DEALLOCATE order_cursor;
END;