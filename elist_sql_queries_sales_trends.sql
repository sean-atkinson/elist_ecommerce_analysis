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
