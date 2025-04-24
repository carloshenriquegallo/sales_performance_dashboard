-- (Query 1) Revenue, leads, conversion and avg ticket month by month
with
	leads as (
		select
		date_trunc('month',  visit_page_date)::date as visit_page_month,
		count(*) as visit_page_count
	from sales.funnel
	group by visit_page_month
	order by visit_page_month
	),
	
	
	payments as (
		select
		date_trunc('month', fun.paid_date)::date as paid_month,
		count(fun.paid_date) as paid_count,
		sum(prd.price * (1+fun.discount))revenue

	from sales.funnel as fun
		left join sales.products as prd
		on fun.product_id = prd.product_id
	where fun.paid_date is not null
	group by paid_month
	order by paid_month
	)
	
select
	leads.visit_page_month as "month",
	leads.visit_page_count as "leads (#)",
	payments.paid_count as "sales (#)",
	(payments.revenue/1000) as "revenue (k, BRL)",
	(payments.paid_count::float/leads.visit_page_count::float) as "conversion",
	(payments.revenue/payments.paid_count/1000) as "AVG Ticket (k, BRL)"
	
from leads
left join payments
	on leads.visit_page_month = payments.paid_month
