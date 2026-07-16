## View: `seller_channel_revenue`

One row per item sold, with the acquisition channel and dates attached
to the seller who sold it. Built by joining leads through deals, order
items, and orders — see sql/02_transform_join_chain.sql for the
underlying query.

| Column | Type | Description |
|---|---|---|
| `seller_id` | text | Unique identifier for the seller |
| `origin` | text | The marketing channel that produced the lead who became this seller (e.g., `paid_search`, `organic_search`, `social`, `direct_traffic`, `referral`, `email`, `other`). `'unknown'` is kept as its own category rather than filtered out — see docs/decisions_log.md. A small number of rows have a blank origin rather than `'unknown'` — flagged for follow-up, not yet resolved. |
| `price` | numeric | Sale price of one item sold by this seller |
| `order_purchase_timestamp` | timestamp | When the order containing this item was placed |
| `order_id` | text | Identifier for the order this item belongs to |
| `won_date` | date | Date the seller's deal was marked won (i.e., when they officially became a seller) |
| `first_contact_date` | date | Date the seller's original lead first made contact |

**Row-level note:** this view has one row per item sold, not one row
per seller — a seller who sold 20 items appears 20 times. Aggregation
to seller- or channel-level happens in Milestone 3's metrics queries,
not in this view.

