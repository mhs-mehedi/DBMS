CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department VARCHAR(50),
    base_salary DECIMAL(10, 2) CHECK (base_salary > 0),
    bonus_eligible bit DEFAULT 0
);

CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY identity(1,1),
    employee_id INT REFERENCES employees(employee_id) ON DELETE CASCADE,
    attendance_date DATE,
    employee_status varchar(15) check(employee_status in ('Present', 'Absent')) DEFAULT 'Absent' 
);

CREATE TABLE payroll (
    payroll_id INT PRIMARY KEY identity(1,1),
    employee_id INT  REFERENCES employees(employee_id) ON DELETE CASCADE,
    payroll_date date,
    days_worked INT CHECK (days_worked >= 0),
    total_salary DECIMAL(10, 2)
);

CREATE TABLE bonuses (
    bonus_id INT PRIMARY KEY identity(1,1),
    employee_id INT REFERENCES employees(employee_id) ON DELETE CASCADE,
    bonus_amount DECIMAL(10, 2) CHECK (bonus_amount > 0),
    awarded_date DATE DEFAULT getdate()
);

go
create proc record  @employee_id int,@days_worked int,@payroll_date date
as
begin
	declare @total_salary decimal(10,2),@base_salary decimal(10,2),@total_days int
	select @base_salary=base_salary from employees where employee_id=@employee_id
	set @total_days=30
	set @total_salary=(@base_salary/@total_days)*@days_worked
	if @days_worked>20
	begin
		set @total_salary=@total_salary*1.05
		insert into bonuses(employee_id,bonus_amount)
		values
		(@employee_id,@base_salary*0.05)
	end 
	else
	begin
		set @total_salary=@total_salary
	end 
	insert into payroll (employee_id,payroll_date,days_worked,total_salary)
	values
	(@employee_id,@payroll_date,@days_worked,@total_salary)
end

go
create trigger updating
on employees after delete
as
begin
	declare @employee_id int
	select @employee_id=employee_id from deleted
	delete from payroll where employee_id=@employee_id
	delete from attendance where employee_id=@employee_id
end



INSERT INTO employees (employee_id, employee_name, department, base_salary, bonus_eligible) VALUES
(1, 'John Doe', 'Sales', 50000.00, 1),  -- Eligible for bonus
(2, 'Jane Smith', 'IT', 60000.00, 1),   -- Eligible for bonus
(3, 'Samuel Clark', 'HR', 45000.00, 0), -- Not eligible for bonus
(4, 'Emma Wilson', 'Marketing', 55000.00, 1),  -- Eligible for bonus
(5, 'David Brown', 'Finance', 70000.00, 0);  -- Not eligible for bonus

INSERT INTO attendance (employee_id, attendance_date, employee_status) VALUES
(1, '2025-02-01', 'Present'),
(1, '2025-02-02', 'Absent'),
(2, '2025-02-01', 'Present'),
(2, '2025-02-02', 'Present'),
(3, '2025-02-01', 'Absent'),
(3, '2025-02-02', 'Present'),
(4, '2025-02-01', 'Present'),
(4, '2025-02-02', 'Present'),
(5, '2025-02-01', 'Absent'),
(5, '2025-02-02', 'Absent');

SELECT * FROM employees
SELECT * FROM attendance
SELECT * FROM payroll
SELECT * FROM bonuses

exec record @employee_id=2, @days_worked=21, @payroll_date='2025-01-15'
delete from employees where employee_id=1

