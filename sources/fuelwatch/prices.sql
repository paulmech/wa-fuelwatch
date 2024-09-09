SELECT
    publish_date,
    hash(address || location || postcode) identifier,
    brand_description,
    product_description,
    region_description,
    product_price
from fuelwatch