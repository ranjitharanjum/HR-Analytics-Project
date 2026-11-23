USE project_hr_analytics;
SHOW TABLES;
DESCRIBE HR;
SELECT COUNT(*) AS total_employees FROM HR;

### Data quality checking
# Task 1 – Check duplicate employee IDs
SELECT
    id,
    COUNT(*) AS duplicate_count
FROM HR
GROUP BY id
HAVING COUNT(*) > 1;

# Task 2 – Check missing values
SELECT
    COUNT(*) AS total_records,
    SUM(first_name IS NULL OR first_name = '') AS missing_first_name,
    SUM(last_name IS NULL OR last_name = '') AS missing_last_name,
    SUM(gender IS NULL OR gender = '') AS missing_gender,
    SUM(department IS NULL OR department = '') AS missing_department,
    SUM(birthdate IS NULL OR birthdate = '') AS missing_birthdate,
    SUM(hire_date IS NULL OR hire_date = '') AS missing_hire_date,
    SUM(termdate IS NULL OR termdate = '') AS missing_termdate
FROM HR;

# Task 3 – Check employee age
SELECT
    MIN(Age) AS minimum_age,
    MAX(Age) AS maximum_age,
    AVG(Age) AS average_age
FROM HR;

### Investigate date formats
#Task 1 – View sample records
SELECT
    id, birthdate, hire_date, termdate
FROM HR
LIMIT 15;

# Task 2 – Convert birthdate and hire_date
SELECT
    id,
    birthdate,
    STR_TO_DATE(birthdate, '%d-%m-%Y') AS converted_birthdate,
    hire_date,
    STR_TO_DATE(hire_date, '%d-%m-%Y') AS converted_hire_date
FROM HR
LIMIT 15;

# Task 3 – Convert termination dates
SELECT
    id,
    termdate,
    STR_TO_DATE(
        NULLIF(termdate, ''),
        '%Y-%m-%d %H:%i:%s UTC'
    ) AS converted_termdate
FROM HR
WHERE termdate IS NOT NULL
  AND termdate != ''
LIMIT 15;

# Check future termination dates
SELECT
    COUNT(*) AS future_termination_records
FROM HR
WHERE STR_TO_DATE(
    NULLIF(termdate, ''),
    '%Y-%m-%d %H:%i:%s UTC'
) > UTC_TIMESTAMP();

# Display future termination records
SELECT
    id,
    department,
    hire_date,
    termdate
FROM HR
WHERE STR_TO_DATE(
    NULLIF(termdate, ''),
    '%Y-%m-%d %H:%i:%s UTC'
) > UTC_TIMESTAMP()
LIMIT 10;

# Check the actual termination date range
SELECT
    MIN(
        STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC')
    ) AS earliest_termination,

    MAX(
        STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC')
    ) AS latest_termination
FROM HR
WHERE termdate IS NOT NULL
  AND termdate != '';
  
# Count historical terminations
SELECT
    COUNT(*) AS historical_terminations
FROM HR
WHERE STR_TO_DATE(
    NULLIF(termdate, ''),
    '%Y-%m-%d %H:%i:%s UTC'
) <= '2026-11-17 23:59:59';

# Calculate current active employees
SELECT
    COUNT(*) AS active_employees
FROM HR
WHERE termdate IS NULL
   OR termdate = '';
   
# Calculate current active employees
SELECT
    COUNT(*) AS active_employees
FROM HR
WHERE termdate IS NULL
   OR termdate = '';
   
# Calculate the historical termination percentage
SELECT
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM HR),
        2
    ) AS historical_termination_percentage
FROM HR
WHERE STR_TO_DATE(
    NULLIF(termdate, ''),
    '%Y-%m-%d %H:%i:%s UTC'
) <= '2026-11-17 23:59:59';

# Analyze employee gender distribution
SELECT
    gender,
    COUNT(*) AS employee_count
FROM HR
GROUP BY gender
ORDER BY employee_count DESC;

# Employee distribution by department
SELECT
    department,
    COUNT(*) AS employee_count
FROM HR
GROUP BY department
ORDER BY employee_count DESC;

# Employees by state
SELECT
    location_state,
    COUNT(*) AS employee_count
FROM HR
GROUP BY location_state
ORDER BY employee_count DESC;

# Employees by race
SELECT
    race,
    COUNT(*) AS employee_count
