-- Exercise 12: Dimension — Product
-- Source  : core_products  (use {{ ref('silver_products') }})
-- Target  : gold schema (table), tag: gold
--
-- Steps:
--   1. Rename product_sk → product_key.
--   2. Pass through: product_id, product_name, category, subcategory, list_price.
--
-- Grain: one row per product.

{{ config(materialized='table', schema='gold', tags=['gold']) }}

SELECT
    product_sk AS product_key,
    product_id,
    product_name,
    category,
    subcategory,
    list_price
FROM {{ ref('silver_products') }}
