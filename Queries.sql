USE Assignment_1;

#a. Show the call id of all calls that were made between 8am and 10am on June 2022 having duration < 30

SELECT Call_id
FROM CALLS
WHERE Phone_Datetime >= '2022-06-01' AND Phone_Datetime < '2022-07-01'
  AND TIME(Phone_Datetime) BETWEEN '08:00:00' AND '10:00:00'
  AND Duration < 30;
  

#b. Show the first and last name of customers that live in a city with population greater than 20000

SELECT c.First_name,c.Last_name
FROM CUSTOMER c join CITY ct on c.City_id = ct.City_id 
WHERE ct.Population>20000;

#c. Show the customer id that have a contract in the plan with name LIKE ‘Freedom’ (use nested queries).

SELECT DISTINCT Customer_id
FROM CONTRACT
WHERE Plan_id IN (SELECT Plan_id FROM PLAN WHERE Plan_Name LIKE 'Freedom%')
ORDER BY Customer_id; 

#d. For each contract that ends in less than sixty days from today, show the contract id, the phone number,
#   the customer’s id, his/her first name and his/her last name.

SELECT ct.Contract_id,ct.Phone_number,c.Customer_id,c.First_name,c.Last_name
FROM CUSTOMER c JOIN CONTRACT ct ON ct.Customer_id = c.Customer_id
WHERE  datediff(ct.End_date,CURDATE())BETWEEN 0 AND 59;

#e. For each contract id and each month of 2022, show the average duration of calls

WITH RECURSIVE months(mo) AS (
  SELECT 1
  UNION ALL
  SELECT mo + 1 FROM months WHERE mo < 12
)
SELECT
  ct.Contract_id,
  m.mo AS Month_of_2022,
  COALESCE(AVG(cl.Duration), 0) AS Avg_Duration
FROM CONTRACT ct
CROSS JOIN months m
LEFT JOIN CALLS cl
  ON cl.Contract_id = ct.Contract_id
 AND cl.Phone_Datetime >= '2022-01-01'
 AND cl.Phone_Datetime <  '2023-01-01'
 AND MONTH(cl.Phone_Datetime) = m.mo
GROUP BY ct.Contract_id, m.mo
ORDER BY ct.Contract_id, m.mo;


#f. Show the total duration of calls in 2022 per plan id

SELECT ct.Plan_id, SUM(cl.Duration) AS Total_Duration
FROM CALLS cl
JOIN CONTRACT ct ON cl.Contract_id = ct.Contract_id
WHERE cl.Phone_Datetime >= '2022-01-01'
  AND cl.Phone_Datetime <  '2023-01-01'
GROUP BY ct.Plan_id
ORDER BY ct.Plan_id;

#g. Show the top called number among TP’s customers in 2022

SELECT cl.Called_phone, COUNT(*) AS Number_of_Call
FROM CALLS cl
JOIN CONTRACT ct ON ct.Phone_number = cl.Called_phone
WHERE cl.Phone_Datetime >= '2022-01-01' AND cl.Phone_Datetime <  '2023-01-01'
GROUP BY cl.Called_phone
ORDER BY Number_of_Call DESC
LIMIT 1;

#h. Show the contract ids and the months where the total duration of the calls was greater than the free
#   minutes offered by the plan of the contract.

SELECT TEMP1.Contract_id, TEMP1.Months
FROM (
  SELECT
    ct.Contract_id,
    MONTH(cl.Phone_Datetime) AS Months,
    SUM(cl.Duration) AS Total_Duration,
    MAX(p.Minutes) * 60 AS Seconds
  FROM CONTRACT ct
  JOIN CALLS cl ON cl.Contract_id = ct.Contract_id
  JOIN PLAN  p  ON p.Plan_id      = ct.Plan_id
  GROUP BY ct.Contract_id, MONTH(cl.Phone_Datetime)
) AS TEMP1
WHERE TEMP1.Total_Duration > TEMP1.Seconds
ORDER BY TEMP1.Contract_id, TEMP1.Months;


#i. For each month of 2022, show the percentage change of the total duration of calls compared to the same
#   month of 2021.


