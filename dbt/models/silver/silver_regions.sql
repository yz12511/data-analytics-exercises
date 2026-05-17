-- Exercise 9: Silver model for regions — adds a surrogate key
-- Source  : stg_regions  (use {{ ref('stg_regions') }})
-- Target  : silver schema (table), tag: silver
--
-- Steps:
--   1. Reference stg_regions with {{ ref('stg_regions') }}.
--   2. Generate a deterministic integer surrogate key from region_id using:
--        ABS(('x' || MD5(region_id))::BIT(32)::INT)  AS region_sk
--   3. Pass through all original columns: region_id, region_name, country, continent.
--   4. Add CURRENT_TIMESTAMP AS loaded_at.
--
-- Surrogate key pattern (memo):
--   ABS(('x' || MD5(<natural_key>))::BIT(32)::INT)

{{ config(materialized='table', schema='silver', tags=['silver']) }}

SELECT
    ABS(('x' || MD5(region_id))::BIT(32)::INT) AS region_sk,
    region_id,
    region_name,
    country,
    continent,
    CURRENT_TIMESTAMP AS loaded_at
FROM {{ ref('stg_regions') }}
