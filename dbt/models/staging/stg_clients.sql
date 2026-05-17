-- Exercise 7: Staging model for clients
-- Source table : bronze.clients
-- Destination  : silver schema (view), tag: staging
--
-- Steps:
--   1. SELECT all five columns from bronze.clients.
--   2. TRIM whitespace from every text column.
--   3. Additionally LOWER() the email column.
--   4. Filter out rows where client_id IS NULL.
--
-- Columns to expose: client_id, client_name, client_type, region_id, email

{{ config(materialized='view', schema='silver', tags=['staging']) }}

SELECT
    TRIM(client_id) AS client_id,
    TRIM(client_name) AS client_name,
    TRIM(client_type) AS client_type,
    TRIM(region_id) AS region_id,
    LOWER(TRIM(email)) AS email
FROM bronze.clients
WHERE NULLIF(TRIM(client_id), '') IS NOT NULL