FROM HR
GROUP BY race
ORDER BY employee_count DESC;

# Analyze work location (HQ vs Remote)
SELECT
    location,
    COUNT(*) AS employee_count
FROM HR
GROUP BY location
ORDER BY employee_count DESC;

# Hiring trends by year
SELECT
    YEAR(
        STR_TO_DATE(hire_date, '%d-%m-%Y')
    ) AS hiring_year,
    COUNT(*) AS employees_hired
FROM HR
GROUP BY hiring_year
ORDER BY hiring_year;

# Calculate average employee age by department
SELECT
    department,
    ROUND(AVG(Age), 2) AS average_age
FROM HR
GROUP BY department
ORDER BY average_age DESC;

# Employees by job title
SELECT
    jobtitle,
    COUNT(*) AS employee_count
FROM HR
GROUP BY jobtitle
ORDER BY employee_count DESC
LIMIT 15;

# Calculate employee age distribution
SELECT
    CASE
        WHEN Age < 25 THEN 'Under 25'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55 and Above'
    END AS age_group,
    COUNT(*) AS employee_count
FROM HR
GROUP BY age_group
ORDER BY MIN(Age);

# Calculate employee tenure
SELECT
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                YEAR,
                STR_TO_DATE(hire_date, '%d-%m-%Y'),
                '2026-11-17'
            )
        ), 2
    ) AS average_tenure_years
FROM HR
WHERE hire_date IS NOT NULL
  AND hire_date != '';
  
# Average tenure by department
SELECT
    department,
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                YEAR,
                STR_TO_DATE(hire_date, '%d-%m-%Y'),
                '2026-11-17'
            )
        ), 2
    ) AS average_tenure_years
FROM HR
GROUP BY department
ORDER BY average_tenure_years DESC;

# Hiring distribution by department
SELECT
    department,
    COUNT(*) AS employees_hired
FROM HR
GROUP BY department
ORDER BY employees_hired DESC;

# Historical terminations by department
SELECT
    department,
    COUNT(*) AS terminated_employees
FROM HR
WHERE STR_TO_DATE(
    NULLIF(termdate, ''),
    '%Y-%m-%d %H:%i:%s UTC'
) <= '2026-11-17 23:59:59'
GROUP BY department
ORDER BY terminated_employees DESC;

# Calculate department-wise historical termination percentages
SELECT
    department,
    COUNT(*) AS total_employees,
    SUM(
        CASE
            WHEN STR_TO_DATE(
                NULLIF(termdate, ''),
                '%Y-%m-%d %H:%i:%s UTC'
            ) <= '2026-11-17 23:59:59'
            THEN 1
            ELSE 0
        END
    ) AS terminated_employees,
    ROUND(
        SUM(
            CASE
                WHEN STR_TO_DATE(
                    NULLIF(termdate, ''),
                    '%Y-%m-%d %H:%i:%s UTC'
                ) <= '2026-11-17 23:59:59'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS termination_percentage
FROM HR
GROUP BY department
ORDER BY termination_percentage DESC;

# Historical terminations by year
SELECT
    YEAR(
        STR_TO_DATE(
            NULLIF(termdate, ''),
            '%Y-%m-%d %H:%i:%s UTC'
        )
    ) AS termination_year,
    COUNT(*) AS terminated_employees
FROM HR
WHERE STR_TO_DATE(
    NULLIF(termdate, ''),
    '%Y-%m-%d %H:%i:%s UTC'
) <= '2026-11-17 23:59:59'
GROUP BY termination_year
ORDER BY termination_year;

# Department-wise hiring trends over time
SELECT 
    YEAR(STR_TO_DATE(hire_date, '%d-%m-%Y')) AS hiring_year,
    COUNT(*) AS employees_hired
FROM
    HR
WHERE
    department = 'Engineering'
GROUP BY hiring_year
ORDER BY hiring_year;

# Hiring trends in Accounting
SELECT
    YEAR(
        STR_TO_DATE(hire_date, '%d-%m-%Y')
    ) AS hiring_year,
    COUNT(*) AS employees_hired
FROM HR
WHERE department = 'Accounting'
GROUP BY hiring_year
ORDER BY hiring_year;

# Analyze employee tenure groups
SELECT
    CASE
        WHEN TIMESTAMPDIFF(
            YEAR,
            STR_TO_DATE(hire_date, '%d-%m-%Y'),
            '2026-11-17'
        ) < 5 THEN 'Less than 5 years'

        WHEN TIMESTAMPDIFF(
            YEAR,
            STR_TO_DATE(hire_date, '%d-%m-%Y'),
            '2026-11-17'
        ) BETWEEN 5 AND 10 THEN '5-10 years'

        WHEN TIMESTAMPDIFF(
            YEAR,
            STR_TO_DATE(hire_date, '%d-%m-%Y'),
            '2026-11-17'
        ) BETWEEN 11 AND 15 THEN '11-15 years'

        ELSE 'More than 15 years'
    END AS tenure_group,

    COUNT(*) AS employee_count

FROM HR
GROUP BY tenure_group
ORDER BY MIN(
    TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(hire_date, '%d-%m-%Y'),
        '2026-11-17'
    )
);

# Check age data accuracy
SELECT
    COUNT(*) AS total_records,
    SUM(
        Age <> TIMESTAMPDIFF(
            YEAR,
            STR_TO_DATE(birthdate, '%d-%m-%Y'),
            '2026-11-17'
        )
    ) AS age_mismatches
FROM HR
WHERE birthdate IS NOT NULL
  AND birthdate <> '';
  
# Compare existing and calculated ages
SELECT
    id,
    birthdate,
    Age AS existing_age,
    TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(birthdate, '%d-%m-%Y'),
        '2026-11-17'
    ) AS calculated_age
