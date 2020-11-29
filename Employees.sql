--Tables
CREATE TABLE Departments (
dept_no VARCHAR(100) PRIMARY KEY,
dept_name VARCHAR(100)
);

CREATE TABLE Employees (
emp_no VARCHAR(100) PRIMARY KEY,
emp_title VARCHAR(100),
birth_date VARCHAR(100),
first_name VARCHAR(100),
last_name VARCHAR(100),
sex VARCHAR(100),
hire_date VARCHAR(100)
);

CREATE TABLE Dept_emp (
emp_no VARCHAR(100),
FOREIGN KEY (emp_no) REFERENCES Employees(emp_no),
dept_no VARCHAR(100),
FOREIGN KEY (dept_no) REFERENCES Departments(dept_no)
);

CREATE TABLE Dept_manager (
dept_no VARCHAR(100),
FOREIGN KEY (dept_no) REFERENCES Departments(dept_no),
emp_no VARCHAR(100),
FOREIGN KEY (emp_no) REFERENCES Employees(emp_no)
);

CREATE TABLE Salaries (
emp_no VARCHAR(100),
FOREIGN KEY (emp_no) REFERENCES Employees(emp_no),
salary INT
);

CREATE TABLE Titles (
title_id VARCHAR(100) PRIMARY KEY,
title VARCHAR(100)
);

--Queries
SELECT employees.emp_no, last_name, first_name, sex, salaries.salary
FROM Employees
JOIN Salaries
ON employees.emp_no = salaries.emp_no

SELECT first_name, last_name, hire_date
FROM Employees
WHERE hire_date LIKE '%1986'

SELECT dept_manager.dept_no, departments.dept_name, dept_manager.emp_no, employees.first_name, employees.last_name
FROM Dept_manager
JOIN Departments
ON dept_manager.dept_no = departments.dept_no
JOIN Employees
ON dept_manager.emp_no = employees.emp_no


SELECT employees.emp_no, employees.first_name, employees.last_name, departments.dept_name
FROM Departments
JOIN Dept_emp
ON dept_emp.dept_no = departments.dept_no
JOIN Employees
ON dept_emp.emp_no = employees.emp_no

SELECT first_name, last_name, sex
FROM Employees
WHERE first_name = 'Hercules' AND last_name LIKE 'B%'

SELECT employees.emp_no, employees.first_name, employees.last_name, departments.dept_name
FROM Departments
JOIN Dept_emp
ON dept_emp.dept_no = departments.dept_no
JOIN Employees
ON dept_emp.emp_no = employees.emp_no
WHERE departments.dept_name = 'Sales'

SELECT employees.emp_no, employees.first_name, employees.last_name, departments.dept_name
FROM Departments
JOIN Dept_emp
ON dept_emp.dept_no = departments.dept_no
JOIN Employees
ON dept_emp.emp_no = employees.emp_no
WHERE dept_name = 'Sales' OR dept_name = 'Developement'

Select last_name, count(last_name)
from Employees
GROUP By last_name
ORDER BY last_name DESC;