use dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(255),  -- Adjust the length as needed
  order_date DATE,
  product_id INTEGER
);


INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id  INTEGER,
  product_name VARCHAR(2555),
  price  INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(255),
  join_date  DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  select * from sales;
  select * from menu;
  select * from members;
  

  select * from sales s 
  left join menu m on s.product_id = m.product_id 
  left join members e on s.customer_id = e.customer_id;
  
  
  -- --1)  What is the total amount each customer spent at the restaurant?
  
  select  s.customer_id  as customer ,  sum(m.price) as Total_amount_spent  from sales s 
  join menu m on s.product_id = m.product_id 
  group by 1;
  
  -- 2) How many days has each customer visited the restaurant?
  
  select customer_id  as customer , count(order_date)  as visit_days from sales 
  group by 1;
  
  -- 3) What was the first item from the menu purchased by each customer?
  
  with cte as (
  select s.customer_id as customer ,  m.product_name  as first_item_purchased, s. order_date , 
  dense_rank() over (partition by s.customer_id  order by  s.order_date )  as rnk1
  from sales s left join menu m on s.product_id = m.product_id ) 
  
  select distinct customer , first_item_purchased   from cte 
  where rnk1  = '1';
  
-- 4) What is the most purchased item on the menu and how many times was it purchased by all customers?

with cte as (
select  s.customer_id , m.product_name , m.product_id  , 
dense_rank() over ( order by m.product_id desc )  as most_Purchased_item from  sales s left join menu m on s.product_id = m.product_id )

select customer_id , product_name as most_porchased_product  , count(product_id ) as  count_of_purchased_item  from cte 
where most_Purchased_item = '1'
group by 1 , 2;

-- --5)  Which item was the most popular for each customer?

with  cte as (
select  s.customer_id , m.product_name ,   count(*)  as items_ordered 
 from  sales s left join menu m on s.product_id = m.product_id 
 group by 1, 2 )

select customer_id , product_name as most_popular_product  from cte 
where items_ordered  = (select max(items_ordered)  from cte) ;

-- 6) Which item was purchased first by the customer after they became a member?

with cte as (
select s.customer_id , m.product_name, e.join_date , s.order_date , 
dense_rank() over (partition by customer_id order by order_date asc) as rank1  from sales s
left join menu m using(product_id)
left join members e using (customer_id ) 
where order_date >= join_date )

select customer_id, product_name as first_product , join_date , order_date   from cte 
where rank1 = '1';


-- 7) Which item was purchased just before the customer became a member?

with cte as (
select s.customer_id , m.product_name, e.join_date , s.order_date , 
rank() over (partition by customer_id order by order_date desc ) as rank1  from sales s
left join menu m using(product_id)
left join members e using (customer_id ) 
where order_date <= join_date )

select customer_id, product_name , join_date , order_date from cte 
where rank1 = '1' ; 

-- 8) what is the total items and amount spent for each member before they became a member?  

with cte as (
select  s.customer_id ,  s.product_id , m.price   from  sales s
left join menu m using(product_id )
left join members e using(customer_id) 
where order_date < join_date ) 

select customer_id , count(product_id ) as total_items  , sum(price)  as amount_spent  from cte 
group by 1;

-- 9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with cte as (
select s.customer_id ,  
case when  product_name = 'sushi'  then 20*price 
else 10* price  
end as  points  
from sales s left join menu m using(product_id ))

select customer_id , sum(points)  as total_points   from cte 
group by 1 ;

-- 10)  In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
--  not just sushi - how many points do customer A and B have at the end of January?

with cte as (
select s.customer_id , m.price ,  s.order_date , 
case when order_date >= join_date  then  price*20
else null
end as points 
from sales s 
left join menu m using (product_id)
left join members e using ( customer_id ) )

select customer_id , sum(points)  as total_points from cte 
where points is not null  and  order_date < ' 2021-01-31'  
group by 1;













-- 


















  

  
  

  
  
  
  
  
  
  