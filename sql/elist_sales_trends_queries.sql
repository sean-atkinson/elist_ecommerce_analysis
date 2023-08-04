-- For each month, calculating main sales metrics: order count, total sales, and aov
-- Filtering to only North America and MacBooks
-- Rounding numbers for readability
WITH sales_trends_monthly_cte AS (
    SELECT 
        DATE_TRUNC(orders.purchase_ts, MONTH) AS purchase_month,
        COUNT(orders.id) AS total_orders,
        ROUND(SUM(orders.usd_price),2) AS total_sales,
        ROUND(AVG(orders.usd_price), 2) AS avg_sales
    FROM 
        elist.orders AS orders
    JOIN 
        elist.customers AS customers ON orders.customer_id = customers.id
    JOIN 
        elist.geo_lookup AS geo_lookup ON customers.country_code = geo_lookup.country
    WHERE 
        geo_lookup.region = 'NA' AND LOWER(orders.product_name) LIKE '%macbook%'
    GROUP BY 
        1
)
SELECT 
    ROUND(AVG(total_orders)) AS avg_total_orders,
    ROUND(AVG(total_sales)) AS avg_monthly_sales,
    ROUND(AVG(avg_sales)) AS avg_price
FROM 
    sales_trends_monthly_cte;

-- For each quarter, calculating main sales metrics: order count, total sales, and aov
-- Filtering to only North America and MacBooks
-- Rounding numbers for readability
WITH sales_trends_quarterly_cte AS (
    SELECT 
        DATE_TRUNC(orders.purchase_ts, QUARTER) AS purchase_quarter,
        COUNT(orders.id) AS total_orders,
        ROUND(SUM(orders.usd_price),2) AS total_sales,
        ROUND(AVG(orders.usd_price), 2) AS avg_sales
    FROM 
        elist.orders AS orders
    JOIN 
        elist.customers AS customers ON orders.customer_id = customers.id
    JOIN 
        elist.geo_lookup AS geo_lookup ON customers.country_code = geo_lookup.country
    WHERE 
        geo_lookup.region = 'NA' AND LOWER(orders.product_name) LIKE '%macbook%'
    GROUP BY 
        1
)
SELECT 
    ROUND(AVG(total_orders)) AS avg_total_orders,
    ROUND(AVG(total_sales)) AS avg_quarterly_sales,
    ROUND(AVG(avg_sales)) AS avg_price
FROM 
    sales_trends_quarterly_cte;

-- Counting the number of refunds per month (non-null values in refund_ts represent refunds)
-- Calculating the refund rate
WITH monthly_refunds_cte AS (
    SELECT 
        DATE_TRUNC(purchase_ts, MONTH) AS month,
        SUM(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END) AS refunds,
        SUM(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END) / COUNT(DISTINCT order_id) AS refund_rate
    FROM 
        elist.order_status 
    WHERE 
        EXTRACT(YEAR FROM purchase_ts) = 2020
    GROUP BY 
        1
    ORDER BY 
        1
)
SELECT 
    ROUND(AVG(refund_rate),3) AS monthly_refunds
FROM 
    monthly_refunds_cte;

-- Calculating the number of refunds per month (non-null values in refund_ts represent refunds)
-- Filtering for 2021 and Apple products
SELECT 
    DATE_TRUNC(order_status.refund_ts, MONTH) AS month,
    COUNT(order_status.refund_ts) AS refunds
FROM 
    elist.order_status AS order_status
JOIN 
    elist.orders AS orders ON order_status.order_id = orders.id
WHERE 
    EXTRACT(YEAR FROM order_status.refund_ts) = 2021 AND (LOWER(orders.product_name) LIKE '%apple%' OR LOWER(orders.product_name) LIKE '%macbook%')
GROUP BY 
    1
ORDER BY 
    1;

