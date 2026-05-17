-- Exercise 12: Dimension — Region
-- Source  : core_regions  (use {{ ref('silver_regions') }})
-- Target  : gold schema (table), tag: gold
--
-- Steps:
--   1. Rename region_sk → region_key  (this becomes the PK in the star schema).
--   2. Pass through: region_id, region_name, country, continent.
--
-- Grain: one row per region.

{{ config(materialized='table', schema='gold', tags=['gold']) }}

SELECT
    region_sk AS region_key,
    region_id,
    region_name,
    country,
    continent
FROM {{ ref('silver_regions') }}
