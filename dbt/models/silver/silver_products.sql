-- Exercise 10: Silver model for products — adds a surrogate key
-- Source  : stg_products  (use {{ ref('stg_products') }})
-- Target  : silver schema (table), tag: silver
--
-- Steps:
--   1. Generate product_sk from product_id using the MD5 surrogate key pattern.
--   2. Pass through: product_id, product_name, category, subcategory, list_price.
--   3. Add CURRENT_TIMESTAMP AS loaded_at.

{{ config(materialized='table', schema='silver', tags=['silver']) }}

SELECT
    ABS(('x' || MD5(product_id))::BIT(32)::INT) AS product_sk,
    product_id,
    product_name,
    category,
    subcategory,
    list_price,
    CURRENT_TIMESTAMP AS loaded_at
FROM {{ ref('stg_products') }}
