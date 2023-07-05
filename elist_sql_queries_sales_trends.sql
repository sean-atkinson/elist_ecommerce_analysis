--for each month, calculating main sales metrics: order count, total sales, and aov
--filtering to only north america and macbooks
--rounding numbers for readability
with sales_trends_monthly_cte as (
  select date_trunc(orders.purchase_ts, month) as purchase_quarter,
    geo_lookup.region as region,
    count(orders.id) as total_orders,
    round(sum(orders.usd_price),2) as total_sales,
    round(avg(orders.usd_price), 2) as avg_sales
  from elist.orders orders
  join elist.customers customers
    on orders.customer_id = customers.id
  join elist.geo_lookup geo_lookup
    on customers.country_code = geo_lookup.country
  where region = 'NA' and lower(orders.product_name) like '%macbook%'
  group by 1,2)

---monthly trends across all years
select round(avg(total_orders)) as avg_total_orders,
  round(avg(total_sales)) as avg_quarterly_sales,
  round(avg(avg_sales)) as avg_price
from sales_trends_monthly_cte;

--for each quarter, calculating main sales metrics: order count, total sales, and aov
--filtering to only north america and macbooks
--round numbers for readability
with sales_trends_quarterly_cte as (
  select date_trunc(orders.purchase_ts, quarter) as purchase_quarter,
    geo_lookup.region as region,
    count(orders.id) as total_orders,
    round(sum(orders.usd_price),2) as total_sales,
    round(avg(orders.usd_price), 2) as avg_sales
  from elist.orders orders
  join elist.customers customers
    on orders.customer_id = customers.id
  join elist.geo_lookup geo_lookup
    on customers.country_code = geo_lookup.country
  where region = 'NA' and lower(orders.product_name) like '%macbook%'
  group by 1,2)
---quarterly trends across all years
select round(avg(total_orders)) as avg_total_orders,
  round(avg(total_sales)) as avg_quarterly_sales,
  round(avg(avg_sales)) as avg_price
from sales_trends_quarterly_cte;

--counting the number of refunds per month (non-null values in refund_ts represent refunds)
--calculting the refund rate
with monthly_refunds_cte as (
  select date_trunc(purchase_ts, month) as month,
    sum(case when refund_ts is not null then 1 else 0 end) as refunds,
    sum(case when refund_ts is not null then 1 else 0 end)/count(distinct order_id) as refund_rate
from elist.order_status order_status
group by 1
order by 1)
--calculating the monthly refund rate for 2020
select round(avg(refund_rate),3) as monthly_refunds
from monthly_refunds_cte
where extract(year from month) = 2020;

--calcultating the number of refunds per month (non-null values in refund_ts represent refunds)
--filtering for 2021 and products with apple in their name
select date_trunc(order_status.refund_ts, month) as month,
    sum(case when order_status.refund_ts is not null then 1 else 0 end) as refunds,
from elist.order_status order_status
join elist.orders orders
    on order_status.order_id = orders.id
where extract(year from order_status.refund_ts) = 2021
    and lower(orders.product_name) like '%apple%'
group by 1
order by 1;

--cleaning up product names
--calculating refund rates for each product
with refunds_cte as (
    select case when product_name ='27in"" 4k gaming monitor' then '27in 4K gaming monitor' else product_name end as product_name_clean,
        sum(case when order_status.refund_ts is not null then 1 else 0 end) as refunds,
        round(sum(case when order_status.refund_ts is not null then 1 else 0 end)/count(distinct orders.id),3) as refund_rate,
    from elist.orders orders
    left join elist.order_status order_status
        on orders.id = order_status.order_id
    group by 1)
--highlighting the 3 products with the highest refund rate
select product_name_clean, refund_rate
from refunds_cte
order by 2 desc
limit 3;

