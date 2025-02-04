CREATE TABLE students(
	student_id varchar(10) primary key check(student_id like '[S][0-9][0-9][0-9][0-9][0-9]'),
	first_name varchar(50) not null,
	last_name varchar(50) not null,
	date_of_birth date,
	email varchar(100) not null unique,
	enroll_date date not null
);

create table professor(
	professor_id varchar(10) primary key check(professor_id like '[P][0-9][0-9][0-9][0-9][0-9]'),
	first_name varchar(50) not null,
	last_name varchar(50) not null,
	email varchar(100) not null unique,
	department varchar(50) not null,
	hire_date date default getdate()
);

create table courses(
	course_id varchar(10) primary key check(course_id like '[C][0-9][0-9][0-9][0-9][0-9]'),
	course_name varchar(50) not null,
	course_code varchar(7) unique not null check(course_code like 'ICE[0-9][0-9][0-9][0-9]'),
	credits int check(credits>0),
	professor_id varchar(10) references professor(professor_id)
);

create table enrollment(
	enrollment_id varchar(10) primary key check(enrollment_id LIKE 'EN[0-9][0-9][0-9]'),
	student_id varchar(10) references students(student_id) on delete cascade,
	course_id varchar(10) references courses(course_id) on delete cascade,
	enroll_date date default getdate(),
	grade char(2) check(grade in ('A','B','C','D','F')),
	UNIQUE (student_id, course_id)
);

INSERT INTO students (student_id, first_name, last_name, date_of_birth, email, enroll_date) VALUES
('S00001', 'John', 'Doe', '2002-05-15', 'john.doe@example.com', '2023-08-20'),
('S00002', 'Alice', 'Smith', '2001-09-10', 'alice.smith@example.com', '2022-09-15'),
('S00003', 'Bob', 'Johnson', '2003-02-25', 'bob.johnson@example.com', '2024-01-10'),
('S00004', 'Emma', 'Davis', '2000-11-30', 'emma.davis@example.com', '2021-07-05');

INSERT INTO professor (professor_id, first_name, last_name, email, department, hire_date) VALUES
('P00001', 'Michael', 'Brown', 'michael.brown@university.edu', 'Computer Science', '2015-08-12'),
('P00002', 'Sarah', 'Miller', 'sarah.miller@university.edu', 'Mathematics', '2010-06-25'),
('P00003', 'Robert', 'Wilson', 'robert.wilson@university.edu', 'Physics', '2018-09-30');

INSERT INTO courses (course_id, course_name, course_code, credits, professor_id) VALUES
('C00001', 'Database Management', 'ICE1010', 3, 'P00001'),
('C00002', 'Machine Learning', 'ICE2020', 4, 'P00001'),
('C00003', 'Linear Algebra', 'ICE3030', 3, 'P00002'),
('C00004', 'Quantum Mechanics', 'ICE4040', 4, 'P00003');

INSERT INTO courses (course_id, course_name, course_code, credits, professor_id) VALUES
('C00005', 'Database Management Systems', 'ICE1110', 21, 'P00003')

INSERT INTO enrollment (enrollment_id, student_id, course_id, enroll_date, grade) VALUES
('EN001', 'S00001', 'C00001', '2023-09-01', 'A'),
('EN002', 'S00001', 'C00002', '2023-09-01', 'B'),
('EN003', 'S00002', 'C00001', '2022-09-10', 'A'),
('EN004', 'S00002', 'C00003', '2022-09-12', 'C'),
('EN005', 'S00003', 'C00004', '2024-01-15', NULL),
('EN006', 'S00004', 'C00003', '2021-07-10', 'B');

delete from enrollment where course_id='C00005'
exec record_enroll @enrollment_id='EN007',@student_id='S00003',@course_id='C00003',@enroll_date='2025-02-05',@grade='B'
exec record_enroll @enrollment_id='EN008',@student_id='S00001',@course_id='C00005',@enroll_date='2025-02-05',@grade='B'

select * from students
select * from courses
select * from professor
select * from enrollment

drop table students
drop table courses
drop table professor
drop table enrollment

delete from courses where course_id='C00003'

-----------------------------STORED PROCEDURE----------------------------------------

go
CREATE PROC record_enroll @enrollment_id varchar(10), @student_id varchar(10), 
@course_id varchar(10), @enroll_date date, @grade char(2)
as
begin
	declare @total_credit int,@new_credit int
	select @new_credit=credits from courses where course_id=@course_id
	SELECT @total_credit=sum(credits) from enrollment e join
	courses c on c.course_id=e.course_id where e.student_id=@student_id
	
	set @total_credit= @total_credit+@new_credit

	IF @total_credit>21
	begin
		raiserror('Credit Limit Exceeded',16,1)
		return
	end
	else
	begin
	    if exists (select 1 from courses where course_id=@course_id)
		begin
			insert into enrollment values
			(@enrollment_id , @student_id , @course_id,  @enroll_date, @grade)
		end
		else
		begin
			raiserror('This course doesn''t exist',16,1)
			return
		end
	end

end

drop proc record_enroll

---------------------------------------TRIGGER-------------------------------------------

go
create trigger deletion
on courses after delete
as
begin
	declare @course_id varchar(10)
	
	delete from enrollment where course_id in (select course_id from deleted)
end

DROP trigger deletion



