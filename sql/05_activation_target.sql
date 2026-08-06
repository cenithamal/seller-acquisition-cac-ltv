-- Purpose: Materializes the seller activation target variable (734
--          sellers) as a permanent table, rather than a view, since
--          this is a fixed training-data snapshot that should not
--          silently change if underlying tables are modified later.
-- Input: seller_channel_revenue, raw_deal
-- Output: seller_activation_labels (table) — one row per seller with
--         their activated / not activated label
-- Author: Cenith Amal | Last updated: 2026-07-30

CREATE TABLE seller_activation_labels AS
SELECT
    seller_id,
    CASE
        WHEN (min(order_purchase_timestamp)::date - won_date::date) <= 60 THEN 'activated'
        ELSE 'not activated'
    END AS activated
FROM seller_channel_revenue
GROUP BY seller_id, won_date
UNION
SELECT *
FROM (
    SELECT
        rd.seller_id,
        CASE
            WHEN ('2018-08-29'::date - rd.won_date::date) >= 60 THEN 'not activated'
            ELSE 'exclude'
        END AS activated
    FROM raw_deal rd
    LEFT JOIN seller_channel_revenue scr ON scr.seller_id = rd.seller_id
    WHERE scr.seller_id IS NULL
) AS zero_sale_sellers
WHERE activated = 'not activated';