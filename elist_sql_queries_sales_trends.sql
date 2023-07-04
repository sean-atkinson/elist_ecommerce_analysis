--for each quarter, calculating main sales metrics: order count, total sales, and aov
--filtering to only north america and macbooks
--round numbers for readability
with sales_trends_cte as (
  select date_trunc(orders.purchase_ts, quarter) as purchase_quarter,
    geo_lookup.region as region,
    count(orders.id) as total_orders,
    round(sum(orders.usd_price),2) as total_sales,
    round(avg(orders.usd_price), 2) as avg_sales
  from elist.orders as orders
  join elist.customers as customers
    on orders.customer_id = customers.id
  join elist.geo_lookup as geo_lookup
    on customers.country_code = geo_lookup.country
  where region = 'NA' and lower(orders.product_name) like '%macbook%'
  group by 1,2)

---quarterly trends across all years
select round(avg(total_orders)) as avg_total_orders,
  round(avg(total_sales)) as avg_quarterly_sales,
  round(avg(avg_sales)) as avg_price
from sales_trends_cte;

--for each month, calculating main sales metrics: order count, total sales, and aov
--filtering to only north america and macbooks
--rounding numbers for readability
with sales_trends_cte as (
  select date_trunc(orders.purchase_ts, month) as purchase_quarter,
    geo_lookup.region as region,
    count(orders.id) as total_orders,
    round(sum(orders.usd_price),2) as total_sales,
    round(avg(orders.usd_price), 2) as avg_sales
  from elist.orders as orders
  join elist.customers as customers
    on orders.customer_id = customers.id
  join elist.geo_lookup as geo_lookup
    on customers.country_code = geo_lookup.country
  where region = 'NA' and lower(orders.product_name) like '%macbook%'
  group by 1,2)

---monthly trends across all years
select round(avg(total_orders)) as avg_total_orders,
  round(avg(total_sales)) as avg_quarterly_sales,
  round(avg(avg_sales)) as avg_price
from sales_trends_cte;