with refunds_cte as (
    select case when product_name ='27in"" 4k gaming monitor' then '27in 4K gaming monitor' else product_name end as product_name_clean,
        sum(case when order_status.refund_ts is not null then 1 else 0 end) as refunds,
        round(sum(case when order_status.refund_ts is not null then 1 else 0 end)/count(distinct orders.id),3) as refund_rate,
    from elist.orders orders
    left join elist.order_status order_status
        on orders.id = order_status.order_id
    group by 1)
--highlighting the 3 products with the highest count of total refunds
select product_name_clean, refunds
from refunds_cte
order by 2 desc
limit 3;

--finding aov and new customers by account_creation_method for accounts created in the first 2 months of 2022 
with account_creation_method_cte as (
  select customers.account_creation_method as account_creation_method, 
    round(avg(usd_price),2) as aov, 
    count(distinct customers.id) as new_customers
  from elist.customers customers
  join elist.orders orders 
    on customers.id = orders.customer_id
  where extract(year from customers.created_on) = 2022 and extract(month from customers.created_on) in (1,2)
  group by 1)
--aov
select account_creation_method, aov
from account_creation_method_cte
order by 2 desc;

with account_creation_method_cte as (
  select customers.account_creation_method as account_creation_method, 
    round(avg(usd_price),2) as aov, 
    count(distinct customers.id) as new_customers
  from elist.customers customers
  join elist.orders orders 
    on customers.id = orders.customer_id
  where extract(year from customers.created_on) = 2022 and extract(month from customers.created_on) in (1,2)
  group by 1)
--total new customers
select account_creation_method, new_customers
from account_creation_method_cte
order by 2 desc;

--avg amount of time between customer registration and initial purchase
--averaging the amount of days to purchase for all customers
with initial_order_cte as (
	select orders.customer_id as customer_id, min(purchase_ts) as initial_order
	from elist.orders orders
	group by 1 
)
select round(avg(date_diff(initial_order_cte.initial_order, customers.created_on, day)),2) as days_to_purchase
from elist.customers customers
join initial_order_cte
	on customers.id = initial_order_cte.customer_id

--avg time between customer registration and all orders made by customers
--averaging the amount of days to purchase for all customers
with time_to_order_cte as (
	select orders.customer_id, 
		orders.purchase_ts,
		customers.created_on,
		date_diff(orders.purchase_ts, customers.created_on, day) as days_to_purchase
	from elist.customers customers
	left join elist.orders orders
		on customers.id = orders.customer_id
		)
select round(avg(days_to_purchase),1) as avg_days_to_purchase
from time_to_order_cte

--calculating total sales, aov, and total orders per region to determine which marketing channel performs best
--ranking channels by total sales, aov, and total orders since what performs best depends on the metric you're trying to maximize for
with top_marketing_channel_cte as (
  select geo_lookup.region as region,
    customers.marketing_channel as marketing_channel, 
    round(sum(orders.usd_price),2) as total_sales,
    round(avg(orders.usd_price),2) as aov,
    count(distinct orders.id) as total_orders,
    row_number() over (partition by geo_lookup.region order by sum(orders.usd_price) desc) as total_sales_rank,
    row_number() over (partition by geo_lookup.region order by avg(orders.usd_price) desc) as aov_rank,
    row_number() over (partition by geo_lookup.region order by count(distinct orders.id) desc) as total_orders_rank,
  from elist.customers customers
  join elist.orders orders 
    on customers.id = orders.customer_id
  join elist.geo_lookup geo_lookup 
    on customers.country_code = geo_lookup.country
  group by 1, 2
  )
--finding out which marketing channel performs best in terms of total sales
--note since the top ranking is direct, which isn't a marketing channel, in this instance you're better off looking for what's ranked #2
select region, marketing_channel, total_sales 
from top_marketing_channel_cte
where total_sales_rank = 1
order by 3 desc;

