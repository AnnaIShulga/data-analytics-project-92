select COUNT(customer_id) as customers_count --считает общее количество покупателей из таблицы customers
from customers

select --отчет о десятке лучших продавцов по выручке
	CONCAT(e.last_name,' ', e.first_name) as name,
	COUNT(s.sales_id) as operations,
	sum(s.quantity * p.price) as income
from sales s
left join employees e on e.employee_id = s.sales_person_id
left join products p on p.product_id = s.product_id
group by CONCAT(e.last_name,' ', e.first_name)
order by sum(s.quantity * p.price) desc
limit 10;

select --отчет с продавцами, чья выручка ниже средней выручки всех продавцов
	CONCAT(e.last_name,' ', e.first_name) as name,
	ROUND(AVG(s.quantity * p.price),0) as average_income
from sales s
left join employees e on e.employee_id = s.sales_person_id
left join products p on p.product_id = s.product_id
group by CONCAT(e.last_name,' ', e.first_name)
having ROUND(AVG(s.quantity * p.price),0) < (select avg(s.quantity * p.price) from sales s left join products p on p.product_id = s.product_id)
order by average_income;

select--отчет с данными по выручке по каждому продавцу и дню недели
	CONCAT(e.last_name,' ', e.first_name) as name,
	to_char(s.sale_date, 'day') as weekday,
	sum(s.quantity * p.price) as income
from sales s
left join employees e on e.employee_id = s.sales_person_id
left join products p on p.product_id = s.product_id
group by CONCAT(e.last_name,' ', e.first_name),s.sale_date
order by to_char(s.sale_date, 'D'), name;