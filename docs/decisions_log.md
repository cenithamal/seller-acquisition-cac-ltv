# Decisions Log — CAC/LTV Optimizer

A running record of judgment calls made during this project, logged at
the time they were made. See docs/data_dictionary.md for what the data
itself looks like; this file is about the reasoning behind the choices
made with it.

---

## 2026-07-13 — Decision: Keeping origin = 'unknown' as its own category

**Decision:** Kept 'unknown' as its own category in the channel
comparison rather than filtering those sellers out of
seller_channel_revenue.

**Why:** Filtering them out would understate total revenue and hide
part of the business. An honest 'unknown' bucket alongside the named
channels is more defensible than silently dropping real sellers.

---

## 2026-07-13 — Decision: Handling blank origin values

**Decision:** Coalesced blank/null origin values into 'unknown' at the
SQL level, so blanks and 'unknown' are treated as one category.

**Why:** Both represent the same practical situation — no identifiable
channel for that seller — so splitting them into two buckets would
fragment the same group without adding real information.

**Alternative considered:** Keeping blanks as a separate third
category, in case they indicate a different underlying issue (e.g., a
tracking failure) than an explicit 'unknown' tag. Rejected — no way to
distinguish the two causes with the data available; revisit if that
ever becomes knowable.

---

## 2026-07-13 — Decision: Column scope for seller_channel_revenue

**Decision:** Excluded most of raw_deal's columns (business_segment,
lead_type, declared_monthly_revenue, has_company, has_gtin, etc.) from
the final view, keeping only seller_id, origin, price,
order_purchase_timestamp, order_id, won_date, and first_contact_date.

**Why:** These columns don't serve the core CAC/LTV-by-channel
question. Carrying them forward "just in case" would bloat the view
without adding analytical value at this stage.

---

## 2026-07-13 — Decision: Excluding freight_value from revenue

**Decision:** Used only `price` (not `freight_value`) as the revenue
figure in seller_channel_revenue.

**Why:** Freight is a pass-through shipping cost, not revenue the
seller generated — including it would inflate the LTV numbers.

---
## 2026-07-20 — Decision: Excluding other_publicities from CAC/LTV table

**Decision:** Left other_publicities out of sql/03_metrics_cac_ltv.sql
(uses INNER JOIN throughout) rather than including it with zeros.

**Why:** other_publicities produced 65 leads but only 3 converted, and
all 3 never sold anything — zero rows in seller_channel_revenue. A
channel with no active sellers has no meaningful CAC/LTV to compare;
it's a separate funnel-dropout finding, not a data point for this table.

## 2026-07-20 — Decision: Flagged display, other, and unknown channels

**Decision:** Flagged display, other, and unknown channels as lowe confidence or unreliable channels.

**Why:** flagged display, other, and unknown as low-confidence/unreliable based on confidence intervals; only organic_search, paid_search, and referral have intervals precise enough to support a real recommendation.


## 2026-07-30 — Decision: 60-day threshold for sellers to be activated

**Decision:** Defined "activated" as a seller making at least one sale
within 60 days of their won_date.

**Why:** A reasonable window to judge early momentum without being too
strict (a few days) or too lenient (many months).


## 2026-07-30 — Decision: Exclude sellers who couldn't be observed for long enough time

**Decision:** Of 462 sellers with zero sales, excluded 108 whose
won_date was less than 60 days before the dataset's end (2018-08-29),
leaving 354 confidently labeled "not activated."

**Why:** These 108 hadn't had a full 60-day window yet — labeling them
"not activated" would have unfairly judged sellers who simply ran out
of observable time, not sellers who actually failed.

## Decision: Stopped classification modeling after 5-model comparison
[already drafted earlier — add if not yet saved]

## Decision: Organic_search vs paid_search revenue difference not significant
**Decision:** Ran Welch's t-test comparing per-seller revenue between
organic_search and paid_search. p-value = 0.627.
**Why it matters:** The apparent gap in average revenue between these
two channels is not statistically significant — reinforces the
confidence-interval caution from Milestone 3 Part 4.

## Decision: Rebuilt cohort ramp-up chart after finding a composition bias
**Decision:** Original ramp-up chart grouped sellers by "who transacted
that month," causing medians to impossibly decrease month-over-month.
Rebuilt using a fixed cohort (same sellers forward-filled across all
months) with a 4-month eligibility window.
**Why:** The original chart's sample composition shifted month to
month, making comparisons invalid. Verified the fix with two checks:
seller counts constant per channel across months, and medians never
decreasing (both passed).

## Decision: Business segment "other" grouping threshold
**Decision:** Grouped segments with fewer than 10 sellers into "other"
for descriptive analysis (not used in the earlier predictive model).
**Why:** Consistent with the sample-size discipline used throughout
the project; segments below this threshold were too thin to compare
reliably.