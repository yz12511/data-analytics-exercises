-- Exercise 11: Silver model for orders — enriched with surrogate keys + computed fields
-- Sources : stg_orders, core_clients, core_products
-- Target  : silver schema (table), tag: silver
--
-- Steps:
--   1. Reference stg_orders (alias o), LEFT JOIN core_clients (alias c) on client_id,
--      LEFT JOIN core_products (alias p) on product_id.
--   2. Generate order_sk from o.order_id using the MD5 surrogate key pattern.
--   3. Pass through: order_id, order_date, client_id, product_id, quantity,
--      unit_price, discount_pct.
--   4. Add date_key as: TO_CHAR(o.order_date, 'YYYYMMDD')::INTEGER
--      (used as FK to dim_date in the mart).
--   5. Include c.client_sk, p.product_sk, c.region_sk (from core_clients).
--   6. Compute total_amount:
--        ROUND(quantity * unit_price * (1 - discount_pct), 2)
--   7. Add CURRENT_TIMESTAMP AS loaded_at.

{{ config(materialized='table', schema='silver', tags=['silver']) }}

SELECT
    ABS(('x' || MD5(o.order_id))::BIT(32)::INT) AS order_sk,
    o.order_id,
    o.order_date,
    o.client_id,
    o.product_id,
    o.quantity,
    o.unit_price,
    o.discount_pct,
    TO_CHAR(o.order_date, 'YYYYMMDD')::INTEGER AS date_key,
    c.client_sk,
    p.product_sk,
    c.region_sk,
    ROUND(o.quantity * o.unit_price * (1 - o.discount_pct), 2) AS total_amount,
    CURRENT_TIMESTAMP AS loaded_at
FROM {{ ref('stg_orders') }} o
LEFT JOIN {{ ref('silver_clients') }}  c ON o.client_id = c.client_id
LEFT JOIN {{ ref('silver_products') }} p ON o.product_id = p.product_id
