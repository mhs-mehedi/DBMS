use pubs
/*---------------------1. Joining Tables-----------------------*/
select au_lname,title_id from authors inner join titleauthor on authors.au_id=titleauthor.au_id

/*Task 1 (i) : Show the title of a book and the corresponding author name*/
select title,
au_lname+' '+au_fname as author_name
from titles join titleauthor on titles.title_id=titleauthor.title_id
join authors on titleauthor.au_id=authors.au_id


/*Task 1 (ii) :  Show the title of a book, the corresponding author name and publisher name*/
select title,au_lname+' '+au_fname as author_name,pub_name 
from titles join titleauthor on titles.title_id=titleauthor.title_id
join authors on titleauthor.au_id=authors.au_id
join publishers on titles.pub_id=publishers.pub_id

/*---------------------2. The Cartesian product--------------------*/
select au_lname,pub_name from authors,publishers

/*Task 2*/

select au_lname+' '+au_fname as author_name,
authors.city as CITY,pub_name
from authors join titleauthor on authors.au_id=titleauthor.au_id
join titles on titleauthor.title_id=titles.title_id
join publishers on titles.pub_id=publishers.pub_id where publishers.city=authors.city

/*-----------------3. Nested Query------------------*/
select * from titles where royalty=(select avg(royalty) from titles)

/*Task 3*/

select au_lname+' '+au_fname as authors_name
from authors join titleauthor on authors.au_id=titleauthor.au_id
join titles on titleauthor.title_id=titles.title_id
where royalty in (select max(royalty) from titles)    /*Use 'IN' when it returns more than one value*/
													  /* Use '=' when it returns only one value*/

/*----------------------4. Creating a Table----------------------*/

create table CustomerAndSuppliers(
	cust_id varchar(6) primary key 
	check (cust_id like '[C|S][0-9][0-9][0-9][0-9][0-9]'),

	cust_fname varchar(15) NOT NULL,
	cust_lname varchar(15),
	cust_address text,
	cust_telno varchar(12) check(cust_telno like '[0-9][0-9][0-9][-][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	cust_city varchar(12) default 'Rajshahi',
	sales_amount money check (sales_amount>0),
	proc_amount money check (proc_amount>0)
);

select * from CustomerAndSuppliers


/*---------------------5. Inserting Data into a Tablee------------------*/

insert into CustomerAndSuppliers
(cust_id, cust_fname, cust_lname,cust_address,cust_city,cust_telno,sales_amount,proc_amount)
values
('C00001','Iqbal','Hossain','Binodpur','Rajshahi','012-34567890', 12,1)

/*---------------------6. Create Item table-----------------------*/
create table item(
	item_id varchar(6) primary key
	check (item_id like '[P][0-9][0-9][0-9][0-9][0-9]'),

	item_name varchar(12),
	item_category varchar(12),
	item_price float check(item_price>0),
	item_qoh int check(item_qoh>0),
	item_last_sold date default getdate()

);
-- Insert sample items into the `item` table

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh, item_last_sold)
VALUES ('P00001', 'Laptop', 'Electronics', 799.99, 10, '2025-01-01');

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh, item_last_sold)
VALUES ('P00002', 'Tablet', 'Electronics', 499.99, 25, '2024-12-31');

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh)
VALUES ('P00003', 'Chair', 'Furniture', 99.99, 50); -- Uses default `item_last_sold` as today

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh)
VALUES ('P00004', 'Desk', 'Furniture', 149.49, 15); -- Uses default `item_last_sold` as today

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh, item_last_sold)
VALUES ('P00005', 'Smartphone', 'Electronics', 999.49, 20, '2024-12-15');

-- More sample data for the `item` table

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh, item_last_sold)
VALUES ('P00006', 'Monitor', 'Electronics', 249.99, 30, '2025-01-10');

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh)
VALUES ('P00007', 'Keyboard', 'Electronics', 49.99, 100); -- Defaults to today's date for item_last_sold

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh, item_last_sold)
VALUES ('P00008', 'Sofa', 'Furniture', 899.49, 5, '2025-01-05');

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh)
VALUES ('P00009', 'Table Lamp', 'Lighting', 29.99, 40); -- Defaults to today's date for item_last_sold

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh, item_last_sold)
VALUES ('P00010', 'Air Fryer', 'Appliances', 129.95, 20, '2024-12-20');

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh)
VALUES ('P00011', 'Bed Frame', 'Furniture', 399.99, 12); -- Defaults to today's date for item_last_sold

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh, item_last_sold)
VALUES ('P00012', 'Headphones', 'Electronics', 199.99, 50, '2025-01-15');

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh, item_last_sold)
VALUES ('P00013', 'Blender', 'Appliances', 89.95, 35, '2024-12-30');

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh, item_last_sold)
VALUES ('P00014', 'Wall Clock', 'Decor', 24.95, 25, '2024-12-28');

INSERT INTO item (item_id, item_name, item_category, item_price, item_qoh)
VALUES ('P00015', 'Bookshelf', 'Furniture', 129.99, 15); -- Defaults to today's date for item_last_sold

select * from item
drop table item
select avg(item_price) from item where item_category='Electronics'



/*-------------------7. Create Transaction table------------------------*/
create table transactions(
	tran_id varchar(10) primary key,
	check (tran_id like 'T[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),

	item_id varchar(6),
	constraint chk_item_id foreign key(item_id) references item(item_id),

	cust_id varchar(6),
	constraint chk_cust_id foreign key(cust_id) references CustomerAndSuppliers(cust_id),
	
	/*learn to declare foreign key
	with refernece to another table*/

	tran_type char check(tran_type like '[S|O)]'),
	tran_quantity int check(tran_quantity>0),
	tran_date datetime default getdate()       /*both date and time type column*/

);
-- foreign key te insert koarar smy oi table er primary key match krte hbe....parent table a oi 
-- key ta thakte hbe...jemon transactions table a item_id and cust_id ai 2 tay insert krar smy 
-- kheyal rakhte hbe jate item table and CustomersAndSuppliers table a oi item_id and cust_id thakte hbe nahle error assbe

/*-- Matches values that start with 'T', have any second character, and end with 'E' (e.g., 'Take', 'Tone')
SELECT * FROM table_name WHERE column_name LIKE 'T_E%';

-- Matches values with exactly 5 characters, where the first is 'H' and the last is 'N' (e.g., 'Human', 'Heaven')
SELECT * FROM table_name WHERE column_name LIKE 'H___N';*/
