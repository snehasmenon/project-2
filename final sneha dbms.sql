create database project; 
use project;
select * from cust_dimen;
select * from market_fact;
select * from orders_dimen;
select * from prod_dimen;
select * from shipping_dimen;
-- Part:1 Sales and Delivery
-- Question 1: Find the top 3 customers who have the maximum number of orders
SELECT CUST_ID, COUNT(DISTINCT M.ORD_ID) AS NO_OF_ORDERS 
FROM MARKET_FACT M JOIN ORDERS_DIMEN O
ON M.ORD_ID=O.ORD_ID
GROUP BY CUST_ID
ORDER BY NO_OF_ORDERS DESC LIMIT 3; 

-- Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date
SELECT O.ORD_ID, ORDER_DATE, SHIP_DATE, DATEDIFF(STR_TO_DATE(SHIP_DATE,'%d-%m-%Y'),STR_TO_DATE(ORDER_DATE,'%d-%m-%Y')) AS DaysTakenForDelivery
FROM ORDERS_DIMEN O JOIN SHIPPING_DIMEN S
ON O.ORDER_ID=S.ORDER_ID;

-- Question 3: Find the customer whose order took the maximum time to get delivered.
SELECT CUSTOMER_NAME, O.ORD_ID, DATEDIFF(STR_TO_DATE(SHIP_DATE,'%d-%m-%Y'),STR_TO_DATE(ORDER_DATE,'%d-%m-%Y')) AS DaysTakenForDelivery
FROM ORDERS_DIMEN O JOIN SHIPPING_DIMEN S
ON O.ORDER_ID=S.ORDER_ID
JOIN MARKET_FACT M
ON O.ORD_ID=M.ORD_ID
JOIN CUST_DIMEN C
ON M.CUST_ID=C.CUST_ID
ORDER BY DaysTakenForDelivery DESC LIMIT 1;

-- Question 4: Retrieve total sales made by each product from the data (use Windows function)
SELECT DISTINCT PROD_ID, ROUND((SUM(SALES)OVER(PARTITION BY PROD_ID)),2) AS TOTAL_SALES
FROM MARKET_FACT
ORDER BY TOTAL_SALES DESC;

-- Question 5: Retrieve the total profit made from each product from the data (use windows function)
SELECT DISTINCT PROD_ID, ROUND((SUM(PROFIT)OVER(PARTITION BY PROD_ID)),2) AS TOTAL_PROFIT
FROM MARKET_FACT
ORDER BY TOTAL_PROFIT DESC;
#  Question 6: Count the total number of unique customers in January and how many of them came back every month over the entire
# year in 2011
select 'count of repetition' as Descirption,count(*) from (
(select 'count' as Descirption,count(distinct month) cnt from (
select customer_name,cd.Cust_id,year(str_to_date(Order_Date,'%d-%m-%Y')) year ,
month(str_to_date(Order_Date,'%d-%m-%Y')) month from cust_dimen cd 
left join market_fact  mf on mf.Cust_id=cd.Cust_id
left join orders_dimen od on od.Ord_id=mf.Ord_id
order by 1,2,3,4
)t
where year=2011
group  by  customer_name,Cust_id
having cnt>=12
order by 1)

)y
union all
(select 'total in january', count(distinct cust_id) from market_fact
where Ord_id in (select Ord_id from orders_dimen where year(str_to_date(Order_Date,'%d-%m-%Y'))=2011 and 
month(str_to_date(Order_Date,'%d-%m-%Y'))=1 
));




#part b

use project;
#Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.
select name,alcohol,count(userID)
from geoplaces2 g join rating_final r
using(placeID)
where alcohol like "%alcohol%"
group by alcohol,name;



#Question 2: -Let's find out the average rating according to alcohol and price so that we can understand the rating in respective price 
#categories as well.
select avg(r.rating) ,g.alcohol,g.price
from rating_final r join geoplaces2 g
using(placeid)
where alcohol not like  "%No%"
group by g.alcohol,g.price;


