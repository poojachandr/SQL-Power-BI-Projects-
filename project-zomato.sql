use learn 

drop table if exists gold_signup
create table gold_signup(user_id int,gold_signup_date date);

insert into gold_signup(user_id,gold_signup_date)
values(1,'09-22-2017'),
(3,'04-21-2017');

select *from gold_signup

drop table if exists prod
create table prod(product_id int, product_name varchar(30), price int)

insert into prod values
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select *from prod

drop table if exists users
create table users(user_id int,signup_date date);

insert into users values
(1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

select *from users

drop table if exists sales
create table sales(user_id int,created_at date,product_id int);
insert into sales values
(1,'04-19-2017',2),
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

select *from sales
select *from gold_signup
select *from users
select *from prod

---1. What is the total amount each customer spent on zomato?
select s.user_id,sum(p.price) as 'total amount' from
sales s
inner join
prod p
on s.product_id = p.product_id
group by user_id

---2. How many days has each customer visited zomato?
select user_id,count(distinct created_at) as 'days' from sales 
group by user_id
 
---3. what was the first product purchased by each customer
SELECT *from
(select *,
dense_rank() over (partition by user_id order by created_at) RN
from sales) sales where RN=1

---4. what is the most purchased item on the menu and how many times was it purchased by all customers?
select product_id,count(product_id) as 'no.' from sales 
group by product_id 
order by count(product_id) desc

select user_id,count(product_id) as 'no' from sales 
where product_id = (select top 1 product_id from sales 
group by product_id 
order by count(product_id) desc)
group by user_id

---5. which item was the most popular for each customer 

select *from
(select *,rank()over(partition by user_id order by cnt desc) RK from 
(select user_id,product_id,count(product_id) cnt from sales
group by user_id,product_id)sales)sales
where RK=1

---6. which item was purchased first by the customer after they became a gold member?
with cse
as
(
select a.user_id,a.created_at,a.product_id,b.gold_signup_date from sales a 
inner join gold_signup b
on a.user_id = b.user_id and a.created_at >= b.gold_signup_date
)
select *from
(select *,rank()over (partition by user_id order by created_at)RK from cse
) T
where RK=1

--7. which item was purchased just before the customer become a member?

with cse
as
(
select a.user_id,a.created_at,a.product_id,b.gold_signup_date from sales a 
inner join gold_signup b
on a.user_id = b.user_id and a.created_at <= b.gold_signup_date
)
select *from
(select *,rank()over (partition by user_id order by created_at desc)RK from cse
) T
where RK=1

8. ---what is the total orders and amount spend for each member before they become a member?

select e.user_id,count(e.product_id) as 'orders',sum(e.price) as 'amount' from
(select c.*,d.price from (select a.user_id,a.created_at,a.product_id,b.gold_signup_date from sales a
inner join gold_signup b 
on a.user_id = b.user_id and created_at < gold_signup_date)c 
inner join prod d
on c.product_id = d.product_id)e
group by user_id


