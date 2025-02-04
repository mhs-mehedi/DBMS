CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10, 2) CHECK (price > 0),
    stock INT CHECK (stock >= 0),
    low_stock_flag bit DEFAULT 0
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100) UNIQUE
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE DEFAULT getdate(),
    total_amount DECIMAL(10, 2) 
);

CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY IDENTITY(1,1),
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id),
    quantity INT CHECK (quantity > 0),
    price DECIMAL(10, 2) 
);
insert into orders (customer_id,order_date,total_amount) values(101,'2025-02-10',100)

INSERT INTO products (product_id, product_name, price, stock, low_stock_flag)
VALUES
(1, 'Laptop', 999.99, 50, 0),
(2, 'Smartphone', 499.99, 200, 0),
(3, 'Headphones', 89.99, 0, 1),  -- Low stock, marked with flag 1
(4, 'Keyboard', 39.99, 150, 0),
(5, 'Mouse', 29.99, 300, 0),
(6, 'Monitor', 199.99, 10, 1);  -- Low stock, marked with flag 1

INSERT INTO customers (customer_id, customer_name, email)
VALUES
(101, 'John Doe', 'john.doe@example.com'),
(102, 'Alice Smith', 'alice.smith@example.com'),
(103, 'Bob Johnson', 'bob.johnson@example.com'),
(104, 'Emma Davis', 'emma.davis@example.com'),
(105, 'Michael Brown', 'michael.brown@example.com');

SELECT * FROM products
SELECT * FROM customers
SELECT * FROM orders
SELECT * FROM order_details