#Question 3:  Let’s write a query to quantify that what are the parking availability as well 
#in different alcohol categories along with the total number of restaurants.
select g.placeID,parking_lot,alcohol,count(g.placeID)over(partition by alcohol)
from geoplaces2 g join chefmozparking c
where alcohol not like  "%No%"
;

#Question 4: -Also take out the percentage of different cuisine in each alcohol type.


 select *,(available_cuisine/sum_each)*100 percentage from
 (select *,sum(available_cuisine)over(partition by alcohol)sum_each from 
(select alcohol,c.Rcuisine,count( c.Rcuisine) available_cuisine from
 geoplaces2 g 
  join chefmozcuisine c on g.placeID=c.placeID 
 group by alcohol,Rcuisine)t1)t2;
 
# Questions 5: - let’s take out the average rating of each state.


 select g.state,avg(rf.rating)rat from 
 geoplaces2 g join rating_final rf
 on g.placeID=rf.placeID
 group by g.state
 order by rat;
 #Questions 6: -' Tamaulipas' Is the lowest average rated state.
 #Quantify the reason why it is the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine.

/*  Questions 6: -' Tamaulipas' Is the lowest average rated state. 
Quantify the reason why it is the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine. */

 select state,
 (select count(alcohol) from geoplaces2 gp2 where alcohol<>'No_Alcohol_Served' and gp2.state=gp.state ) as
 ct_alcohol_serverd_places,
 count(distinct Rcuisine) ct_cuisine_available_in_places ,
 avg(rating) ,avg(service_rating),avg(food_rating) from geoplaces2 gp
 left join chefmozcuisine cc on cc.placeid=gp.placeID
 left join rating_final rf on rf.placeID=gp.placeID
group by 1
order by 1,2,3;

-- based on number of restaurant serving alcohol and number of cuisines avilable in that state, we came to
-- the conclusion that in the given state there is no restaurant with alcohol and also food rating for the available cusines are
-- comparatively lower


/* Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC 
and tried Mexican or Italian types of cuisine, and also their budget level is low.
We encourage you to give it a try by not using joins. */


SELECT 
    (SELECT AVG(weight)
     FROM userprofile
     WHERE budget = 'low'
     AND userid IN (
         SELECT userid
         FROM usercuisine
         WHERE Rcuisine LIKE 'MEXI%' OR Rcuisine LIKE 'ITAL%'
         AND userid IN (
             SELECT userid
             FROM rating_final
             WHERE placeID IN (
                 SELECT placeID
                 FROM geoplaces2
                 WHERE name LIKE 'KFC'
             )
         )
     )
    ) AS avg_WEIGHT,
    
    (SELECT AVG(food_rating)
     FROM rating_final
     WHERE userid IN (
         SELECT userid
         FROM usercuisine
         WHERE Rcuisine LIKE 'MEXI%' OR Rcuisine LIKE 'ITAL%'
         AND userid IN (
             SELECT userid
             FROM rating_final
             WHERE placeID IN (
                 SELECT placeID
                  from geoplaces2
                 WHERE name LIKE 'KFC'
             )
         )
     )
    ) AS avg_FOOD,
    
    (SELECT AVG(service_rating)
     FROM rating_final
     WHERE userid IN (
         SELECT userid
         FROM usercuisine
         WHERE Rcuisine LIKE 'MEXI%' OR Rcuisine LIKE 'ITAL%'
         AND userid IN (
             SELECT userid
             FROM rating_final
             WHERE placeID IN (
                 SELECT placeID
                 FROM geoplaces2
                 WHERE name LIKE 'KFC'
             )
         )
     )
    ) AS avg_service;



-- Part:3 Triggers
 -- Question 1: Create two called Student_details and Student_details_backup. Insert some records into Student details. 
CREATE DATABASE TRIGGERS_DB;
USE TRIGGERS_DB;
CREATE TABLE STUDENT_DETAILS
(STUDENT_ID VARCHAR(7),
STUDENT_NAME VARCHAR(20),
MAIL_ID VARCHAR(30),
MOBILE_NO BIGINT);

