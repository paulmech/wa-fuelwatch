CREATE TABLE fuelwatch AS
    SELECT * FROM read_csv(getenv('DOWNLOAD_PATH') || '/FuelWatchRetail*.csv');

CREATE TABLE postcodes AS
    SELECT * FROM read_csv(getenv('DOWNLOAD_PATH') || '/australian_postcodes.csv');
