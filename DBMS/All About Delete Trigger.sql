-- Prevent order deletion which is pending


CREATE TRIGGER PreventProductDeletionWithPendingOrders
ON Products
AFTER DELETE
AS
BEGIN
    DECLARE @ProductID VARCHAR(6);

    SELECT @ProductID = ProductID FROM DELETED;

    -- Check if there are any pending orders for the product
    IF EXISTS (SELECT 1 FROM OrderDetails WHERE ProductID = @ProductID AND OrderStatus = 'Pending')
    BEGIN
        RAISERROR('Cannot delete the product because it has pending orders.', 16, 1);
        ROLLBACK;
    END
END;


----------------------------------------------------------------------------------------------------
-- Archieve deleted customers and their orders
CREATE TRIGGER ArchiveCustomerDeletion
ON Customers
AFTER DELETE
AS
BEGIN
    DECLARE @CustomerID INT;

    SELECT @CustomerID = CustomerID FROM DELETED;

    -- Archive customer details and their orders before deletion
    INSERT INTO CustomerArchive (CustomerID, CustomerName, CustomerAddress, DeletionDate)
    SELECT CustomerID, CustomerName, CustomerAddress, GETDATE() FROM DELETED;

    INSERT INTO OrderArchive (CustomerID, OrderID, OrderAmount, OrderDate)
    SELECT CustomerID, OrderID, OrderAmount, OrderDate FROM Orders WHERE CustomerID = @CustomerID;

    -- Optionally, delete related orders after archiving
    DELETE FROM Orders WHERE CustomerID = @CustomerID;
END;

------------------------------------------------------------------------------------------
-- Prevent customer deletion with unpaid orders
CREATE TRIGGER PreventCustomerDeletionWithUnpaidOrders
ON Customers
AFTER DELETE
AS
BEGIN
    DECLARE @CustomerID INT;

    SELECT @CustomerID = CustomerID FROM DELETED;

    -- Check if the customer has any unpaid orders
    IF EXISTS (SELECT 1 FROM Orders WHERE CustomerID = @CustomerID AND PaymentStatus = 'Unpaid')
    BEGIN
        RAISERROR('Cannot delete customer with unpaid orders.', 16, 1);
        ROLLBACK;
    END
END;
