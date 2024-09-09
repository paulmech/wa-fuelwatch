install spatial;
load spatial;
with crossjoin as (
    select
     p1.postcode p1_pc,
     p2.postcode p2_pc,
    --  approximate conversion to km
     111 * st_distance(
        st_point(p1.long,p1.lat),
        st_point(p2.long,p2.lat)
     ) home_distance 
     from postcodes p1     
     cross join postcodes p2
     where p1.state='WA' and not (p1.postcode like '69%' or p2.postcode  LIKE '69%')
),
filtered as (
    select * from crossjoin
     where home_distance <= 7
)
select
    p1_pc postcode,
    array_to_string(list_distinct(array_agg(p2_pc ))[:10],',') neighbours 
    from filtered
    group by 1
    order by p1_pc;

