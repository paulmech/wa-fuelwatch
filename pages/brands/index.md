---
title: Brand Pricing
---

```sql brands
select
brand_description,
valid_from,
valid_to
from brands
where list_contains(string_split(regions,',') ,'${inputs.selected_region.value}')
```

```sql products
select * from products
```

```sql regions
select * from regions
```

<Grid cols="2">

<DateRange name="mydaterange" defaultValue={"Last 30 Days"}/>

<Dropdown name=selected_product data={products} title='Products'
    value=product_description order="product_description desc" defaultValue="ULP"/>

<Dropdown name=selected_brands data={brands} title='Retailer Brands' 
    selectAllByDefault=true multiple=true value=brand_description/>

<Dropdown name=selected_region data={regions} title='Region'
    value=REGION_DESCRIPTION order=REGION_DESCRIPTION defaultValue='Metro'/>
</Grid>

```sql priceplots
select
brand_description,
min(product_price) price_min,
max(product_price) price_max,
approx_quantile(product_price,0.25) price_2q,
approx_quantile(product_price,0.5) price_midpoint,
approx_quantile(product_price,0.75) price_4q
from prices
where brand_description in ${inputs.selected_brands.value}
and product_description = '${inputs.selected_product.value}'
and publish_date >= DATE '${inputs.mydaterange.start}' and publish_date < DATE '${inputs.mydaterange.end}' + INTERVAL '1' DAY
and REGION_DESCRIPTION = '${inputs.selected_region.value}'

group by brand_description
```

<BoxPlot data={priceplots}  name=BRAND_DESCRIPTION
    min=price_min max=price_max 
    intervalBottom=price_2q midpoint=price_midpoint intervalTop=price_4q 
    swapXY=true/>
