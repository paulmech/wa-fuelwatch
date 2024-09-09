---
title: By Postcode
---

```sql postcode_stations
select *,
BRAND_DESCRIPTION || ' - ' || ADDRESS || ' (' || LOCATION || ')' series_name,
'/station/' || identifier station_url

 from stations s
join wa_postcodes w
on w.locality = s.location and w.postcode=s.postcode
where s.postcode = '${params.postcode}' and valid_to is null
order by valid_from desc
```

## Postcode: {params.postcode} ({postcode_stations[0].locality})

```sql products
SELECT product_description FROM products
```

<DataTable data={postcode_stations} link=station_url>
<Column id=BRAND_DESCRIPTION/>
<Column id=TRADING_NAME/>
<Column id=series_name title="Address"/>
<Column id=REGION_DESCRIPTION/>
<Column id=SA2_NAME_2021/>
</DataTable>

## Prices

<Grid cols="2">

<ButtonGroup name="product" data={products} value=product_description>
<ButtonGroupItem default value="ULP" valueLabel="ULP"/>
</ButtonGroup>

<DateRange name=mydaterange data={postcode_stations} start='2024-01-01' defaultValue={'Last 30 Days'}/>

<ButtonGroup name="ranking" title="Average Rankings">
<ButtonGroupItem value="" valueLabel="All" default/>
<ButtonGroupItem value="top3" valueLabel="Top"/>
<ButtonGroupItem value="bottom3" valueLabel="Bottom"/>
</ButtonGroup>

<Slider name="threshold" title="Rank Threshold" defaultValue=3 min=1 max=20 size=medium/>
</Grid>

### Prices by servo

```sql prices
with filtered_prices as (
    select
        ps.identifier,
        p.publish_date,
        p.product_price,
        ps.series_name,
        RANK() OVER(partition by p.publish_date order by p.product_price) high_rank,
        RANK() OVER(partition by p.publish_date order by p.product_price desc) low_rank
    from prices p
    join ${postcode_stations} ps on ps.identifier=p.identifier
    where product_description = '${inputs.product}'
    and p.publish_date >= date '${inputs.mydaterange.start}' and p.publish_date < date '${inputs.mydaterange.end}' + interval '1' day
),
avg_rank as (
    select *,
    avg(high_rank) over (partition by series_name order by publish_date ) avg_highrank,
    avg(low_rank) over (partition by series_name order by publish_date ) avg_lowrank

    from filtered_prices
)
,identities as (
    select
        list_distinct(array_agg(identifier) filter(avg_highrank <= ${inputs.threshold}) ) high_servos,
        list_distinct(array_agg(identifier) filter(avg_lowrank <= ${inputs.threshold}) ) low_servos
    from avg_rank
)
select * from avg_rank
where '${inputs.ranking}' = ''
OR ('${inputs.ranking}' = 'top3' and list_contains((select high_servos from identities),identifier))
OR ('${inputs.ranking}' = 'bottom3' and list_contains((select low_servos from identities),identifier))
ORDER BY PUBLISH_DATE,avg_highrank
```

<LineChart data={prices} x=PUBLISH_DATE y=PRODUCT_PRICE series=series_name chartAreaHeight=350 yScale=true step=false/>

<LineChart data={prices} x=PUBLISH_DATE y=PRODUCT_PRICE series=series_name chartAreaHeight=350 yScale=true step=true/>
