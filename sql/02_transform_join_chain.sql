-- Purpose: Joins leads through deals, order items, and orders to attach
--          each seller's acquisition channel (origin) to their individual
--          item-level sales, producing the base table for CAC/LTV-by-channel
--          analysis in Milestone 3.
-- Input tables: raw_lead, raw_deal, raw_order_item, raw_order
-- Output: seller_channel_revenue (view) — one row per item sold, with
--         seller_id, origin, price, order_purchase_timestamp, order_id,
--         won_date, first_contact_date
-- Notes: origin = 'unknown' is kept as its own category rather than
--        filtered out (see docs/decisions_log.md)
-- Author: Cenith Amal | Last updated: 2026-07-13

CREATE OR REPLACE VIEW seller_channel_revenue AS
WITH channel_sellers AS (
    SELECT
        raw_deal.seller_id,
        raw_lead.origin,
        raw_lead.first_contact_date,
        raw_deal.won_date
    FROM raw_lead
    INNER JOIN raw_deal ON raw_deal.mql_id = raw_lead.mql_id
),
seller_sales AS (
    SELECT
        channel_sellers.seller_id,
        channel_sellers.origin,
        channel_sellers.first_contact_date,
        channel_sellers.won_date,
        raw_order_item.order_id,
        raw_order_item.price
    FROM channel_sellers
    INNER JOIN raw_order_item ON channel_sellers.seller_id = raw_order_item.seller_id
),
seller_sales_dated AS (
    SELECT
        seller_sales.seller_id,
        seller_sales.origin,
        seller_sales.first_contact_date,
        seller_sales.won_date,
        seller_sales.order_id,
        seller_sales.price,
        raw_order.order_purchase_timestamp
    FROM seller_sales
    INNER JOIN raw_order ON seller_sales.order_id = raw_order.order_id
)
SELECT
    seller_id,
    origin,
    price,
    order_purchase_timestamp,
    order_id,
    won_date,
    first_contact_date
FROM seller_sales_dated;