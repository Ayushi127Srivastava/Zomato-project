drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


           What is the total amount each customer spent on Zomato?


SELECT sales.userid, product.product_id ,sum(product.price) as total_amount_spent
FROM sales inner join  product
on sales.product_id=product.product_id
GROUP BY sales.userid , product.product_id

SELECT sales.userid, sum(product.price) as total_amount_spent
FROM sales inner join  product
on sales.product_id=product.product_id
GROUP BY sales.userid 

      how many days has each customer visited zomato?

SELECT * FROM goldusers_signup
SELECT * FROM product
SELECT * FROM sales
SELECT * FROM users 

SELECT sales.userid ,count(distinct(sales.created_date)) as number_of_days
FROM sales
GROUP BY sales.userid

       What is the first product purchased by each customer ?

SELECT *
FROM(SELECT *,RANK() over(partition by userid order by created_date ) rnk FROM sales) a
WHERE rnk=1

     What is the most purchased items on the menu and how many times it was purchased by all customer ?


SELECT distinct(product_id), count(product_id) as number_of_times_purchased
FROM sales
Group by product_id

SELECT distinct(product_id),count(product_id) as number_of_times_purchased
FROM sales
Group by product_id
order by number_of_times_purchased desc

SELECT top 1 product_id, count(product_id) as number_of_times_purchased
FROM sales
Group by product_id
order by number_of_times_purchased desc


    Which item was most popular for each customer ?

SELECT userid , product_id,count(product_id) as fav_order
FROM sales
group by userid,product_id
order by count(product_id) desc

SELECT * FROM
(Select *, rank() over (partition by userid order by fav_order desc ) rnk from 
(SELECT userid , product_id,count(product_id) as fav_order from sales group by userid,product_id) a) b 
WHERE rnk=1

   Which item was first purchased by the customer after they become the member?


 SELECT * from
 (SELECT *,rank() over (partition by userid order by created_date) rnk from
  
 ( SELECT sales.userid, sales.product_id,sales.created_date,goldusers_signup.gold_signup_date
   FROM sales
   inner join goldusers_signup
   on sales.userid=goldusers_signup.userid and created_date>=gold_signup_date) c)d
   WHERE rnk= 1
  

  

  Which item was purchased just before the customer become gold member ?

  SELECT * FROM
  (SELECT * ,rank() over(partition by userid order  by created_date desc)rnk from

 ( SELECT sales.userid, sales.product_id,sales.created_date,goldusers_signup.gold_signup_date
  FROM sales
  inner join goldusers_signup
  on sales.userid=goldusers_signup.userid and created_date<=gold_signup_date)c)d
  WHERE rnk=1


      What is the total order and amount spent for each member before they become member ?

SELECT * FROM goldusers_signup
SELECT * FROM product
SELECT * FROM sales
SELECT * FROM users 
 
 SELECT a.userid,count(a.product_id),sum(a.price)
 FROM
 (SELECT sales.userid,product.product_id, sales.created_date, goldusers_signup.gold_signup_date, product.price
 from sales
 inner join goldusers_signup
 on sales.userid=goldusers_signup.userid
 inner join product
 on sales.product_id=product.product_id and created_date<=gold_signup_date) a
 GROUP BY a.userid


    If buying each product generates point like - product1 p1 , 5Rs=1Zomato point and p2 , 10rs=5 zomato points and p3, 5rs=1zomato points
      Calculate points collected by each customers and for which product most point have been given till now ?





SELECT userid,sum(points_per_order) as points_earned_per_user
FROM
(
SELECT b.userid, b.price*b.points_per_rs as points_per_order
FROM
 (
SELECT *,case when product_id=1 then 0.2 when product_id=2 then 0.5 when product_id=3 then 0.2 else 0 end as points_per_rs FROM
(SELECT sales.userid,product.product_id,product.price
 FROM sales
 inner join product
 on sales.product_id=product.product_id)a)b)c
 GROUP BY userid



SELECT d.product_id,sum(d.total_points) as total_sum_points
FROM
( SELECT * , price*point_per_rs as total_points
FROM
 (SELECT *,case when product_id=1 then 0.2 when product_id=2 then 0.5 when product_id=3 then 0.2 else 0 end as point_per_rs 
  FROM
  (SELECT a.userid, a.product_id,sum(price) as price
  FROM
 (SELECT sales.userid,product.product_id,product.price
  FROM sales
  INNER JOIN product
  ON sales.product_id=product.product_id) a
  GROUP BY userid,product_id)b)c)d
GROUP BY d.product_id
ORDER BY total_sum_points desc

  In the first one year after a customer joins the gold program (including their join date ) irrespective of what the customer has purchased they 
  earn 5 zomato points for every 10rs spent who earned more 1 or 3 and what was their points earning in their first year ?



  SELECT userid , sum(points_per_rs) as total_points_per_user
  FROM
 (SELECT *, price*0.5 as points_per_rs
  FROM
 (SELECT sales.userid,product.product_id ,sales.created_date,goldusers_signup.gold_signup_date,product.price
  FROM sales
  inner join product 
  on sales.product_id=product.product_id
  inner join goldusers_signup
  on sales.userid=goldusers_signup.userid and created_date>gold_signup_date and created_date<= dateadd(year,1,gold_signup_date))a)b
  Group by userid
  Order by total_points_per_user  desc

  
       Rank all the transaction fo the customer ?

  SELECT * from sales

  SELECT * , rank ()over (partition by userid order by created_date )rnk 
  FROM sales

      Rank all the transaction for each customer whenever they are a zomato gold member for every non gold member trasaction mark as null

SELECT * , case when rnk=0 then 'na' else rnk end as rnkk from
(
SELECT *,cast((case when gold_signup_date is null then 0 else rank() over (partition by userid order by created_date desc) end )as varchar) as rnk 
FROM

(SELECT sales.userid, sales.product_id,sales.created_date,goldusers_signup.gold_signup_date
FROM sales
LEFT join goldusers_signup
On sales.userid=goldusers_signup.userid and created_date>=gold_signup_date)a)b

