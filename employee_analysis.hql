-- 1. Retrieve all employees who joined after 2015
SELECT *
FROM employees_partitioned
WHERE join_date > '2015-12-31';

-- 2. Average salary by department
SELECT department, AVG(salary) AS avg_salary
FROM employees_partitioned
GROUP BY department;

-- 3. Employees working on 'Alpha' project
SELECT *
FROM employees_partitioned
WHERE project = 'Alpha';

-- 4. count the number of employees in each role 
SELECT 
    job_role, 
    COUNT(*) AS emp_count
FROM employees_partitioned
GROUP BY job_role;

-- 5. Retrieve employees whose salary is above the average salary of their department --- This one was so hard for no reason for me to figure out 
SELECT e.*
FROM employees_partitioned e
JOIN (
    SELECT 
        department, 
        AVG(salary) AS avg_salary
    FROM employees_partitioned
    GROUP BY department
) deptavg
ON e.department = deptavg.department
WHERE e.salary > deptavg.avg_salary;


-- 6. Find the department with the highest number of employees
SELECT department, COUNT(*) AS emp_count
FROM employees_partitioned
GROUP BY department
ORDER BY emp_count DESC
LIMIT 1;


-- 7. Check for employees with null values in any column and exclude them from analysis
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

  --8. Join employees and departments to display employee details along with department location
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


-- 9.Rank employees within each department based on salary
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

-- 10. Find the top 3 highest-paid employees in each department
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
