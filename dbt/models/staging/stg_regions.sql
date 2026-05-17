-- Exercise 7: Staging model for regions
-- Source table : bronze.regions
-- Destination  : silver schema (view), tag: staging
--
-- Steps:
--   1. SELECT all four columns from bronze.regions.
--   2. TRIM whitespace from every text column.
--   3. Filter out rows where region_id IS NULL.
--
-- Columns to expose: region_id, region_name, country, continent

{{ config(materialized='view', schema='silver', tags=['staging']) }}

SELECT
    TRIM(region_id) AS region_id,
    TRIM(region_name) AS region_name,
    TRIM(country) AS country,
    TRIM(continent) AS continent
FROM bronze.regions
WHERE NULLIF(TRIM(region_id), '') IS NOT NULL