-- Cleaning up product names
-- Calculating refund rates for each product
WITH refunds_cte AS (
    SELECT 
        CASE 
            WHEN product_name ='27in"" 4k gaming monitor' THEN '27in 4K gaming monitor' 
            ELSE product_name 
        END AS product_name_clean,
        COUNT(order_status.refund_ts) AS refunds,
        ROUND(COUNT(order_status.refund_ts) / COUNT(DISTINCT orders.id), 3) AS refund_rate
    FROM 
        elist.orders AS orders
    LEFT JOIN 
        elist.order_status AS order_status ON orders.id = order_status.order_id
    GROUP BY 
        1
)
-- Highlighting the 3 products with the highest refund rate
SELECT 
    product_name_clean, 
    refund_rate
FROM 
    refunds_cte
ORDER BY 
    3 DESC
LIMIT 
    3;

-- Cleaning up product names
-- Calculating refund rates for each product
WITH refunds_cte AS (
    SELECT 
        CASE 
            WHEN product_name ='27in"" 4k gaming monitor' THEN '27in 4K gaming monitor' 
            ELSE product_name 
        END AS product_name_clean,
        COUNT(order_status.refund_ts) AS refunds,
        ROUND(COUNT(order_status.refund_ts) / COUNT(DISTINCT orders.id), 3) AS refund_rate
    FROM 
        elist.orders AS orders
    LEFT JOIN 
        elist.order_status AS order_status ON orders.id = order_status.order_id
    GROUP BY 
        1
)
-- Highlighting the 3 products with the highest count of total refunds
SELECT 
    product_name_clean, 
    refunds
FROM 
    refunds_cte
ORDER BY 
    2 DESC
LIMIT 
    3;

-- Finding AOV and new customers by account_creation_method for accounts created in the first 2 months of 2022 
WITH account_creation_method_cte AS (
    SELECT 
        customers.account_creation_method AS account_creation_method, 
        ROUND(AVG(usd_price), 2) AS aov, 
        COUNT(DISTINCT customers.id) AS new_customers
    FROM 
        elist.customers customers
    JOIN 
        elist.orders orders ON customers.id = orders.customer_id
    WHERE 
        EXTRACT(YEAR FROM customers.created_on) = 2022 AND EXTRACT(MONTH FROM customers.created_on) IN (1, 2)
    GROUP BY 
        1
)
-- Comparing AOV for each account creation method
SELECT 
    account_creation_method, 
    aov
FROM 
    account_creation_method_cte
ORDER BY 
    2 DESC;

-- Finding AOV and new customers by account_creation_method for accounts created in the first 2 months of 2022 
WITH account_creation_method_cte AS (
    SELECT 
        customers.account_creation_method AS account_creation_method, 
        ROUND(AVG(usd_price), 2) AS aov, 
        COUNT(DISTINCT customers.id) AS new_customers
    FROM 
        elist.customers customers
    JOIN 
        elist.orders orders ON customers.id = orders.customer_id
    WHERE 
        EXTRACT(YEAR FROM customers.created_on) = 2022 AND EXTRACT(MONTH FROM customers.created_on) IN (1, 2)
    GROUP BY 
        1
)
-- Comparing total new customers for each account creation method
SELECT 
    account_creation_method, 
    new_customers
FROM 
    account_creation_method_cte
ORDER BY 
    new_customers DESC;

-- Avg amount of time between customer registration and initial purchase
-- Averaging the amount of days to purchase for all customers
WITH initial_order_cte AS (
    SELECT 
        orders.customer_id AS customer_id, 
        MIN(purchase_ts) AS initial_order
    FROM 
        elist.orders orders
    GROUP BY 
        1 
)
SELECT 
    ROUND(AVG(DATE_DIFF(initial_order_cte.initial_order, customers.created_on, DAY)), 2) AS days_to_purchase
FROM 
    elist.customers customers
JOIN 
    initial_order_cte ON customers.id = initial_order_cte.customer_id;

