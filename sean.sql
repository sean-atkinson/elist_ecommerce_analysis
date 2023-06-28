--OVERALL SALES TRENDS
--start with a simple warm-up query: get order count, total, sales, and aov by quarter
select date_trunc(purchase_ts, quarter) as purchase_month,
  count(distinct id) as order_count,
  sum(usd_price) as total_sales,
  avg(usd_price) as aov
from elist.orders
group by 1
order by 1
