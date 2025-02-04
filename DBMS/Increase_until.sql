create table items(
	items_id varchar(6) primary key
	check (items_id like '[P][0-9][0-9][0-9][0-9][0-9]'),

	items_name varchar(12),
	items_category varchar(12),
	items_price float check(items_price>0),
	items_qoh int check(items_qoh>0),
	items_last_sold date default getdate()

);


INSERT INTO items (items_id, items_name, items_category, items_price, items_qoh, items_last_sold)
VALUES ('P00001', 'Laptop', 'Electronics', 799.99, 10, '2025-01-01');

INSERT INTO items (items_id, items_name, items_category, items_price, items_qoh, items_last_sold)
VALUES ('P00002', 'Tablet', 'Electronics', 399.99, 25, '2024-12-31');

INSERT INTO items (items_id, items_name, items_category, items_price, items_qoh)
VALUES ('P00003', 'Chair', 'Furniture', 99.99, 50); -- Uses default `items_last_sold` as today

INSERT INTO items (items_id, items_name, items_category, items_price, items_qoh)
VALUES ('P00004', 'Desk', 'Furniture', 149.49, 15); -- Uses default `items_last_sold` as today

INSERT INTO items (items_id, items_name, items_category, items_price, items_qoh, items_last_sold)
VALUES ('P00005', 'Smartphone', 'Electronics', 699.49, 20, '2024-12-15');

-- More sample data for the `items` table

INSERT INTO items (items_id, items_name, items_category, items_price, items_qoh, items_last_sold)
VALUES ('P00006', 'Monitor', 'Electronics', 149.99, 30, '2025-01-10');

INSERT INTO items (items_id, items_name, items_category, items_price, items_qoh)
VALUES ('P00007', 'Keyboard', 'Electronics', 49.99, 100); -- Defaults to today's date for items_last_sold

INSERT INTO items (items_id, items_name, items_category, items_price, items_qoh, items_last_sold)
VALUES ('P00008', 'Sofa', 'Furniture', 899.49, 5, '2025-01-05');

INSERT INTO items (items_id, items_name, items_category, items_price, items_qoh)
VALUES ('P00009', 'Table Lamp', 'Lighting', 29.99, 40); -- Defaults to today's date for items_last_sold

INSERT INTO items (items_id, items_name, items_category, items_price, items_qoh, items_last_sold)
VALUES ('P00010', 'Air Fryer', 'Appliances', 129.95, 20, '2024-12-20');

INSERT INTO items (items_id, items_name, items_category, items_price, items_qoh)
VALUES ('P00011', 'Bed Frame', 'Furniture', 399.99, 12);

-- 799,399,699,149,49

select avg(items_price) from items where items_category='Electronics'
select * from items

go
create proc increase @item_category varchar(15), @desired_value float
as
begin
	declare @current_avg float
	select @current_avg=avg(items_price) from items where items_category=@item_category
	while @current_avg<@desired_value
		begin
		update items
		set items_price=1.1*items_price where items_category=@item_category

		select @current_avg=avg(items_price) from items where items_category=@item_category
		end
end

drop proc increase
exec increase @item_category = 'Electronics' , @desired_value=600