-- Avg time between customer registration and all orders made by customers
-- Averaging the amount of days to purchase for all customers
WITH time_to_order_cte AS (
    SELECT 
        orders.customer_id, 
        orders.purchase_ts,
        customers.created_on,
        DATE_DIFF(orders.purchase_ts, customers.created_on, DAY) AS days_to_purchase
    FROM 
        elist.customers customers
    LEFT JOIN 
        elist.orders orders ON customers.id = orders.customer_id
)
SELECT 
    ROUND(AVG(days_to_purchase), 1) AS avg_days_to_purchase
FROM 
    time_to_order_cte;

-- Calculating total sales, AOV, and total orders per region to determine which marketing channel performs best
-- Ranking channels by total sales, AOV, and total orders since what performs best depends on the metric you're trying to maximize for
WITH top_marketing_channel_cte AS (
    SELECT 
        geo_lookup.region as region,
        customers.marketing_channel as marketing_channel, 
        SUM(orders.usd_price) as total_sales,
        AVG(orders.usd_price) as aov,
        COUNT(DISTINCT orders.id) as total_orders,
        ROW_NUMBER() OVER (PARTITION BY geo_lookup.region ORDER BY SUM(orders.usd_price) DESC) as total_sales_rank,
        ROW_NUMBER() OVER (PARTITION BY geo_lookup.region ORDER BY AVG(orders.usd_price) DESC) as aov_rank,
        ROW_NUMBER() OVER (PARTITION BY geo_lookup.region ORDER BY COUNT(DISTINCT orders.id) DESC) as total_orders_rank
    FROM 
        elist.customers customers
    JOIN 
        elist.orders orders ON customers.id = orders.customer_id
    JOIN 
        elist.geo_lookup geo_lookup ON customers.country_code = geo_lookup.country
    GROUP BY 
        1, 2
)
-- Finding out which marketing channel performs best in terms of total sales
-- Note since the top ranking is direct, which isn't a marketing channel, in this instance you're better off looking for what's ranked #2
SELECT 
    region,
    marketing_channel,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(aov, 2) AS aov,
    total_orders
FROM 
    top_marketing_channel_cte
WHERE 
    total_sales_rank = 1
ORDER BY 
    3 DESC;

-- Calculating total sales, AOV, and total orders per region to determine which marketing channel performs best
-- Ranking channels by total sales, AOV, and total orders since what performs best depends on the metric you're trying to maximize for
WITH top_marketing_channel_cte AS (
    SELECT
        geo_lookup.region AS region,
        customers.marketing_channel AS marketing_channel, 
        ROUND(SUM(orders.usd_price), 2) AS total_sales,
        ROUND(AVG(orders.usd_price), 2) AS aov,
        COUNT(DISTINCT orders.id) AS total_orders,
        ROW_NUMBER() OVER (PARTITION BY geo_lookup.region ORDER BY SUM(orders.usd_price) DESC) AS total_sales_rank,
        ROW_NUMBER() OVER (PARTITION BY geo_lookup.region ORDER BY AVG(orders.usd_price) DESC) AS aov_rank,
        ROW_NUMBER() OVER (PARTITION BY geo_lookup.region ORDER BY COUNT(DISTINCT orders.id) DESC) AS total_orders_rank
    FROM 
        elist.customers customers
    JOIN 
        elist.orders orders ON customers.id = orders.customer_id
    JOIN 
        elist.geo_lookup geo_lookup ON customers.country_code = geo_lookup.country
    GROUP BY 
        1, 2
)
-- Finding out which marketing channel performs best in terms of AOV
SELECT 
    region, 
    marketing_channel, 
    aov 
FROM 
    top_marketing_channel_cte
WHERE 
    aov_rank = 1
ORDER BY 
    3 DESC;

