SELECT 
    orders.customer_id,
    orders.id AS order_id,
    -- other columns...
FROM 
    `elist-390902.elist.orders` orders 
LEFT JOIN 
    `elist-390902.elist.customers` customers 
ON
    orders.customer_id = customers.id
LEFT JOIN 
    `elist-390902.elist.geo_lookup` geo_lookup 
ON
    customers.country_code = geo_lookup.country
LEFT JOIN 
    `elist-390902.elist.order_status` order_status 
ON
    orders.id = order_status.order_id;
