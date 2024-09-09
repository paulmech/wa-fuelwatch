---
title: Price Rankings - Neighbours
---

<!-- locality named postcodes -->

```sql postcodes
select
    pc.postcode,
    pc.neighbours,
    pc.postcode || ' - ' || w.locality locality
from postcode_neighbours pc
join wa_postcodes w using(postcode)
```

<!-- neighbouring postcodes -->

```sql neighbours
WITH good_neighbours AS (
    select unnest(string_split(neighbours,',')) npc
    from ${postcodes}
    where postcode = '${inputs.postcodes.value}'
),
postcodes as (
    select postcode,array_to_string(list_distinct(array_agg(locality)),',') locality
    from good_neighbours g
    join wa_postcodes w on w.postcode = g.npc
    group by 1
)
select * ,
    '/postcode/' || postcode link
    from postcodes group by 1,2
```

<!-- list of products (e.g. ULP, Diesel) -->

```sql products
SELECT product_description FROM products
```

<!-- prices -->

```sql prices
with selected_stations as (
    select
        identifier,
        arbitrary(brand_description) || ' - ' || ARBITRARY(ADDRESS) || ' (' || ARBITRARY(LOCATION) || ')'  series_name
     from ${neighbours}
     join stations using(postcode)
     where valid_to is null
     group by 1
),
filtered_prices as (
    select
        ps.identifier,
        p.publish_date,
        p.product_price,
        ps.series_name,
        RANK() OVER(partition by p.publish_date order by p.product_price) high_rank,
        RANK() OVER(partition by p.publish_date order by p.product_price desc) low_rank
    from prices p
    join selected_stations ps on ps.identifier=p.identifier
    where product_description = '${inputs.products.value}'
    and publish_date >= date '${inputs.mydaterange.start}' and publish_date < date '${inputs.mydaterange.end}' + interval '1' day
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

<Grid cols="2">

<Grid cols="1">

### Pricing Period

<DateRange name=mydaterange defaultValue={'Last 30 Days'}/>
</Grid>

<Grid cols="1">

### Home Postcode

<Dropdown name="postcodes" value="postcode" label=locality data={postcodes} defaultValue=6108 title="Postcodes"/>
</Grid>

</Grid>
<!-- end of set pricing period and home postcode -->
<!-- no grids open -->

<!-- start of thresholds and neighbours -->
<Grid cols="2">

<!-- start of thresholds -->

<Grid cols="2">

<Grid cols="1">

### Ranking Level

<Slider min=1 max=12 name=threshold defaultValue=3 title="Ranking Threshold"/>
</Grid>

<Grid cols="1">

### Fuel Product

<Dropdown title='Product' name="products" data={products} value=PRODUCT_DESCRIPTION defaultValue=ULP order="PRODUCT_DESCRIPTION DESC"/>
</Grid>

<Grid cols="1">

### Show Rankings

<ButtonGroup name="ranking">
<ButtonGroupItem value="" valueLabel="Off" default/>
<ButtonGroupItem value="top3" valueLabel="Top"/>
<ButtonGroupItem value="bottom3" valueLabel="Bottom"/>
</ButtonGroup>
</Grid>
</Grid>

<!-- end of thresholds -->

<!-- start of neighbours -->

<Grid cols="1">

### Surrounding Postcodes

<DataTable data={neighbours} rows=12 link=link/>
</Grid>

<!-- end of thresholds and heighbours -->
</Grid>

> The following chart shows price movement for either all, high ranked or low ranked service stations

<LineChart data={prices} x=PUBLISH_DATE y=PRODUCT_PRICE series=series_name chartAreaHeight=350 yScale=true step=true/>

```sql agg_prices
with selected_stations as (
    select
        identifier,
        arbitrary(brand_description) || ' - ' || ARBITRARY(ADDRESS) || ' (' || ARBITRARY(LOCATION) || ')'  series_name
     from ${neighbours}
     join stations using(postcode)
     where valid_to is null
     group by 1
),
filtered_prices as (
    select
        p.publish_date,
        p.product_price,
        ps.series_name
    from prices p
    join selected_stations ps on ps.identifier=p.identifier
    where product_description = '${inputs.products.value}'
),
agged as (
    select
        series_name servo,
        min(product_price) pp_min,
        max(product_price) pp_max,
        approx_quantile(product_price,0.5) pp_midpoint,
        approx_quantile(product_price,0.25) pp_2q,
        approx_quantile(product_price,0.75) pp_4q
        from filtered_prices
        group by series_name
)
select * from agged order by servo
```

> The following box and whiskers chart shows the price distribution of neighbouring stations. A small box indicates less price fluctuation in the cycle

<BoxPlot data={agg_prices}  name=servo
    min=pp_min max=pp_max 
    intervalBottom=pp_2q midpoint=pp_midpoint intervalTop=pp_4q 
    swapXY=true xGridlines=false/>
