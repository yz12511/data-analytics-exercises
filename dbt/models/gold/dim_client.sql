-- Exercise 12: Dimension — Client
-- Source  : core_clients  (use {{ ref('silver_clients') }})
-- Target  : gold schema (table), tag: gold
--
-- Steps:
--   1. Rename client_sk → client_key.
--   2. Rename region_sk → region_key  (FK to dim_region).
--   3. Pass through: client_id, client_name, client_type, email.
--
-- Grain: one row per client.

{{ config(materialized='table', schema='gold', tags=['gold']) }}

SELECT
    client_sk AS client_key,
    client_id,
    client_name,
    client_type,
    email,
    region_sk AS region_key
FROM {{ ref('silver_clients') }}
