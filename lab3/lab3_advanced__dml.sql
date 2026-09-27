-- part A

CREATE DATABASE "advanced_lab";

CREATE TABLE employees(
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    departament VARCHAR(100),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(50) DEFAULT 'Active',
);

CREATE TABLE departments(
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100),
    budget INTEGER,
    manager_id INTEGER,
);

CREATE TABLE projects(
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    budget INTEGER,
);


-- part B

INSERT INTO employees (emp_id, first_name, last_name,departament)
VALUES (1, 'Bob', 'Mike', 'IT');

INSERT INTO employees(first_name, last_name, departament, salary, status)
VALUES ('Jane', 'Smith', 'PR',DEFAULT, DEFAULT);

INSERT INTO departments(dept_name, budget, manager_id)
VALUES
    ('IT', 10000, 1),
    ('PR', 50000, 2),
    ('project' , 15000, 3);

INSERT INTO employees(first_name, last_name, departament, salary, hire_date)
VALUES ('Alice' , 'Li', 'IT', 50000 * 1,1, CURRENT_DATE);

CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE 1=0;

INSERT INTO temp_employees
SELECT * FROM employees
WHERE departament = 'IT';


--part C

UPDATE employees
SET salary = salary * 1.10;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

UPDATE employees
SET departament = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

UPDATE employees
SET dapartament = DEFAULT
WHERE status = 'Inactive';

UPDATE departments d
SET budget = (
    SELECT COALESCE(AVG(e.salary), 0) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
)
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.department = d.dept_name
);

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';


--part D

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;


--Part E

INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Bob', 'Marley', NULL, NULL);

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;


--part F

INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('Charlie', 'Brown', 'IT', 70000)
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, (salary - 5000) AS old_salary, salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


--part G

INSERT INTO employees (first_name, last_name, department, salary)
SELECT 'David', 'Miller', 'Finance', 65000
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE first_name = 'David' AND last_name = 'Miller'
);

UPDATE employees e
SET salary = CASE
    WHEN (SELECT d.budget FROM departments d WHERE d.dept_name = e.department) > 100000
        THEN salary * 1.10
    ELSE salary * 1.05
END
WHERE department IN (SELECT dept_name FROM departments);

INSERT INTO employees (first_name, last_name, department, salary)
VALUES
    ('Emp1', 'Test', 'IT', 40000),
    ('Emp2', 'Test', 'IT', 42000),
    ('Emp3', 'Test', 'Sales', 45000),
    ('Emp4', 'Test', 'HR', 38000),
    ('Emp5', 'Test', 'Finance', 50000);

UPDATE employees
SET salary = salary * 1.10
WHERE last_name = 'Test';


CREATE TABLE IF NOT EXISTS employee_archive (LIKE employees INCLUDING ALL);


WITH moved_rows AS (
    DELETE FROM employees
    WHERE status = 'Inactive'
    RETURNING *
)
INSERT INTO employee_archive
SELECT * FROM moved_rows;

UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND p.dept_id IN (
      SELECT d.dept_id
      FROM departments d
      JOIN employees e ON e.department = d.dept_name
      GROUP BY d.dept_id
      HAVING COUNT(e.emp_id) > 3
  );
