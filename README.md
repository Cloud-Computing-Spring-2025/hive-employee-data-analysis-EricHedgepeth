# Hive Employee & Department Data Analysis

# overview

This project analyzes employee and department data using Apache Hive. Two CSV files are given:
- employees.csv
- departments.csv
The analysis involves

 creating a temporary staging table, dynamically partitioning data by department, and running several queries that address different business questions.


## Steps 

# Start Docker 
```bash
Docker compose up -d 
```

# Copy CSV into hive container 
```bash
cd input_dataset
docker cp employees.csv hive-server:/tmp/
docker cp departments.csv hive-server:/tmp/
```

# Open container shell 
```bash
docker exec -it hive-server /bin/bash
```

# launch Hive 
```bash
hive
```

# Create a Temporary Table
```bash
CREATE TABLE temp_employees (
    emp_id STRING,
    name STRING,
    age INT,
    job_role STRING,
    salary DOUBLE,
    project STRING,
    join_date STRING,
    department STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;
```

# Load Data 
```bash
LOAD DATA LOCAL INPATH '/tmp/employees.csv'
OVERWRITE INTO TABLE temp_employees;
```


# Create the Partitioned Table
```bash
CREATE TABLE employees_partitioned (
    emp_id STRING,
    name STRING,
    age INT,
    job_role STRING,
    salary DOUBLE,
    project STRING,
    join_date STRING
)
PARTITIONED BY (department STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;
```

# Insert Data
```bash
INSERT OVERWRITE TABLE employees_partitioned
PARTITION (department)
SELECT emp_id, name, age, job_role, salary, project, join_date, department
FROM temp_employees;
```

# Create the departments table
```bash
CREATE TABLE departments (
    dept_id STRING,
    department_name STRING,
    location STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;
```

# Load Data
```bash
LOAD DATA LOCAL INPATH '/tmp/departments.csv'
OVERWRITE INTO TABLE departments;
```


## Queries 

# Retrieve All Employees Who Joined After 2015
```bash
SELECT *
FROM employees_partitioned
WHERE join_date > '2015-12-31';
```
# Find the Average Salary of Employees in Each Department
```bash
SELECT department, AVG(salary) AS avg_salary
FROM employees_partitioned
GROUP BY department;
```

# Identify Employees Working on the 'Alpha' Project
```bash
SELECT *
FROM employees_partitioned
WHERE project = 'Alpha';
```

# Count the Number of Employees in Each Job Role
```bash
SELECT job_role, COUNT(*) AS emp_count
FROM employees_partitioned
GROUP BY job_role;
```

# Retrieve Employees Whose Salary Is Above the Average for Their Department
```bash
SELECT e.*
FROM employees_partitioned e
JOIN (
    SELECT department, AVG(salary) AS avg_salary
    FROM employees_partitioned
    GROUP BY department
) deptavg
ON e.department = deptavg.department
WHERE e.salary > deptavg.avg_salary;
```

# Find the Department with the Highest Number of Employees
```bash
SELECT department, COUNT(*) AS emp_count
FROM employees_partitioned
GROUP BY department
ORDER BY emp_count DESC
LIMIT 1;
```

# Exclude Employees with NULL Values in Any Column
```bash
SELECT *
FROM employees_partitioned
WHERE emp_id IS NOT NULL
  AND name IS NOT NULL
  AND age IS NOT NULL
  AND job_role IS NOT NULL
  AND salary IS NOT NULL
  AND project IS NOT NULL
  AND join_date IS NOT NULL
  AND department IS NOT NULL;
```
# Join Employees and Departments to Show Department Location
```bash
SELECT 
    e.emp_id,
    e.name,
    e.age,
    e.job_role,
    e.salary,
    e.project,
    e.join_date,
    e.department,
    d.location
FROM employees_partitioned e
JOIN departments d
ON e.department = d.department_name;
```

# Rank Employees Within Each Department Based on Salary
```bash
SELECT
    emp_id,
    name,
    age,
    job_role,
    salary,
    project,
    join_date,
    department,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank
FROM employees_partitioned;
```


# Find the Top 3 Highest-Paid Employees in Each Department
```bash
SELECT *
FROM (
    SELECT
        emp_id,
        name,
        age,
        job_role,
        salary,
        project,
        join_date,
        department,
        RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank
    FROM employees_partitioned
) ranked
WHERE ranked.salary_rank <= 3;
```

## Create file and put all Queries into it

# Load Data
```bash
docker cp employee_analysis.hql hive-server:/tmp/
```

# Run the Script
```bash
docker exec -it hive-server /bin/bash
hive -f /tmp/employee_analysis.hql > /tmp/query_output.txt

```

# Get the Output
```bash
exit
docker cp hive-server:/tmp/query_output.txt .
```



## Challenges Faced 

-   I had trouble getting the tables correct and acidentally joined them whem I should not have 
    - I just had to drop the create table and go back several steps and start over. 
- I keep having issues with some commands not working in terminal but working in Hue     
  - I just had to use HUE because I could not figure it out. 
- SQL coding  
  - It has been several years since I touched SQL and it took a good bit of searching to figure out how to use the tables and database. 