-- Calculating total sales, AOV, and total orders per region to determine which marketing channel performs best
-- Ranking channels by total sales, AOV, and total orders since what performs best depends on the metric you're trying to maximize for
WITH top_marketing_channel_cte AS (
    SELECT
        geo_lookup.region AS region,
        customers.marketing_channel AS marketing_channel, 
        ROUND(SUM(orders.usd_price), 2) AS total_sales,
        ROUND(AVG(orders.usd_price), 2) AS aov,
        COUNT(DISTINCT orders.id) AS total_orders,
        ROW_NUMBER() OVER (PARTITION BY geo_lookup.region ORDER BY SUM(orders.usd_price) DESC) AS total_sales_rank,
        ROW_NUMBER() OVER (PARTITION BY geo_lookup.region ORDER BY AVG(orders.usd_price) DESC) AS aov_rank,
        ROW_NUMBER() OVER (PARTITION BY geo_lookup.region ORDER BY COUNT(DISTINCT orders.id) DESC) AS total_orders_rank
    FROM 
        elist.customers customers
    JOIN 
        elist.orders orders ON customers.id = orders.customer_id
    JOIN 
        elist.geo_lookup geo_lookup ON customers.country_code = geo_lookup.country
    GROUP BY 
        1, 2
)
-- Finding which marketing channel performs best in terms of total orders
-- Note since the top ranking is direct, which isn't a marketing channel, in this instance you're better off looking for what's ranked #2
SELECT 
    region, 
    marketing_channel, 
    total_orders  
FROM 
    top_marketing_channel_cte
WHERE 
    total_orders_rank = 1
ORDER BY 
    3 DESC;

-- Looking for customers with more than 4 purchases
WITH loyal_customers_cte AS (
    SELECT
        orders.customer_id AS customer_id, 
        COUNT(DISTINCT orders.id) AS total_orders
    FROM 
        elist.orders orders 
    GROUP BY 
        1
    HAVING 
        COUNT(DISTINCT orders.id) > 4
)
-- To see the most recent order of loyal customers, doing a join with loyal_customers_cte
SELECT
    orders.customer_id AS customer_id, 
    orders.id AS order_id, 
    orders.product_name AS product_name, 
    DATE(orders.purchase_ts) AS purchase_date,
    ROW_NUMBER() OVER (PARTITION BY orders.customer_id ORDER BY orders.purchase_ts DESC) AS rank
FROM 
    elist.orders orders
JOIN 
    loyal_customers_cte loyal_customers ON orders.customer_id = loyal_customers.customer_id
WHERE 
    rank = 1;

-- Creating a brand category and totaling the amount of refunds per month
-- Filtering to the year 2020
WITH highest_num_refunds_cte AS (
    SELECT
        CASE
            WHEN LOWER(orders.product_name) LIKE '%apple%' OR LOWER(orders.product_name) LIKE '%macbook%' THEN 'Apple'
            WHEN LOWER(orders.product_name) LIKE '%samsung%' THEN 'Samsung'
            WHEN LOWER(orders.product_name) LIKE '%thinkpad%' THEN 'ThinkPad'
            WHEN LOWER(orders.product_name) LIKE '%bose%' THEN 'Bose'
            ELSE 'Unknown'
        END AS brand,
        DATE_TRUNC(order_status.refund_ts, MONTH) AS month,
        COUNT(order_status.refund_ts) AS num_refunds
    FROM 
        elist.orders orders 
    JOIN 
        elist.order_status order_status ON orders.id = order_status.order_id
    WHERE 
        EXTRACT(YEAR FROM order_status.refund_ts) = 2020
    GROUP BY 
        1, 2
)
-- Getting the highest month and corresponding number of refunds for each brand in 2020 
SELECT
    brand, 
    month, 
    num_refunds
FROM 
    highest_num_refunds_cte
QUALIFY 
    ROW_NUMBER() OVER (PARTITION BY brand ORDER BY num_refunds DESC) = 1
ORDER BY 
    1;
