SELECT 
	seller_id, 
	case 
		when (min(order_purchase_timestamp)::date - won_date::date) <= 60 then 'activated'
		else 'not activated'
	end as activated
from seller_channel_revenue
group by seller_id, won_date
UNION
select *
from
(select rd.seller_id,
CASE
    WHEN ('2018-08-29'::date - rd.won_date::date) >= 60 THEN 'not activated'
    ELSE 'exclude'
END AS activated
from raw_deal rd
left join seller_channel_revenue scr 
on scr.seller_id = rd.seller_id
where scr.seller_id is NULL)
where activated = 'not activated'