FROM HR
LIMIT 10;

# Check the age difference across all records
SELECT
    Age - TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(birthdate, '%d-%m-%Y'),
        '2026-11-17'
    ) AS age_difference,
    COUNT(*) AS employee_count
FROM HR
GROUP BY age_difference
ORDER BY age_difference;

# Verify the calculated age range
SELECT
    MIN(TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%d-%m-%Y'), '2026-11-17')) AS min_age,
    MAX(TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%d-%m-%Y'), '2026-11-17')) AS max_age,
    ROUND(AVG(TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%d-%m-%Y'), '2026-11-17')), 2) AS average_age
FROM HR
WHERE birthdate IS NOT NULL
  AND birthdate <> '';
  
# Calculate the age-group distribution using corrected ages
SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%d-%m-%Y'), '2026-11-17') < 25
            THEN 'Under 25'
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%d-%m-%Y'), '2026-11-17') BETWEEN 25 AND 34
            THEN '25-34'
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%d-%m-%Y'), '2026-11-17') BETWEEN 35 AND 44
            THEN '35-44'
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%d-%m-%Y'), '2026-11-17') BETWEEN 45 AND 54
            THEN '45-54'
        ELSE '55 and Above'
    END AS age_group,
    COUNT(*) AS employee_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM HR), 2) AS percentage
FROM HR
WHERE birthdate IS NOT NULL
  AND birthdate <> ''
GROUP BY age_group
ORDER BY MIN(TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%d-%m-%Y'), '2026-11-17'));

# Check the hiring trend by department
SELECT
    department,
    COUNT(*) AS total_hires
FROM HR
GROUP BY department
ORDER BY total_hires DESC;

# Analyze hiring by department over time
 SELECT
    YEAR(STR_TO_DATE(hire_date, '%d-%m-%Y')) AS hiring_year,
    department,
    COUNT(*) AS employees_hired
FROM HR
GROUP BY
    hiring_year,
    department
ORDER BY
    hiring_year,
    department;
    
# identify - Blank Termination Date, Historical Termination, Future-Dated Termination
SELECT
    CASE
        WHEN termdate IS NULL OR TRIM(termdate) = ''
            THEN 'Blank Termination Date'
        WHEN STR_TO_DATE(
            TRIM(REPLACE(termdate, ' UTC', '')),
            '%Y-%m-%d %H:%i:%s'
        ) <= '2026-11-17 23:59:59'
            THEN 'Historical Termination'
        ELSE 'Future-Dated Termination'
    END AS termination_status,
    COUNT(*) AS employee_count
FROM HR
GROUP BY termination_status
ORDER BY termination_status;

# Calculate historical terminations by year
SELECT
    YEAR(
        STR_TO_DATE(
            TRIM(REPLACE(termdate, ' UTC', '')),
            '%Y-%m-%d %H:%i:%s'
        )
    ) AS termination_year,
    COUNT(*) AS employees_terminated
FROM HR
WHERE termdate IS NOT NULL
  AND TRIM(termdate) <> ''
  AND STR_TO_DATE(
        TRIM(REPLACE(termdate, ' UTC', '')),
        '%Y-%m-%d %H:%i:%s'
      ) <= '2026-11-17 23:59:59'
GROUP BY termination_year
ORDER BY termination_year;

# Calculate average completed service before termination
SELECT
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                DAY,
                STR_TO_DATE(hire_date, '%d-%m-%Y'),
                STR_TO_DATE(
                    TRIM(REPLACE(termdate, ' UTC', '')),
                    '%Y-%m-%d %H:%i:%s'
                )
            ) / 365.25
        ), 2
    ) AS average_years_before_termination