CREATE TABLE STUDENT_DETAILS_BACKUP
(STUDENT_ID VARCHAR(7),
STUDENT_NAME VARCHAR(20),
MAIL_ID VARCHAR(30),
MOBILE_NO BIGINT);

INSERT INTO STUDENT_DETAILS VALUES (60502,'RICKY', 'rickyhobb1@yahoo.com', 9578302340),
(65232,'JULIE','juliechristy5@gmail.com', 8934593745),
(65793,'DILIP','dilipraj123@gmail.com',9567934739),
(64593, 'MINA', 'minaprakash98@gmail.com', 9739259595);


CREATE TRIGGER STUDENT_BACKUP_DETAILS
BEFORE DELETE ON STUDENT_DETAILS
FOR EACH ROW
INSERT INTO STUDENT_DETAILS_BACKUP (STUDENT_ID,STUDENT_NAME,MAIL_ID,MOBILE_NO) 
VALUES (OLD.STUDENT_ID, OLD.STUDENT_NAME, OLD.MAIL_ID, OLD.MOBILE_NO);

DELETE FROM STUDENT_DETAILS WHERE STUDENT_NAME='RICKY';
SELECT * FROM STUDENT_DETAILS;
SELECT * FROM STUDENT_DETAILS_BACKUP;

-- MAJOR CHALLENGES
USE SALES_DELIVERY;

-- 1 Use of GROUP_CONCAT function to show customers from same city.
SELECT PROVINCE, REGION, GROUP_CONCAT(CUSTOMER_NAME ORDER BY CUST_ID SEPARATOR ', ') AS CUSTOMER_LIST
FROM CUST_DIMEN
GROUP BY PROVINCE, REGION;

-- 2 Creating stored procedure to retrieve user ids based on religion.
-- The stored procedure will be useful to make attractive offers during festival times.
DELIMITER //
CREATE PROCEDURE GetUsersByReligion(IN RELIGION_NAME VARCHAR(50))
BEGIN
    SELECT * FROM USERPROFILE WHERE RELIGION = RELIGION_NAME;
END;
//
DELIMITER ;
CALL GetUsersByReligion('Jewish');

-- 3 Calculate delta values of order date for each customer
 SELECT CUST_ID, STR_TO_DATE(ORDER_DATE,'%d-%m-%Y') AS 'ORDER DATE', LAG(STR_TO_DATE(ORDER_DATE,'%d-%m-%Y'))OVER(PARTITION BY CUST_ID ORDER BY STR_TO_DATE(ORDER_DATE,'%d-%m-%Y'))
 AS 'PREVIOUS ORDER DATE', DATEDIFF(STR_TO_DATE(ORDER_DATE,'%d-%m-%Y'),LAG(STR_TO_DATE(ORDER_DATE,'%d-%m-%Y'))OVER(PARTITION BY CUST_ID ORDER BY STR_TO_DATE(ORDER_DATE,'%d-%m-%Y')))
 AS 'DAYS BETWEEN THE PURCHASES'
 FROM MARKET_FACT M JOIN ORDERS_DIMEN O
 ON M.ORD_ID=O.ORD_ID
 ORDER BY CUST_ID;
 
 -- 4 Creating index on food_rating to retrieve restaurant information easily.
 CREATE INDEX ID_FOOD_RATING
 ON RATING_FINAL(FOOD_RATING);
 
 SELECT R.PLACEID, NAME, RATING, FOOD_RATING, SERVICE_RATING
 FROM RATING_FINAL R JOIN GEOPLACES2 G
 ON R.PLACEID=G.PLACEID
 WHERE FOOD_RATING=2;
 
 -- 5  Retrieve the total profit made from each product from the data and give percentile ranks where total profit is positive.
SELECT *, PERCENT_RANK()OVER(ORDER BY TOTAL_PROFIT) AS PCTRANK FROM
(SELECT DISTINCT PROD_ID, ROUND((SUM(PROFIT)OVER(PARTITION BY PROD_ID)),2) AS TOTAL_PROFIT
FROM MARKET_FACT
ORDER BY TOTAL_PROFIT DESC)TEMP
WHERE TOTAL_PROFIT>0;

 
 




