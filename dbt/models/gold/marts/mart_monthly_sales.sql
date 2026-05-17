{{ config(materialized='table', schema='gold', tags=['gold', 'mart']) }}

SELECT
    DATE_TRUNC('month', d.full_date)::DATE AS month_start,
    d.year,
    d.month,
    TRIM(d.month_name) AS month_name,
    SUM(f.total_amount) AS gmv,
    COUNT(DISTINCT f.sale_key) AS order_count,
    COUNT(DISTINCT f.client_key) AS customer_count,
    ROUND(SUM(f.total_amount) / NULLIF(COUNT(DISTINCT f.sale_key), 0), 2) AS average_order_value
FROM {{ ref('fact_sales') }} f
JOIN {{ ref('dim_date') }} d
    ON f.date_key = d.date_key
GROUP BY 1, 2, 3, 4
