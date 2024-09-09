---
title: WA Postcodes
---

```sql regions
select * from regions
```

<Dropdown name="region" value=REGION_DESCRIPTION data={regions} title="Region">
  <DropdownOption value="" valueLabel="All regions"/>
</Dropdown>

```sql postcodes
select
    postcode,
    location,
    '/postcode/' || CAST(postcode AS INT) link,
    count(*) AS station_count
from stations
WHERE valid_to IS NULL
and '' = '${inputs.region.value}' OR REGION_DESCRIPTION = '${inputs.region.value}'

GROUP BY 1,2,3
order by postcode
```

<DataTable search=true data={postcodes} rows={20} link=link>
<Column id=POSTCODE fmt="#" />
<Column id=LOCATION/>
<Column id=station_count/>
</DataTable>
