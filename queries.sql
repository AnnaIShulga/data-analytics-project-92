select COUNT(customer_id) as customers_count --считает общее количество покупателей из таблицы customers
from customers

select --отчет о десятке лучших продавцов по выручке
	CONCAT(e.first_name,' ', e.last_name) as name,
	COUNT(s.sales_id) as operations,
	floor(sum(s.quantity * p.price)) as income
from sales s
left join employees e on e.employee_id = s.sales_person_id
left join products p on p.product_id = s.product_id
group by CONCAT(e.first_name,' ', e.last_name)
order by floor(sum(s.quantity * p.price)) desc
limit 10;

select --отчет с продавцами, чья выручка ниже средней выручки всех продавцов
	CONCAT(e.first_name,' ', e.last_name) as name,
	ROUND(AVG(s.quantity * p.price),0) as average_income
from sales s
left join employees e on e.employee_id = s.sales_person_id
left join products p on p.product_id = s.product_id
group by CONCAT(e.first_name,' ', e.last_name)
having ROUND(AVG(s.quantity * p.price),0) < (select avg(s.quantity * p.price) from sales s left join products p on p.product_id = s.product_id)
order by average_income;

with tab as --отчет с данными по выручке по каждому продавцу и дню недели
(select
s.sale_date as sale_date,
CONCAT(e.first_name,' ', e.last_name) as name,
sum(s.quantity * p.price) as income,
to_char(sale_date, 'day') as weekday,
case when to_char(sale_date, 'day')= 'monday   ' then '1'
 	 when to_char(sale_date, 'day')= 'tuesday  ' then '2'
 	 when to_char(sale_date, 'day')= 'wednesday' then '3' 
	 when to_char(sale_date, 'day')= 'thursday ' then '4' 
	 when to_char(sale_date, 'day')= 'friday   ' then '5' 
	 when to_char(sale_date, 'day')= 'saturday ' then '6' 
	 when to_char(sale_date, 'day')= 'sunday   ' then '7'
else 0
end as rn
from sales s
left join employees e on e.employee_id = s.sales_person_id
left join products p on p.product_id = s.product_id
group by s.sale_date, CONCAT(e.first_name,' ', e.last_name)
order by to_char(sale_date, 'id'), name)

select case when age > '16' and age <='25' then '16-25' --количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+
			when age >='26' and age <='40' then '26-40'
			when age >='41' then '40+'
			else 'other'
		end as age_category,
		count(distinct c.customer_id)
from customers c 
group by age_category

select --данные по количеству уникальных покупателей и выручке, которую они принесли
	to_char(s.sale_date, 'YYYY-MM') as date,
	count(distinct s.customer_id) as total_customers,
	floor(sum(s.quantity * p.price))as income
from sales s
left join products p on p.product_id = s.product_id
group by to_char(s.sale_date, 'YYYY-MM')
order by to_char(s.sale_date, 'YYYY-MM');

select --покупатели первая покупка которых пришлась на время проведения специальных акций
	customer,
	sale_date,
	seller
from	(select 
		concat(c.first_name,' ',c.last_name) as customer,
		s.sale_date as sale_date,
		concat(e.first_name,' ',e.last_name) as seller,
		sum(s.quantity * p.price) as income,
		c.customer_id as id,
		row_number () over (partition by c.customer_id order by s.sale_date) as rn
		from sales s
		left join employees e on e.employee_id = s.sales_person_id
		left join products p on p.product_id = s.product_id
		left join customers c on c.customer_id = s.customer_id
		group by concat(c.first_name,' ',c.last_name),s.sale_date,concat(e.first_name,' ',e.last_name),c.customer_id ) as total
where rn = '1' and income = '0'
order by id
	