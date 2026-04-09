show databases;

create database pizzahut;

use pizzahut;

create table orders(
order_id int primary key,
order_date date not null,
order_time time not null
);

create table order_details(
order_details_id int primary key,
order_id int not null,
pizza_id varchar(100) not null,
quantity int not null
);

-- Basic :
-- Retrieve the total number of orders placed.
select count(order_id)as Total_orders
from orders;


-- Calculate the total revenue generated from pizza sales.
select round(sum(od.quantity*p.price),2)
from order_details od join pizzas p
on od.pizza_id=p.pizza_id;


-- Identify the highest-priced pizza.
select *
from pizzas
order by price desc
limit 1;


-- Identify the most common pizza size ordered.
select p.size,sum(od.quantity)as total_order
from pizzas p join order_details od
on p.pizza_id=od.pizza_id
group by p.size
order by total_order desc
limit 1;


-- List the top 5 most ordered pizza types along with their quantities.
select p.pizza_type_id,sum(od.quantity) quantity
from pizzas p join order_details od
on p.pizza_id=od.pizza_id
group by pizza_type_id
order by quantity desc
limit 5;


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
select p.pizza_id, sum(od.quantity) quantity
from pizzas p left join order_details od
on p.pizza_id=od.pizza_id
group by p.pizza_id;


-- Determine the distribution of orders by hour of the day.
select hour(order_time),count(order_id)
from orders
group by hour(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.
select category,count(pizza_type_id)
from pizza_types 
group by category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(day_order),0) from
(select o.order_date, sum(od.quantity), sum(od.quantity) as day_order
from orders o join order_details od
on o.order_id=od.order_id
group by order_date)as t1;


-- Determine the top 3 most ordered pizza types based on revenue.
select p.pizza_type_id, sum(p.price * od.quantity)as revenue
from pizzas p join order_details od
on p.pizza_id=od.pizza_id
group by p.pizza_type_id
order by revenue desc
limit 3;


-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
-- method 1:
select category, revenue, round((revenue/sum(revenue)over())*100,2) as percentage from
(select pt.category, round(sum(od.quantity*p.price),2) as revenue
from pizzas p 
join order_details od on p.pizza_id=od.pizza_id
join pizza_types pt on p.pizza_type_id=pt.pizza_type_id
group by pt.category) as t;

-- method 2
select category, round((ind_sum/total_sum)*100,2) as percentage 
from
(select pt.category,sum(p.price*od.quantity) as ind_sum
from pizzas p
join order_details od on p.pizza_id=od.pizza_id
join pizza_types pt on p.pizza_type_id=pt.pizza_type_id
group by pt.category)as cat_sum, 
(select sum(p.price*od.quantity)as total_sum
from pizzas p
join order_details od on p.pizza_id=od.pizza_id)as total;


-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_sum 
from
(select o.order_date ,round(sum(p.price*od.quantity),2)as revenue
from pizzas p
join order_details od on p.pizza_id=od.pizza_id
join orders o on od.order_id=o.order_id
group by o.order_date
order by o.order_date asc)as t;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select pt.category, round(sum(od.quantity*p.price),2)as revenue
from pizzas p 
join order_details od on p.pizza_id=od.pizza_id
join pizza_types pt on p.pizza_type_id=pt.pizza_type_id
group by pt.category
order by revenue desc;