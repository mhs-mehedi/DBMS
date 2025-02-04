GO 
CREATE TRIGGER updateAmounts ON Transactions AFTER INSERT 
AS 
BEGIN 
	DECLARE @tranType CHAR(1) 
	DECLARE @tranQuantity INT 
	DECLARE @itemPrice DECIMAL(10,2) 
	DECLARE @custID CHAR(6) 
	SELECT @tranType = tran_type,@tranQuantity = tran_quantity,@custID = cust_id FROM INSERTED 
	IF (@tranType = 'S') 
		BEGIN 
			SELECT @itemPrice = item_price FROM Item WHERE item_id IN (SELECT item_id FROM INSERTED) 
			UPDATE CustomerAndSuppliers 
			SET sales_amnt = sales_amnt + (@itemPrice*@tranQuantity) WHERE cust_id = @custID 
		END 
	IF (@tranType = 'O') 
		BEGIN 
			SELECT @itemPrice = item_price FROM Item WHERE item_id IN (SELECT item_id FROM INSERTED) 
			UPDATE CustomerAndSuppliers 
			SET proc_amnt = proc_amnt + (@itemPrice*@tranQuantity) WHERE cust_id = @custID 
		END 
END 