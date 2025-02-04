create database shop
create table products(
	product_id varchar(4) primary key check(product_id like '[P][0-9][0-9][0-9]'),
	product_name varchar(20) not null,
	manufacturer varchar(12),
	origin varchar(12) check (origin in ('Foreign','Local')),
	price money,
	qoh int
);

create table customers(
	customer_id varchar(4) primary key check (customer_id like '[C][0-9][0-9][0-9]'),
	first_name varchar(15) not null,
	last_name varchar(15) not null,
	city varchar(15) default 'Dhaka',
	total_sale int check(total_sale>0
	
);

create table transactions(
	tran_id varchar(4) primary key check (tran_id like '[T][0-9][0-9][0-9]'),
	tran_date date default getdate(),
	customer_id varchar(4) references customers(customer_id),
	product_id varchar(4) references products(product_id),
	quantity int check(quantity>0)
);


INSERT INTO products (product_id, product_name, manufacturer, origin, price, qoh) 
VALUES 
('P001', 'Laptop', 'Dell', 'Foreign', 75000, 50),
('P002', 'Smartphone', 'Samsung', 'Local', 30000, 100),
('P003', 'Headphones', 'Sony', 'Foreign', 5000, 200);

INSERT INTO customers (customer_id, first_name, last_name, city, total_sale) 
VALUES 
('C001', 'John', 'Doe', 'Dhaka', 500),
('C002', 'Jane', 'Smith', 'Chittagong', 300),
('C003', 'Alice', 'Brown', 'Sylhet', 100);

select * from products
select * from customers
select * from transactions

exec inserting @tran_id='T002',@tran_date='2025-01-19',
@customer_id='C001',@product_id='P002',@quantity=10

--------------------------STORED PROCEDURE--------------------------------------
go
create proc inserting @tran_id varchar(4),@tran_date date,
@customer_id varchar(4), @product_id varchar(4), @quantity int
as
begin 
	select @tran_id=tran_id, @tran_date=tran_date,@customer_id=customer_id, 
	@product_id=product_id,@quantity=quantity from transactions
	declare @current_qoh int
	select @current_qoh=qoh from products where product_id=@product_id

	if @quantity<@current_qoh
	begin
		insert into transactions
		values
		(@tran_id,@tran_date,@customer_id,@product_id,@quantity)
	end
	else
	begin
		print('Not enough products')
	end
end

-----------------------------------TRIGGER-----------------------------------
go
create trigger update_data
on transactions
after insert
as
begin
	declare @customer_id varchar(4), @product_id varchar(4),@quantity int,@qoh int,@total_sale int
	select @customer_id=customer_id,@product_id=product_id,@quantity=quantity from inserted
	update customers
	set
	total_sale=total_sale+@quantity where customer_id=@customer_id

	update products
	set
	qoh=qoh-@quantity where product_id=@product_id
end