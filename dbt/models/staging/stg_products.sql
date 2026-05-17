-- Exercise 8: Staging model for products
-- Source table : bronze.products
-- Destination  : silver schema (view), tag: staging
--
-- Steps:
--   1. SELECT all five columns from bronze.products.
--   2. TRIM whitespace from all text columns.
--   3. Cast list_price to NUMERIC.
--   4. Filter out rows where product_id IS NULL.
--
-- Columns to expose: product_id, product_name, category, subcategory, list_price

{{ config(materialized='view', schema='silver', tags=['staging']) }}

SELECT
    TRIM(product_id) AS product_id,
    TRIM(product_name) AS product_name,
    TRIM(category) AS category,
    TRIM(subcategory) AS subcategory,
    NULLIF(TRIM(list_price), '')::NUMERIC AS list_price
FROM bronze.products
WHERE NULLIF(TRIM(product_id), '') IS NOT NULL
