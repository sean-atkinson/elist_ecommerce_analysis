-- selecting all columns from the 4 elist datasets
-- cleaning product names and creating two additional columns (time to ship and time to purchase)
SELECT orders.customer_id,
  orders.id AS order_id,
  orders.purchase_ts,
  orders.product_id,
  CASE WHEN LOWER(orders.product_name) LIKE '%gaming monitor%' THEN '27in 4K Gaming Monitor'
    WHEN LOWER(orders.product_name) LIKE 'bose soundsport headphones' THEN 'Bose Soundsport Headphones'
    ELSE orders.product_name END AS product_name_clean,
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
  order_status.ship_ts,
  order_status.delivery_ts,
  order_status.refund_ts,
  DATE_DIFF(order_status.ship_ts, order_status.purchase_ts, DAY) AS time_to_ship_days,
  DATE_DIFF(order_status.purchase_ts, customers.created_on, DAY) AS time_to_purchase_days
FROM `elist-390902.elist.orders` orders 
LEFT JOIN `elist-390902.elist.customers` customers 
  ON orders.customer_id = customers.id
LEFT JOIN `elist-390902.elist.geo_lookup` geo_lookup 
  ON customers.country_code = geo_lookup.country
LEFT JOIN `elist-390902.elist.order_status` order_status 
  ON orders.id = order_status.order_id;