WITH RECURSIVE months(mo) AS (
  SELECT 1
  UNION ALL
  SELECT mo + 1 FROM months WHERE mo < 12
),
m21 AS (
  SELECT MONTH(Phone_Datetime) AS Mo, SUM(Duration) AS Total_2021
  FROM CALLS
  WHERE Phone_Datetime >= '2021-01-01' AND Phone_Datetime < '2022-01-01'
  GROUP BY MONTH(Phone_Datetime)
),
m22 AS (
  SELECT MONTH(Phone_Datetime) AS Mo, SUM(Duration) AS Total_2022
  FROM CALLS
  WHERE Phone_Datetime >= '2022-01-01' AND Phone_Datetime < '2023-01-01'
  GROUP BY MONTH(Phone_Datetime)
)
SELECT
  m.mo AS Months,
  COALESCE(m22.Total_2022, 0) AS Total_2022,
  COALESCE(m21.Total_2021, 0) AS Total_2021,
  CASE
    WHEN COALESCE(m21.Total_2021,0) = 0 AND COALESCE(m22.Total_2022,0) > 0 THEN  100.00
    WHEN COALESCE(m21.Total_2021,0) > 0 AND COALESCE(m22.Total_2022,0) = 0 THEN -100.00
    WHEN COALESCE(m21.Total_2021,0) = 0 AND COALESCE(m22.Total_2022,0) = 0 THEN   0.00
    ELSE ROUND(100.0 * (m22.Total_2022 - m21.Total_2021) / NULLIF(m21.Total_2021,0), 2)
  END AS Percentage_Change
FROM months m
LEFT JOIN m22 ON m22.Mo = m.mo
LEFT JOIN m21 ON m21.Mo = m.mo
ORDER BY Months;


#j. For each city id and calls made in 2022, show the average call duration by females and the average call
#   duration by males (i.e. three columns)

SELECT ci.City_id,
ROUND(COALESCE(AVG(CASE WHEN c.Gender='Female' THEN cl.Duration END),0), 2) AS Avg_Female,
ROUND(COALESCE(AVG(CASE WHEN c.Gender='Male'   THEN cl.Duration END),0), 2) AS Avg_Male
FROM CALLS cl
JOIN CONTRACT ct ON ct.Contract_id = cl.Contract_id
JOIN CUSTOMER c  ON c.Customer_id  = ct.Customer_id
JOIN CITY ci     ON ci.City_id     = c.City_id
WHERE cl.Phone_Datetime >= '2022-01-01' AND cl.Phone_Datetime <  '2023-01-01'
GROUP BY ci.City_id
ORDER BY ci.City_id;


#k. For each city id, show the city id, the ratio of the total duration of the calls made from customers staying
#   in that city in 2022 over the total duration of all calls made in 2022, and the ratio of the city’s population
#   over the total population of all cities (i.e three columns)

WITH TEMP4 AS (
  SELECT SUM(cl.Duration) AS Total_Duration_2022
  FROM CALLS cl
  WHERE cl.Phone_Datetime >= '2022-01-01'
    AND cl.Phone_Datetime <  '2023-01-01'),
TEMP5 AS (
  SELECT
    ci.City_id,
    SUM(cl.Duration) AS CitySec,         
    MAX(ci.Population) AS Population
  FROM CITY ci
  LEFT JOIN CUSTOMER cu ON cu.City_id    = ci.City_id
  LEFT JOIN CONTRACT ct ON ct.Customer_id = cu.Customer_id
  LEFT JOIN CALLS   cl ON cl.Contract_id  = ct.Contract_id
                       AND cl.Phone_Datetime >= '2022-01-01'
                       AND cl.Phone_Datetime <  '2023-01-01'
  GROUP BY ci.City_id),
TEMP6 AS (
  SELECT SUM(Population) AS Total_Population
  FROM CITY)
SELECT
  TEMP5.City_id,
  COALESCE(TEMP5.CitySec,0) / NULLIF(TEMP4.Total_Duration_2022,0) AS City_Duration_Ratio,
  TEMP5.Population        / NULLIF(TEMP6.Total_Population,0)      AS Population_Ratio
FROM TEMP5
CROSS JOIN TEMP4
CROSS JOIN TEMP6
ORDER BY TEMP5.City_id;












