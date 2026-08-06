-- Purpose: Combines the activation target (Step 1) with early-signal
--          features (Step 2) for model training — origin, business_type,
--          lead_type, and days_to_convert (first_contact_date to won_date).
-- Input: seller_activation_labels, raw_deal, raw_lead
-- Output: one row per seller, feature columns + activated label,
--         excluding rows with missing business_type/lead_type/origin
--         and rows with a negative days_to_convert (data-quality issue —
--         won_date before first_contact_date, logically invalid)
-- Author: Cenith Amal | Last updated: 2026-07-30

SELECT
    sal.seller_id,
    sal.activated,
    rd.won_date,
    rl.first_contact_date,
    rd.business_type,
    rd.lead_type,
    rl.origin,
    rd.won_date::date - rl.first_contact_date::date AS days_to_convert
FROM seller_activation_labels sal
JOIN raw_deal rd ON rd.seller_id = sal.seller_id
JOIN raw_lead rl ON rl.mql_id = rd.mql_id
WHERE rd.business_type IS NOT NULL
    AND rd.lead_type IS NOT NULL
    AND rl.origin IS NOT NULL
    AND (rd.won_date::date - rl.first_contact_date::date) >= 0