FROM HR
WHERE termdate IS NOT NULL
  AND TRIM(termdate) <> ''
  AND STR_TO_DATE(
        TRIM(REPLACE(termdate, ' UTC', '')),
        '%Y-%m-%d %H:%i:%s'
      ) <= '2026-11-17 23:59:59';
      
# Compare average service duration by department
SELECT
    department,
    COUNT(*) AS terminated_employees,
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                DAY,
                STR_TO_DATE(hire_date, '%d-%m-%Y'),
                STR_TO_DATE(
                    TRIM(REPLACE(termdate, ' UTC', '')),
                    '%Y-%m-%d %H:%i:%s'
                )
            ) / 365.25
        ), 2
    ) AS avg_service_years
FROM HR
WHERE termdate IS NOT NULL
  AND TRIM(termdate) <> ''
  AND STR_TO_DATE(
        TRIM(REPLACE(termdate, ' UTC', '')),
        '%Y-%m-%d %H:%i:%s'
      ) <= '2026-11-17 23:59:59'
GROUP BY department
ORDER BY avg_service_years DESC;

# Analyze historical termination percentages by department
SELECT
    department,
    COUNT(*) AS total_employee_records,
    SUM(
        CASE
            WHEN termdate IS NOT NULL
             AND TRIM(termdate) <> ''
             AND STR_TO_DATE(
                    TRIM(REPLACE(termdate, ' UTC', '')),
                    '%Y-%m-%d %H:%i:%s'
                 ) <= '2026-11-17 23:59:59'
            THEN 1
            ELSE 0
        END
    ) AS historical_terminations,
    ROUND(
        SUM(
            CASE
                WHEN termdate IS NOT NULL
                 AND TRIM(termdate) <> ''
                 AND STR_TO_DATE(
                        TRIM(REPLACE(termdate, ' UTC', '')),
                        '%Y-%m-%d %H:%i:%s'
                     ) <= '2026-11-17 23:59:59'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS historical_termination_percentage
FROM HR
GROUP BY department
ORDER BY historical_termination_percentage DESC;

# termination trends by department and year
SELECT
    YEAR(
        STR_TO_DATE(
            TRIM(REPLACE(termdate, ' UTC', '')),
            '%Y-%m-%d %H:%i:%s'
        )
    ) AS termination_year,
    department,
    COUNT(*) AS employees_terminated
FROM HR
WHERE termdate IS NOT NULL
  AND TRIM(termdate) <> ''
  AND STR_TO_DATE(
        TRIM(REPLACE(termdate, ' UTC', '')),
        '%Y-%m-%d %H:%i:%s'
      ) <= '2026-11-17 23:59:59'
GROUP BY
    termination_year,
    department
ORDER BY
    termination_year,
    department;
    
# Calculate age directly from birthdate in MySQL
SELECT
    ROUND(AVG(
        TIMESTAMPDIFF(
            YEAR,
            STR_TO_DATE(birthdate, '%d-%m-%Y'),
            '2026-11-17'
        )
    ), 2) AS Average_Age_From_Birthdate
FROM HR
WHERE birthdate IS NOT NULL
  AND birthdate <> '';
  
SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%d-%m-%Y'), '2026-11-17') < 25
            THEN 'Under 25'
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%d-%m-%Y'), '2026-11-17') <= 34
            THEN '25-34'
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%d-%m-%Y'), '2026-11-17') <= 44
            THEN '35-44'
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%d-%m-%Y'), '2026-11-17') <= 54
            THEN '45-54'
        ELSE '55 and Above'
    END AS Age_Group,
    COUNT(*) AS Employee_Count
FROM HR
GROUP BY Age_Group
ORDER BY MIN(
    TIMESTAMPDIFF(YEAR, STR_TO_DATE(birthdate, '%d-%m-%Y'), '2026-11-17')
);

# Statistical analysis of employee age

SELECT VERSION();

# Create a temporary table containing the calculated employee ages.
CREATE TEMPORARY TABLE Employee_Ages AS
SELECT
    department,
    TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(birthdate, '%d-%m-%Y'),
        '2026-11-17'
    ) AS employee_age
FROM HR;

SELECT
    @row_num := @row_num + 1 AS row_num,
    employee_age
FROM (
    SELECT
        TIMESTAMPDIFF(
            YEAR,
            STR_TO_DATE(birthdate, '%d-%m-%Y'),
            '2026-11-17'
        ) AS employee_age
    FROM HR
    ORDER BY employee_age
) AS AgeData
CROSS JOIN (SELECT @row_num := 0) AS vars
LIMIT 10;

SELECT
    r.department,
    MAX(c.employee_count) AS Employee_Count,
    ROUND(
        AVG(
            CASE
                WHEN r.age_rank IN (
                    FLOOR((c.employee_count + 1) / 2),
                    FLOOR((c.employee_count + 2) / 2)
                )
                THEN r.employee_age
            END
        ), 2
    ) AS Median_Age
FROM (
    SELECT
        s.department,
        s.employee_age,
        @row_num := IF(
            @prev_department = s.department,
            @row_num + 1,
            1
        ) AS age_rank,
        @prev_department := s.department AS dept_tracker
    FROM (
        SELECT
            department,
            TIMESTAMPDIFF(
                YEAR,
                STR_TO_DATE(birthdate, '%d-%m-%Y'),
                '2026-11-17'
            ) AS employee_age
        FROM HR
        ORDER BY department, employee_age
    ) AS s
    CROSS JOIN (
        SELECT
            @row_num := 0,
            @prev_department := ''
    ) AS vars
) AS r
JOIN (
    SELECT
        department,
        COUNT(*) AS employee_count
    FROM HR
    GROUP BY department
) AS c
    ON r.department = c.department
GROUP BY r.department
ORDER BY Median_Age DESC;

# Calculate standard deviation of employee age by department
SELECT
    department,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(employee_age), 2) AS Average_Age,
    ROUND(STDDEV_POP(employee_age), 2) AS Age_Std_Deviation
