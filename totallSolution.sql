--select * from order_details

--Basic Qussion---------------

--Q1.Retrieve the total number of orders placed.

select count(order_id) as Total_order from orders

--Q2.Calculate the total revenue generated from pizza sales.

select round(sum(order_details.quantity * pizzas.price),3) as Total_price from order_details
inner join pizzas
on order_details.pizza_id=pizzas.pizza_id

--Q3.Identify the highest-priced pizza.

select top 1 pizza_types.name,pizzas.price from pizza_types
inner join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
order by pizzas.price desc;

--Q4.Identify the most common pizza size ordered.

select pizzas.size,count(order_details.order_id) from pizzas
inner join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size order by count(order_details.order_id) desc

--Q5.List the top 5 most ordered pizza types along with their quantities.

select top(5) pizza_types.name,sum(order_details.quantity) as quntity_count from pizza_types
inner join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
inner join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.name order by quntity_count desc;

--Intermediate:Qussions

--Q6.Join the necessary tables to find the total quantity 
--of each pizza category ordered.

select pizza_types.category,sum(order_details.quantity) from pizza_types
	inner join pizzas
	on pizza_types.pizza_type_id=pizzas.pizza_type_id
	inner join order_details
	on pizzas.pizza_id=order_details.pizza_id
	group by pizza_types.category order by sum(order_details.quantity) desc;

--Q7.Determine the distribution of orders by hour of the day.

select DATEPART(HOUR,order_time) as DTime,count(order_id) as orderCount from orders
group by DATEPART(HOUR,order_time) order by orderCount desc;

--Q8.Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) from pizza_types
group by category order by count(name) desc;

--Q9.Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(quantity_day) as Avg_perday from
(select orders.order_date,sum(order_details.quantity) as quantity_day from orders
inner join order_details
on orders.order_id=order_details.order_id
group by orders.order_date) as quntities;

--Q10.Determine the top 3 most ordered pizza types based on revenue.

select top(3) pizza_types.name,sum(order_details.quantity*pizzas.price) from pizza_types
inner join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
inner join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.name
order by sum(order_details.quantity*pizzas.price) desc;

--Advanced:
--Q11.Calculate the percentage contribution of each pizza type to total revenue.

--Q12.Analyze the cumulative revenue generated over time.

select order_date,revenue,
sum(revenue) over(order by order_date)
from (select orders.order_date,sum(order_details.quantity*pizzas.price) as revenue from order_details
inner join pizzas
on order_details.pizza_id=pizzas.pizza_id
inner join orders
on orders.order_id=order_details.order_id
group by orders.order_date) as sales;

--Q13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,revenue from
(select category,name,revenue,
	RANK() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category,pizza_types.name,sum(order_details.quantity * pizzas.price) as revenue from pizza_types
	inner join pizzas
		on pizza_types.pizza_type_id=pizzas.pizza_type_id
	inner join order_details
		on pizzas.pizza_id=order_details.pizza_id
	group by pizza_types.category,pizza_types.name) as a) as b
	where rn<=3;