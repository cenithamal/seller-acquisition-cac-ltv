-- Purpose: Calculates CAC, LTV (avg revenue/seller), and LTV:CAC ratio
--          by channel, using documented cost-per-lead assumptions
--          anchored to real industry benchmarks (Google Ads ~$70 CPL,
--          scaled proportionally for other channels).
-- Input: seller_channel_revenue, channel_cost_assumptions, raw_lead
-- Output: one row per channel (9 rows) with total_sellers, total_revenue,
--         avg_revenue_per_seller, assumed_cost_per_lead, total_leads,
--         cac, and ltv_cac_ratio
-- Notes: Uses INNER JOIN throughout, so channels with zero matching
--        active sellers (e.g. other_publicities) are excluded rather
--        than shown with zeros — see docs/decisions_log.md.
--        ltv_cac_ratio is NULL for channels with $0 assumed cost
--        (division by zero is undefined, not zero).
-- Author: Cenith Amal | Last updated: 2026-07-15


CREATE TABLE channel_cost_assumptions (
    origin TEXT,
    assumed_cost_per_lead NUMERIC
);

INSERT INTO channel_cost_assumptions (origin, assumed_cost_per_lead) VALUES
    ('paid_search', 15.00),
    ('social', 8.00),
    ('display', 5.00),
    ('other_publicity', 5.00),
    ('email', 2.00),
    ('referral', 1.00),
    ('organic_search', 0.00),
    ('direct_traffic', 0.00),
    ('other', 0.00),
    ('unknown', 0.00);

UPDATE channel_cost_assumptions
SET assumed_cost_per_lead = 5.90
WHERE origin = 'social';

UPDATE channel_cost_assumptions
SET assumed_cost_per_lead = 5.35
WHERE origin = 'referral';

UPDATE channel_cost_assumptions
SET assumed_cost_per_lead = 3.20
WHERE origin = 'email';

select 
	scr.origin, 
	COUNT(DISTINCT scr.seller_id) as total_sellers, 
	SUM(scr.price) as total_revenue,
    SUM(scr.price) / COUNT(DISTINCT scr.seller_id) AS avg_revenue_per_seller,
	cca.assumed_cost_per_lead,
	leads.total_leads,
	(leads.total_leads * cca.assumed_cost_per_lead) / COUNT(DISTINCT scr.seller_id) as cac,
	SUM(scr.price) / COUNT(DISTINCT scr.seller_id)
        / NULLIF((leads.total_leads * cca.assumed_cost_per_lead) / COUNT(DISTINCT scr.seller_id), 0)
        AS ltv_cac_ratio
from seller_channel_revenue scr
JOIN channel_cost_assumptions cca
on cca.origin = scr.origin
join (
select 
COALESCE(origin, 'unknown') as origin,
count(*) as total_leads
from raw_lead
group by COALESCE(origin, 'unknown') 
) as leads on leads.origin = scr.origin 
group by scr.origin, cca.assumed_cost_per_lead,	leads.total_leads