FROM (
    SELECT
        department,
        TIMESTAMPDIFF(
            YEAR,
            STR_TO_DATE(birthdate, '%d-%m-%Y'),
            '2026-11-17'
        ) AS employee_age
    FROM HR
    WHERE birthdate IS NOT NULL
      AND birthdate <> ''
) AS AgeData
GROUP BY department
ORDER BY Age_Std_Deviation DESC;

# Calculate Q1, Q3 and IQR by department
SELECT
    r.department,
    MAX(c.total_count) AS Employee_Count,

    MAX(
        CASE
            WHEN r.age_rank = CEIL(c.total_count * 0.25)
            THEN r.employee_age
        END
    ) AS Q1_Age,

    MAX(
        CASE
            WHEN r.age_rank = CEIL(c.total_count * 0.75)
            THEN r.employee_age
        END
    ) AS Q3_Age,

    MAX(
        CASE
            WHEN r.age_rank = CEIL(c.total_count * 0.75)
            THEN r.employee_age
        END
    )
    -
    MAX(
        CASE
            WHEN r.age_rank = CEIL(c.total_count * 0.25)
            THEN r.employee_age
        END
    ) AS IQR

FROM (
    SELECT
        s.department,
        s.employee_age,
        @rank := IF(
            @prev_department = s.department,
            @rank + 1,
            1
        ) AS age_rank,
        @prev_department := s.department AS dept_tracker
    FROM (
        SELECT
            department,
            TIMESTAMPDIFF(
                YEAR,
                STR_TO_DATE(birthdate, '%d-%m-%Y'),
                '2026-11-17'
            ) AS employee_age
        FROM HR
        WHERE birthdate IS NOT NULL
          AND birthdate <> ''
        ORDER BY department, employee_age
    ) AS s
    CROSS JOIN (
        SELECT
            @rank := 0,
            @prev_department := ''
    ) AS vars
) AS r

JOIN (
    SELECT
        department,
        COUNT(*) AS total_count
    FROM HR
    WHERE birthdate IS NOT NULL
      AND birthdate <> ''
    GROUP BY department
) AS c
    ON r.department = c.department

