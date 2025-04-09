---
title: All Service Stations
---

```sql regions
select * from regions
```

<Dropdown name="region" value=REGION_DESCRIPTION data={regions} title="Region">
  <DropdownOption value="" valueLabel="All regions"/>
</Dropdown>

```sql stations
select
trading_name,
brand_description,
address,
location,
 POSTCODE,
area_description,
region_description,
identifier,
'/station/' || identifier station_url
from stations
where '' = '${inputs.region.value}' OR REGION_DESCRIPTION = '${inputs.region.value}'
and valid_to is null
order by postcode
```

<DataTable search=true data={stations} rows={20} formatColumnTitles=false link=station_url>
  <Column id=TRADING_NAME/>
  <Column id=BRAND_DESCRIPTION/>
  <Column id=ADDRESS/>
  <Column id=LOCATION/>
  <Column id=POSTCODE fmt="#"/>
  <Column id=AREA_DESCRIPTION/>
  <Column id=REGION_DESCRIPTION/>
</DataTable>

```sql all_stations
select '/station/' || identifier station_url
from stations where valid_to is null
```

<div style="display:none">

<a href="/robots.txt">Robots.txt</a>

Station List

{#each all_stations as station }

<a href="{station.station_url}">{station.station_url}</a><br/>

{/each}

</div>
