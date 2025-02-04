/*-----------------------1. Stored Procedure----------------------------*/
CREATE PROC ShowTitleAndAuthor
AS
BEGIN
	SELECT "Authors_last_name"= au_lname from authors where au_id in (select au_id from titleauthor where title_id='BU1032')
END

EXEC ShowTitleAndAuthor
DROP proc ShowTitleAndAuthor

/*--------------------2. Parameterized Stored Procedure---------------*/
GO
ALTER PROC ShowTitleAndAuthor @titleid char(15)
AS
BEGIN
	SELECT au_lname as "Authors Last Name" from
	authors where au_id IN (SELECT au_id from titleauthor WHERE title_id=@titleid)
END
EXEC ShowTitleAndAuthor @titleid='BU1035'

/*-----------------------3. Stored procedure with decision making----------------------*/
go
create proc update_price 
@titleid varchar(12)
as
begin
	declare @price money
	select @price=price from titles where title_id=@titleid
	set  @price=@price+0.1*@price
	if @price<20
	update titles set price=@price where title_id=@titleid
end

exec update_price 'BU7832'

/*-------------------------Task 1-------------------*/

select item_category,sum(item_qoh) as Total_Items, avg(item_price) as average_price from item 
group by item_category



/*------------------------Task 3-------------------------*/
go
create proc show_cheaper
@item_category varchar(15), @price_value money
as
begin
	select * from item where item_category=@item_category and item_price<@price_value
end

exec show_cheaper @item_category='Electronics', @price_value=500

/*-----------------Task 4------------------*/

GO 
CREATE PROCEDURE printDetails2 
@itemCategory CHAR(10),@desiredAvgValue FLOAT 
AS 
BEGIN 
	DECLARE @totalPrice DECIMAL(10,2),@totalItem INT,@currentAvgPrice FLOAT 
	SELECT @totalPrice = SUM(item_price),@totalItem = COUNT(*) FROM Item 
	WHERE item_category = @itemCategory 
	SET @currentAvgPrice = @totalPrice/@totalItem 
	WHILE @currentAvgPrice<@desiredAvgValue 
		BEGIN 
			UPDATE Item 
			SET item_price = item_price + 0.1*(item_price) WHERE item_category = @itemCategory 
			SELECT @totalPrice = SUM(item_price) FROM Item WHERE item_category = @itemCategory 
			SET @currentAvgPrice = @totalPrice/@totalItem 
		END 
	SELECT item_category,AVG(item_price) newAvgPrice FROM Item WHERE item_category = @itemCategory 
	GROUP BY item_category 
END 

EXEC printDetails2 @itemCategory = 'Books',@desiredAvgValue = 1500;