GROUP BY r.department
ORDER BY IQR DESC;

# Overall age statistics
SELECT
    COUNT(*) AS Employee_Count,
    MIN(employee_age) AS Minimum_Age,
    MAX(employee_age) AS Maximum_Age,
    ROUND(AVG(employee_age), 2) AS Mean_Age,
    ROUND(STDDEV_POP(employee_age), 2) AS Std_Deviation,

    MAX(CASE
        WHEN age_rank = CEIL(total_count * 0.25)
        THEN employee_age
    END) AS Q1,

    MAX(CASE
        WHEN age_rank = FLOOR((total_count + 1) / 2)
        THEN employee_age
    END) AS Median_Lower,

    MAX(CASE
        WHEN age_rank = FLOOR((total_count + 2) / 2)
        THEN employee_age
    END) AS Median_Upper,

    MAX(CASE
        WHEN age_rank = CEIL(total_count * 0.75)
        THEN employee_age
    END) AS Q3

FROM (
    SELECT
        employee_age,
        @row_num := @row_num + 1 AS age_rank,
        total_count
    FROM (
        SELECT
            TIMESTAMPDIFF(
                YEAR,
                STR_TO_DATE(birthdate, '%d-%m-%Y'),
                '2026-11-17'
            ) AS employee_age
        FROM HR
        WHERE birthdate IS NOT NULL
          AND birthdate <> ''
        ORDER BY employee_age
    ) AS sorted_ages
    CROSS JOIN (
        SELECT
            @row_num := 0,
            (SELECT COUNT(*) FROM HR
             WHERE birthdate IS NOT NULL
               AND birthdate <> '') AS total_count
    ) AS vars
) AS ranked_ages;

# Overall Employee Tenure Statistics
SELECT
    COUNT(*) AS Employee_Count,
    ROUND(MIN(tenure_years), 2) AS Minimum_Tenure_Years,
    ROUND(MAX(tenure_years), 2) AS Maximum_Tenure_Years,
    ROUND(AVG(tenure_years), 2) AS Mean_Tenure_Years,
    ROUND(STDDEV_POP(tenure_years), 2) AS Tenure_Std_Deviation,
    ROUND(
        AVG(
            CASE
                WHEN age_rank IN (
                    FLOOR((total_count + 1) / 2),
                    FLOOR((total_count + 2) / 2)
                )
                THEN tenure_years
            END
        ), 2
    ) AS Median_Tenure_Years
FROM (
    SELECT
        tenure_years,
        @row_num := @row_num + 1 AS age_rank,
        total_count
    FROM (
        SELECT
            TIMESTAMPDIFF(
                DAY,
                STR_TO_DATE(hire_date, '%d-%m-%Y'),
                '2026-11-17'
            ) / 365.25 AS tenure_years
        FROM HR
        WHERE hire_date IS NOT NULL
          AND hire_date <> ''
        ORDER BY tenure_years
    ) AS sorted_tenure
    CROSS JOIN (
        SELECT
            @row_num := 0,
            (SELECT COUNT(*)
             FROM HR
             WHERE hire_date IS NOT NULL
               AND hire_date <> '') AS total_count
    ) AS vars
) AS ranked_tenure;

# tenure statistics by department
SELECT
    department,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(tenure_years), 2) AS Mean_Tenure_Years,
    ROUND(STDDEV_POP(tenure_years), 2) AS Tenure_Std_Deviation
FROM (
    SELECT
        department,
        TIMESTAMPDIFF(
            DAY,
            STR_TO_DATE(hire_date, '%d-%m-%Y'),
            '2026-11-17'
        ) / 365.25 AS tenure_years
    FROM HR
    WHERE hire_date IS NOT NULL
      AND hire_date <> ''
) AS TenureData
GROUP BY department
ORDER BY Mean_Tenure_Years DESC;

# Median tenure by department
SELECT
    r.department,
    MAX(c.employee_count) AS Employee_Count,
    ROUND(
        AVG(
            CASE
                WHEN r.tenure_rank IN (
                    FLOOR((c.employee_count + 1) / 2),
                    FLOOR((c.employee_count + 2) / 2)
                )
                THEN r.tenure_years
            END
        ), 2
    ) AS Median_Tenure_Years
