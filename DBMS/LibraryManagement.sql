CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(255),
    author VARCHAR(255),
    copies_available INT CHECK (copies_available >= 0)
);

CREATE TABLE members (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    current_borrowed INT DEFAULT 0 CHECK (current_borrowed >= 0 AND current_borrowed <= 5)
);

CREATE TABLE borrowing_records (
    record_id INT PRIMARY KEY,
    member_id INT REFERENCES members(member_id) ON DELETE CASCADE,
    book_id INT REFERENCES books(book_id) ON DELETE CASCADE,
    borrow_date DATE DEFAULT getdate(),
	due_date DATE,
    return_date DATE
);
--drop table borrowing_records

CREATE TABLE fines (
    fine_id INT PRIMARY KEY,
    member_id INT REFERENCES members(member_id) ON DELETE CASCADE,
    amount DECIMAL(10, 2),
    paid BIT DEFAULT 0,
);

INSERT INTO books (book_id, title, author, copies_available)
VALUES
(1, 'To Kill a Mockingbird', 'Harper Lee', 5),
(2, '1984', 'George Orwell', 3),
(3, 'The Great Gatsby', 'F. Scott Fitzgerald', 2),
(4, 'The Catcher in the Rye', 'J.D. Salinger', 4),
(5, 'Moby-Dick', 'Herman Melville', 0),
(6, 'Pride and Prejudice', 'Jane Austen', 6);

INSERT INTO members (member_id, member_name, email, current_borrowed)
VALUES
(1, 'John Doe', 'john.doe@example.com', 2),
(2, 'Alice Smith', 'alice.smith@example.com', 3),
(3, 'Bob Johnson', 'bob.johnson@example.com', 1),
(4, 'Emma Davis', 'emma.davis@example.com', 0),
(5, 'Michael Brown', 'michael.brown@example.com', 5),
(6, 'Sarah Wilson', 'sarah.wilson@example.com', 4);

select * from books
select * from members
select * from borrowing_records
select * from fines

exec borrow_proc @record_id=1, @member_id=1, @book_id =1, @borrow_date='2025-02-01', @due_date='2025-02-02', @return_date ='2025-02-03'


go
create proc borrow_proc @record_id int, @member_id int, @book_id int, @borrow_date date, @due_date date, @return_date date
as
begin
	declare @current_borrowed int
	select @current_borrowed=current_borrowed from members where member_id=@member_id
	if @current_borrowed<5
		begin
			if exists (select 1 from books where book_id=@book_id)
			
				insert into borrowing_records
				values(@record_id, @member_id , @book_id , @borrow_date ,@due_date, @return_date )
			
		
			else
			
				print('This Books is not available')
			
		end
	else
		begin
			raiserror('Maximum borrow limit reached',16,1)
			return
		end
end


drop proc borrow_proc

go
create proc return_proc
as
begin
	
end


go
create trigger insert_into_borrowing
on borrowing_records after insert
as
begin
	declare @copies_available int,@book_id int,@current_borrowed int,@member_id int
	select @book_id=book_id,@member_id=member_id from inserted
	select @copies_available=copies_available from books where book_id = @book_id
	select @current_borrowed=current_borrowed from members where member_id=@member_id
	update books
		set copies_available=@copies_available-1 where book_id=@book_id
	update members
		set current_borrowed=@current_borrowed+1 where member_id=@member_id
		
end