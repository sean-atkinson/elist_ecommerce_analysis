--selecting all columns from the 4 elist datsets
--cleaning product names and creating two additional columns (time to ship and time to purchase)
select orders.customer_id,
  orders.id as order_id,
  orders.purchase_ts,
  orders.product_id,
  case when lower(orders.product_name) like '%gaming monitor%' then '27in 4K Gaming Monitor'
    when lower(orders.product_name) like 'bose soundsport headphones' then 'Bose Soundsport Headphones'
    else orders.product_name end as product_name_clean,
  orders.currency,
  orders.local_price,
  orders.usd_price,
  orders.purchase_platform,
  customers.marketing_channel,
  customers.account_creation_method,
  customers.country_code,
  customers.loyalty_program,
  customers.created_on,
  geo_lookup.region,
  order_status.purchase_ts,
  order_status.ship_ts,
  order_status.delivery_ts,
  order_status.refund_ts,
  date_diff(order_status.ship_ts, order_status.purchase_ts, day) as time_to_ship_days,
  date_diff(order_status.purchase_ts, customers.created_on, day) as time_to_purchase_days
from `elist-390902.elist.orders` orders 
left join `elist-390902.elist.customers` customers 
  on orders.customer_id = customers.id
left join `elist-390902.elist.geo_lookup` geo_lookup 
  on customers.country_code = geo_lookup.country
left join `elist-390902.elist.order_status` order_status 
  on orders.id = order_status.order_id
