-- Exercise 12: Dimension — Date
-- Source  : stg_orders  (use {{ ref('stg_orders') }})
-- Target  : gold schema (table), tag: gold
--
-- Steps:
--   1. Build a CTE `dates` that selects DISTINCT order_date AS full_date
--      from stg_orders.
--   2. In the main SELECT, derive all calendar attributes from full_date:
--        date_key   : TO_CHAR(full_date, 'YYYYMMDD')::INTEGER  ← PK used in fact table
--        full_date  : the DATE itself
--        day        : EXTRACT(DAY   FROM full_date)::INTEGER
--        month      : EXTRACT(MONTH FROM full_date)::INTEGER
--        month_name : TO_CHAR(full_date, 'Month')
--        quarter    : EXTRACT(QUARTER FROM full_date)::INTEGER
--        year       : EXTRACT(YEAR  FROM full_date)::INTEGER
--        day_name   : TO_CHAR(full_date, 'Day')
--        day_of_week: EXTRACT(DOW   FROM full_date)::INTEGER
--        day_of_year: EXTRACT(DOY   FROM full_date)::INTEGER
--        is_weekend : CASE WHEN EXTRACT(DOW FROM full_date) IN (0,6) THEN TRUE ELSE FALSE END
--   3. ORDER BY full_date.
--
-- Grain: one row per calendar date present in the orders dataset.

{{ config(materialized='table', schema='gold', tags=['gold']) }}

WITH dates AS (
    SELECT DISTINCT order_date AS full_date
    FROM {{ ref('stg_orders') }}
)
SELECT
    TO_CHAR(full_date, 'YYYYMMDD')::INTEGER AS date_key,
    full_date,
    EXTRACT(DAY FROM full_date)::INTEGER AS day,
    EXTRACT(MONTH FROM full_date)::INTEGER AS month,
    TO_CHAR(full_date, 'Month') AS month_name,
    EXTRACT(QUARTER FROM full_date)::INTEGER AS quarter,
    EXTRACT(YEAR FROM full_date)::INTEGER AS year,
    TO_CHAR(full_date, 'Day') AS day_name,
    EXTRACT(DOW FROM full_date)::INTEGER AS day_of_week,
    EXTRACT(DOY FROM full_date)::INTEGER AS day_of_year,
    CASE WHEN EXTRACT(DOW FROM full_date) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend
FROM dates
ORDER BY full_date
