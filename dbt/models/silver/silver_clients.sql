-- Exercise 10: Silver model for clients — surrogate key + region join
-- Sources : stg_clients, core_regions
-- Target  : silver schema (table), tag: silver
--
-- Steps:
--   1. Reference stg_clients (aliased as c) and LEFT JOIN core_regions (aliased as r)
--      on c.region_id = r.region_id.
--   2. Generate client_sk from c.client_id using the MD5 surrogate key pattern.
--   3. Pass through: client_id, client_name, client_type, email, region_id.
--   4. Include r.region_sk (the foreign key to core_regions).
--   5. Add CURRENT_TIMESTAMP AS loaded_at.
--
-- Hint: use {{ ref('stg_clients') }} and {{ ref('silver_regions') }}

{{ config(materialized='table', schema='silver', tags=['silver']) }}

SELECT
    ABS(('x' || MD5(c.client_id))::BIT(32)::INT) AS client_sk,
    c.client_id,
    c.client_name,
    c.client_type,
    c.email,
    c.region_id,
    r.region_sk,
    CURRENT_TIMESTAMP AS loaded_at
FROM {{ ref('stg_clients') }} c
LEFT JOIN {{ ref('silver_regions') }} r
    ON c.region_id = r.region_id
