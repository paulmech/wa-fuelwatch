select 
brand_description,
min(publish_date) valid_from,
max(publish_date) valid_to,
array_to_string(list_distinct(array_agg(region_description)),',') regions
 from fuelwatch
 group by 1