FROM (
    SELECT
        s.department,
        s.tenure_years,
        @row_num := IF(
            @prev_department = s.department,
            @row_num + 1,
            1
        ) AS tenure_rank,
        @prev_department := s.department AS dept_tracker
    FROM (
        SELECT
            department,
            TIMESTAMPDIFF(
                DAY,
                STR_TO_DATE(hire_date, '%d-%m-%Y'),
                '2026-11-17'
            ) / 365.25 AS tenure_years
        FROM HR
        WHERE hire_date IS NOT NULL
          AND hire_date <> ''
        ORDER BY department, tenure_years
    ) AS s
    CROSS JOIN (
        SELECT
            @row_num := 0,
            @prev_department := ''
    ) AS vars
) AS r
JOIN (
    SELECT
        department,
        COUNT(*) AS employee_count
    FROM HR
    WHERE hire_date IS NOT NULL
      AND hire_date <> ''
    GROUP BY department
) AS c
    ON r.department = c.department
GROUP BY r.department
ORDER BY Median_Tenure_Years DESC;

# mean vs. median tenure comparison by department
SELECT
    m.department,
    m.Employee_Count,
    m.Mean_Tenure_Years,
    d.Median_Tenure_Years,
    ROUND(
        m.Mean_Tenure_Years - d.Median_Tenure_Years,
        2
    ) AS Mean_Median_Difference
FROM (
    SELECT
        department,
        COUNT(*) AS Employee_Count,
        ROUND(
            AVG(
                TIMESTAMPDIFF(
                    DAY,
                    STR_TO_DATE(hire_date, '%d-%m-%Y'),
                    '2026-11-17'
                ) / 365.25
            ), 2
        ) AS Mean_Tenure_Years
    FROM HR
    WHERE hire_date IS NOT NULL
      AND hire_date <> ''
    GROUP BY department
) AS m
JOIN (
    SELECT
        r.department,
        ROUND(
            AVG(
                CASE
                    WHEN r.tenure_rank IN (
                        FLOOR((c.employee_count + 1) / 2),
                        FLOOR((c.employee_count + 2) / 2)
                    )
                    THEN r.tenure_years
                END
            ), 2
        ) AS Median_Tenure_Years
    FROM (
        SELECT
            s.department,
            s.tenure_years,
            @rank := IF(
                @prev_department = s.department,
                @rank + 1,
                1
            ) AS tenure_rank,
            @prev_department := s.department AS dept_tracker
        FROM (
            SELECT
                department,
                TIMESTAMPDIFF(
                    DAY,
                    STR_TO_DATE(hire_date, '%d-%m-%Y'),
                    '2026-11-17'
                ) / 365.25 AS tenure_years
            FROM HR
            WHERE hire_date IS NOT NULL
              AND hire_date <> ''
            ORDER BY department, tenure_years
        ) AS s
        CROSS JOIN (
            SELECT
                @rank := 0,
                @prev_department := ''
        ) AS vars
    ) AS r
    JOIN (
        SELECT
            department,
            COUNT(*) AS employee_count
        FROM HR
        WHERE hire_date IS NOT NULL
          AND hire_date <> ''
        GROUP BY department
    ) AS c
        ON r.department = c.department
    GROUP BY r.department
) AS d
    ON m.department = d.department
ORDER BY Mean_Median_Difference DESC;

# Validation 1 – Verify termination status
SELECT
    CASE
        WHEN termdate IS NULL OR TRIM(termdate) = ''
            THEN 'Blank Termination Date'

        WHEN STR_TO_DATE(
            TRIM(REPLACE(termdate, ' UTC', '')),
            '%Y-%m-%d %H:%i:%s'
        ) <= '2026-11-17 23:59:59'
            THEN 'Historical Termination'

        ELSE 'Future-Dated Termination'
    END AS Termination_Status,

    COUNT(*) AS Employee_Count,

    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM HR),
        2
    ) AS Percentage

FROM HR
GROUP BY Termination_Status
ORDER BY Employee_Count DESC;

# Validation 2 – Check invalid date records
SELECT
    COUNT(*) AS Total_Records,

    SUM(
        birthdate IS NULL
        OR birthdate = ''
        OR STR_TO_DATE(birthdate, '%d-%m-%Y') IS NULL
    ) AS Invalid_Birthdates,

    SUM(
        hire_date IS NULL
        OR hire_date = ''
        OR STR_TO_DATE(hire_date, '%d-%m-%Y') IS NULL
    ) AS Invalid_Hire_Dates

