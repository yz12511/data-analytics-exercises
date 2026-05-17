-- Exercise 8: Staging model for orders
-- Source table : bronze.orders
-- Destination  : silver schema (view), tag: staging
--
-- Steps:
--   1. SELECT all seven columns from bronze.orders.
--   2. TRIM whitespace from text columns (order_id, client_id, product_id).
--   3. Cast order_date to DATE, quantity to INTEGER, unit_price and
--      discount_pct to NUMERIC.
--   4. Filter out rows where order_id IS NULL or order_date IS NULL.
--
-- Columns to expose:
--   order_id, order_date, client_id, product_id,
--   quantity, unit_price, discount_pct

{{ config(materialized='view', schema='silver', tags=['staging']) }}

SELECT
    TRIM(order_id) AS order_id,
    NULLIF(TRIM(order_date), '')::DATE AS order_date,
    TRIM(client_id) AS client_id,
    TRIM(product_id) AS product_id,
    NULLIF(TRIM(quantity), '')::INTEGER AS quantity,
    NULLIF(TRIM(unit_price), '')::NUMERIC AS unit_price,
    NULLIF(TRIM(discount_pct), '')::NUMERIC AS discount_pct
FROM bronze.orders
WHERE NULLIF(TRIM(order_id), '') IS NOT NULL
  AND NULLIF(TRIM(order_date), '') IS NOT NULL
