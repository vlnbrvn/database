--Part 1
--1.1

CREATE TABLE employees(
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK ( age>=18 AND age <=65 ),
    salary NUMERIC CHECK (salary > 0)

);

--1.2
CREATE TABLE products_catalog(
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount(
    regular_price > 0 AND
    discount_price > 0 AND
    discount_price < regular_price
)
);

--1.3
CREATE TABLE bookings(
    book_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK ( num_guests BETWEEN 1 AND 10 ),
   CONSTRAINT valid_date CHECK ( check_out_date > check_in_date )
);

--1.4
INSERT INTO employees VALUES (1,'Mary', 'Pak', 40, 35000);
INSERT INTO employees VALUES (2,'Peter', 'Beast', 52, 300000);
INSERT INTO products_catalog VALUES (1, 'Phone', 50000, 45000);
INSERT INTO bookings VALUES (1, '2026-12-02', '2026-11-25');


--Part 2
--2.1
CREATE TABLE customers(
    customer_id INTEGER NOT NULL ,
    email TEXT NOT NULL ,
    phone TEXT,
    registration_date DATE NOT NULL
);

--2.2
CREATE TABLE inventory(
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL ,
    quantity INTEGER NOT NULL CHECK ( quantity >=0 ),
    unit_price NUMERIC NOT NULL CHECK ( unit_price >=0 ),
    last_updated TIMESTAMP NOT NULL
);

--2.3
INSERT INTO customers VALUES (1,'abc@gmail.com', +77777777777,'2026-05-20');
INSERT INTO customers VALUES (2, 'qwerty@mail.ru', NULL, '2026-03-15');
INSERT INTO inventory VALUES (1, 'Notebook', 3, 400000,'2026-10-10 13:00:00');


--Part3
--3.1
CREATE TABLE users(
    user_id INTEGER,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP,
    CONSTRAINT unique_username UNIQUE (username),
    CONSTRAINT unique_email UNIQUE (email)
);

--3.2
CREATE TABLE course_enrollments(
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_student_id_course_semester UNIQUE(student_id, course_code, semester)

);

--3.3
INSERT INTO users VALUES (1, 'Alex', 'abcd@email.com', '2026-10-12 15:33:53');


--Part 4
--4.1
CREATE TABLE departments(
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL ,
    location TEXT
);
INSERT INTO departments VALUES (1, 'it', 'kazakhstan');
INSERT INTO departments VALUES (2, 'marketing', 'kazakhstan');
INSERT INTO departments VALUES (3, 'finance', 'kazakhstan');

--4.2

CREATE TABLE student_courses(
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

--4.3
-- primary key cant consist null parameters
-- unique can have soe null parametrs

--primary key use when it unical information with combination some strings

-- primary key its fundomental important info, unique can be any information


--Part 5
--5.1
CREATE TABLE employees_dept(
    emp_id INTEGER PRIMARY KEY ,
    emp_name TEXT NOT NULL ,
    dept_id INTEGER REFERENCES departments,
    hire_date DATE
);
INSERT INTO employees_dept VALUES (1,'Mayke', '2', '2026-04-20');

--5.2

CREATE TABLE authors(
    author_id INTEGER PRIMARY KEY ,
    author_name TEXT NOT NULL ,
    country TEXT
);
CREATE TABLE publishers(
    publisher_id INTEGER PRIMARY KEY ,
    publisher_name TEXT NOT NULL ,
    city TEXT
);
CREATE TABLE books(
    book_id INTEGER PRIMARY KEY ,
    title TEXT NOt NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);
INSERT INTO authors VALUES (1, 'Mike', 'USA');
INSERT INTO publishers VALUES (2, 'Bob', 'Vashington');
INSERT INTO books VALUES (5,'Piece', 2,2,'1998');

--5.3

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES (1, 'Phone');
INSERT INTO products_fk VALUES (3, 'Book', 4 );


--Part6
--6.1

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO customers VALUES (1, 'Alibek', 'alibek@mail.com', '+77011112233', '2026-01-01');
INSERT INTO customers VALUES (2, 'Madina', 'madina@mail.com', '+77022223344', '2026-01-02');
INSERT INTO customers VALUES (3, 'Tima', 'timur@mail.com', '+77033334455', '2026-01-03');
INSERT INTO customers VALUES (4, 'Aya', 'aigerim@mail.com', '+77044445566', '2026-01-04');
INSERT INTO customers VALUES (5, 'Ruslan', 'ruslan@mail.com', '+77055556677', '2026-01-05');

INSERT INTO products VALUES (1, 'Laptop', 'Game powered', 450000.00, 10);
INSERT INTO products VALUES (2, 'Mouse', 'Bluetooth', 15000.00, 50);
INSERT INTO products VALUES (3, 'Keyboard', 'Mechanic', 35000.00, 25);
INSERT INTO products VALUES (4, 'Screen', '27 4K', 180000.00, 15);
INSERT INTO products VALUES (5, 'Headphones', 'Bluetooth', 25000.00, 30);

INSERT INTO orders VALUES (1, 1, '2026-03-01', 465000.00, 'delivered');
INSERT INTO orders VALUES (2, 2, '2026-03-02', 35000.00, 'processing');
INSERT INTO orders VALUES (3, 3, '2026-03-03', 180000.00, 'pending');
INSERT INTO orders VALUES (4, 4, '2026-03-04', 25000.00, 'shipped');
INSERT INTO orders VALUES (5, 5, '2026-03-05', 15000.00, 'cancelled');

INSERT INTO order_details VALUES (1, 1, 1, 1, 450000.00);
INSERT INTO order_details VALUES (2, 1, 2, 1, 15000.00);
INSERT INTO order_details VALUES (3, 2, 3, 1, 35000.00);
INSERT INTO order_details VALUES (4, 3, 4, 1, 180000.00);
INSERT INTO order_details VALUES (5, 4, 5, 1, 25000.00);


