---
title: Servo Station
---

```sql stn
select * from stations s
join wa_postcodes w
on w.locality = s.location and w.postcode=s.postcode
where s.identifier = '${params.identifier}'
order by valid_from desc

```

# Station: {stn[0].TRADING_NAME}

| Brand Description          | Address          | Location          | Postcode          | Region                      |
| -------------------------- | ---------------- | ----------------- | ----------------- | --------------------------- |
| {stn[0].BRAND_DESCRIPTION} | {stn[0].ADDRESS} | {stn[0].LOCATION} | {stn[0].POSTCODE} | {stn[0].REGION_DESCRIPTION} |

<BigLink href="/postcode/{stn[0].POSTCODE}">View all Servos in <b>{stn[0].POSTCODE} ({stn[0].locality})</b></BigLink>

<PointMap data={stn} lat=lat long=long />

<BigLink href="/all_stations">&lt; Back to Servos</BigLink>

## Historical Prices

```sql products
select distinct PRODUCT_DESCRIPTION from prices
WHERE identifier = '${params.identifier}'
```

<Grid cols="2">
<DateRange name=mydaterange defaultValue={'Last 90 Days'}/>
<Dropdown name="selected_products" data={products} value=PRODUCT_DESCRIPTION
 multiple=true selectAllByDefault=true/>
</Grid>

```sql prices
select
*
FROM prices
WHERE publish_date >= date '${inputs.mydaterange.start}'
and publish_date < date '${inputs.mydaterange.end}'
and product_description in ${inputs.selected_products.value}
and identifier = '${params.identifier}'
order by publish_date
```

<LineChart data={prices} x=PUBLISH_DATE y=PRODUCT_PRICE series=PRODUCT_DESCRIPTION
    chartAreaHeight=350 step=true yScale=true/>

## Monthly Price Range

<Dropdown data={products} value=PRODUCT_DESCRIPTION name=monthlyproduct
defaultValue='ULP'/>

```sql agg
WITH itall AS (
SELECT
PRODUCT_DESCRIPTION,
    SUBSTRING(CAST(DATE_TRUNC('MONTH',publish_date) AS VARCHAR),1,10) publish_date,
    min(product_price) min_product_price,
    max(product_price) max_product_price,
    approx_quantile(product_price,0.25) q2_product_price,
    approx_quantile(product_price,0.5) mid_product_price,
    approx_quantile(product_price,0.75) q4_product_price
    FROM ${prices}
    WHERE product_description='${inputs.monthlyproduct.value}'
    GROUP BY 1,2
    ORDER BY 2,1
)
SELECT
*,
MIN(min_product_price) OVER () overall_min_price,
MAX(max_product_price) OVER() overall_max_price

FROM itall
```

<BoxPlot data={agg} name=publish_date series=PRODUCT_DESCRIPTION
min=min_product_price max=max_product_price
intervalBottom=q2_product_price
midpoint=mid_product_price
intervalTop=q4_product_price
xGridlines=false chartAreaHeight=350 yMin={agg[0].overall_min_price - 20}>
<ReferenceArea yMin={agg[0].overall_min_price} yMax={agg[0].overall_max_price} label='Price Range'/>
</BoxPlot>