--calculating total sales, aov, and total orders per region to determine which marketing channel performs best
--ranking channels by total sales, aov, and total orders since what performs best depends on the metric you're trying to maximize for
with top_marketing_channel_cte as (
  select geo_lookup.region as region,
    customers.marketing_channel as marketing_channel, 
    round(sum(orders.usd_price),2) as total_sales,
    round(avg(orders.usd_price),2) as aov,
    count(distinct orders.id) as total_orders,
    row_number() over (partition by geo_lookup.region order by sum(orders.usd_price) desc) as total_sales_rank,
    row_number() over (partition by geo_lookup.region order by avg(orders.usd_price) desc) as aov_rank,
    row_number() over (partition by geo_lookup.region order by count(distinct orders.id) desc) as total_orders_rank,
  from elist.customers customers
  join elist.orders orders 
    on customers.id = orders.customer_id
  join elist.geo_lookup geo_lookup 
    on customers.country_code = geo_lookup.country
  group by 1, 2
  )
--finding out which marketing channel performs best in terms of aov
select region, marketing_channel, aov 
from top_marketing_channel_cte
where aov_rank = 1
order by 3 desc;

--calculating total sales, aov, and total orders per region to determine which marketing channel performs best
--ranking channels by total sales, aov, and total orders since what performs best depends on the metric you're trying to maximize for
with top_marketing_channel_cte as (
  select geo_lookup.region as region,
    customers.marketing_channel as marketing_channel, 
    round(sum(orders.usd_price),2) as total_sales,
    round(avg(orders.usd_price),2) as aov,
    count(distinct orders.id) as total_orders,
    row_number() over (partition by geo_lookup.region order by sum(orders.usd_price) desc) as total_sales_rank,
    row_number() over (partition by geo_lookup.region order by avg(orders.usd_price) desc) as aov_rank,
    row_number() over (partition by geo_lookup.region order by count(distinct orders.id) desc) as total_orders_rank,
  from elist.customers customers
  join elist.orders orders 
    on customers.id = orders.customer_id
  join elist.geo_lookup geo_lookup 
    on customers.country_code = geo_lookup.country
  group by 1, 2
  )
--finding which marketing channel performs best in terms of total orders
--note since the top ranking is direct, which isn't a marketing channel, in this instance you're better off looking for what's ranked #2
select region, marketing_channel, total_orders  
from top_marketing_channel_cte
where total_orders_rank = 1
order by 3 desc;

--looking for customers with more than 4 purchases
with loyal_customers_cte as (
  select orders.customer_id as customer_id, 
  count(distinct orders.id) as total_orders
from elist.orders orders 
group by 1
having count(distinct orders.id) > 4
)
--to see the most recent order of loyal customers, do a join with loyal_customers_cte
--ranking their orders by most recent first
--qualify statement allows us to limit results to their most recent order
select orders.customer_id as customer_id, 
  orders.id as order_id, 
  orders.product_name as product_name, 
  date(orders.purchase_ts) as purchase_date,
  row_number()over (partition by orders.customer_id order by orders.purchase_ts desc) as rank
from elist.orders orders
join loyal_customers_cte loyal_customers
on orders.customer_id = loyal_customers.customer_id
qualify row_number()over (partition by orders.customer_id order by orders.purchase_ts desc) = 1


--creating a brand category and totalling the amount of refunds per month
--filtering to the year 2020
with highest_num_refunds_cte as (
  select case
          when lower(orders.product_name) like '%apple%' or lower(orders.product_name) like '%macbook%' then 'Apple'
          when lower(orders.product_name) like '%samsung%' then 'Samsung'
          when lower(orders.product_name) like '%thinkpad%' then 'ThinkPad'
          when lower(orders.product_name) like '%bose%' then 'Bose'
          else 'Unknown'
        end as brand,
        date_trunc(order_status.refund_ts, month) as month,
        count(order_status.refund_ts) as num_refunds
  from elist.orders orders 
  join elist.order_status order_status 
    on orders.id = order_status.order_id
  where extract(year from order_status.refund_ts) = 2020
  group by 1,2)
--getting the high month and corresponding number of refunds for each brand in 2020 
select brand, 
  month, 
  num_refunds
from highest_num_refunds_cte
qualify row_number() over (partition by brand order by num_refunds desc) = 1
order by 1
