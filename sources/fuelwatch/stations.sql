with uniqueish as (
    select
        trading_name,
        brand_description,
        address,
        location,
        postcode,
        area_description,
        region_description,
        cast(hash(address || location || postcode) as varchar) identifier,
        min(publish_date) valid_from,
        arbitrary(publish_date) publish_date
    from fuelwatch
    group by 1,2,3,4,5,6,7
)

select
*,
LEAD(publish_date) over(partition by identifier ORDER BY publish_date) valid_to
from uniqueish