FROM HR;

# Validation 3 – Verify employee ID uniqueness
SELECT
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT id) AS Unique_Employee_IDs,
    COUNT(*) - COUNT(DISTINCT id) AS Duplicate_ID_Count
FROM HR;

# Validation 4 – Verify corrected employee age statistics
SELECT
    COUNT(*) AS Employee_Count,
    MIN(
        TIMESTAMPDIFF(
            YEAR,
            STR_TO_DATE(birthdate, '%d-%m-%Y'),
            '2026-11-17'
        )
    ) AS Minimum_Age,
    MAX(
        TIMESTAMPDIFF(
            YEAR,
            STR_TO_DATE(birthdate, '%d-%m-%Y'),
            '2026-11-17'
        )
    ) AS Maximum_Age,
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                YEAR,
                STR_TO_DATE(birthdate, '%d-%m-%Y'),
                '2026-11-17'
            )
        ), 2
    ) AS Average_Age
FROM HR;

# Validation 5 – Verify department employee counts
SELECT
    department,
    COUNT(*) AS Employee_Count
FROM HR
GROUP BY department
ORDER BY Employee_Count DESC;

# Validation 6 – Verify gender distribution
SELECT
    gender,
    COUNT(*) AS Employee_Count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM HR),
        2
    ) AS Percentage
FROM HR
GROUP BY gender
ORDER BY Employee_Count DESC;

# Validation 7 – Verify work location distribution
SELECT
    location,
    COUNT(*) AS Employee_Count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM HR),
        2
    ) AS Percentage
FROM HR
GROUP BY location
ORDER BY Employee_Count DESC;

# Validation 8 – Verify hiring trends
SELECT
    YEAR(
        STR_TO_DATE(hire_date, '%d-%m-%Y')
    ) AS Hiring_Year,
    COUNT(*) AS Employees_Hired
FROM HR
WHERE hire_date IS NOT NULL
  AND hire_date <> ''
GROUP BY Hiring_Year
ORDER BY Hiring_Year;

# Validation 9 – Verify historical terminations by year
SELECT
    YEAR(
        STR_TO_DATE(
            TRIM(REPLACE(termdate, ' UTC', '')),
            '%Y-%m-%d %H:%i:%s'
        )
    ) AS Termination_Year,
    COUNT(*) AS Employees_Terminated
FROM HR
WHERE termdate IS NOT NULL
  AND TRIM(termdate) <> ''
  AND STR_TO_DATE(
        TRIM(REPLACE(termdate, ' UTC', '')),
        '%Y-%m-%d %H:%i:%s'
      ) <= '2026-11-17 23:59:59'
GROUP BY Termination_Year
ORDER BY Termination_Year;

# Validation 10 – Verify total historical terminations
SELECT
    COUNT(*) AS Historical_Terminations,
    COUNT(DISTINCT id) AS Unique_Terminated_Employees
FROM HR
WHERE termdate IS NOT NULL
  AND TRIM(termdate) <> ''
  AND STR_TO_DATE(
        TRIM(REPLACE(termdate, ' UTC', '')),
        '%Y-%m-%d %H:%i:%s'
      ) <= '2026-11-17 23:59:59';
      
# Reconcile total employee records
SELECT
    COUNT(*) AS Total_Employees,

    SUM(
        CASE
            WHEN termdate IS NULL OR TRIM(termdate) = ''
            THEN 1 ELSE 0
        END
    ) AS Blank_Termination,

    SUM(
        CASE
            WHEN termdate IS NOT NULL
             AND TRIM(termdate) <> ''
             AND STR_TO_DATE(
                 TRIM(REPLACE(termdate, ' UTC', '')),
                 '%Y-%m-%d %H:%i:%s'
             ) <= '2026-11-17 23:59:59'
            THEN 1 ELSE 0
        END
    ) AS Historical_Termination,

    SUM(
        CASE
            WHEN termdate IS NOT NULL
             AND TRIM(termdate) <> ''
             AND STR_TO_DATE(
                 TRIM(REPLACE(termdate, ' UTC', '')),
                 '%Y-%m-%d %H:%i:%s'
             ) > '2026-11-17 23:59:59'
            THEN 1 ELSE 0
        END
    ) AS Future_Termination

FROM HR;
