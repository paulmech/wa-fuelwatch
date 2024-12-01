#!/usr/bin/env bash

set -eo pipefail

DOWNLOAD_PATH=$PWD/downloaded

# postcode data
OUTPUT_POSTCODE=$DOWNLOAD_PATH/australian_postcodes.csv
if [ ! -f $OUTPUT_POSTCODE ]; then
    curl -sL https://github.com/matthewproctor/australianpostcodes/raw/master/australian_postcodes.csv -o $OUTPUT_POSTCODE
fi

# fuelwatch data
FUELWATCH_URL_BASE="https://warsydprdstafuelwatch.blob.core.windows.net/historical-reports/"
BACKFILL_MONTHS=6
if [[ "$1" != "" && "$1" =~ ^[0-9]+$ ]]; then
    BACKFILL_MONTHS=$1
fi

COUNTER=0
while true; do
    FILENAME=$(date --date "$COUNTER month ago" "+FuelWatchRetail-%m-%Y.csv")
    OUTPUT_FUELWATCH=$DOWNLOAD_PATH/$FILENAME

    if [ ! -f $OUTPUT_FUELWATCH ]; then
        curl -f -sL "${FUELWATCH_URL_BASE}${FILENAME}" -o $DOWNLOAD_PATH/$FILENAME
    fi
    let COUNTER="COUNTER + 1"
    if [ $COUNTER -gt $BACKFILL_MONTHS ]; then
        break;
    fi
done
