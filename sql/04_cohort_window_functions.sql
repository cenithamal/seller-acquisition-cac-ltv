-- Purpose: Calculates months-since-joining and a running revenue total
--          per seller, using window functions, to enable cohort/ramp-up
--          analysis by channel (e.g. does referral ramp up slower but
--          sustain longer than paid_search).
-- Input: seller_channel_revenue
-- Output: one row per item sold, with months_since_joining and
--         running_revenue added per seller
-- Notes: Dataset spans ~8.5 months total (Dec 2017 won_date earliest to
--        Aug 2018 latest sale), so DATE_PART('month', AGE(...)) is safe
--        to use without the 12-month rollover issue.
-- Author: Cenith Amal | Last updated: 2026-07-15

SELECT
    seller_id,
    origin,
    order_purchase_timestamp,
    price,
    DATE_PART('month', age(order_purchase_timestamp ::timestamp,  won_date::timestamp)) AS months_since_joining,
    SUM(price) OVER (
        PARTITION BY seller_id
        ORDER BY order_purchase_timestamp
    ) AS running_revenue
FROM seller_channel_revenue
ORDER BY seller_id, order_purchase_timestamp
