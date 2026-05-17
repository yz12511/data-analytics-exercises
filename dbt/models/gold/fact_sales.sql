-- Exercise 13: Fact table — Sales
-- Source  : core_orders  (use {{ ref('silver_orders') }})
-- Target  : gold schema (table), tag: gold
--
-- The fact table is a thin projection of core_orders — just rename surrogate keys
-- to *_key names and keep the measures.
--
-- Steps:
--   1. Rename order_sk   → sale_key   (degenerate dimension / PK)
--   2. Pass through date_key           (FK to dim_date)
--   3. Rename client_sk  → client_key  (FK to dim_client)
--   4. Rename product_sk → product_key (FK to dim_product)
--   5. Rename region_sk  → region_key  (FK to dim_region)
--   6. Pass through measures: quantity, unit_price, discount_pct, total_amount
--
-- Grain: one row per order line.

{{ config(materialized='table', schema='gold', tags=['gold']) }}

SELECT
    order_sk AS sale_key,
    date_key,
    client_sk AS client_key,
    product_sk AS product_key,
    region_sk AS region_key,
    quantity,
    unit_price,
    discount_pct,
    total_amount
FROM {{ ref('silver_orders') }}
