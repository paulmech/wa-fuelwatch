#!/usr/bin/env bash

DBFILE=${1:-}
MIGRATION_FILE=bootstrap.sql
export DOWNLOAD_PATH=downloaded

if [ -z $DBFILE ]; then
    echo "Provide a filename to use as database output"
    exit 1
elif [ -f $DBFILE ]; then
    echo "Database already exists - $DBFILE"
    echo "Remove the file or choose a different filename"
    exit 1
fi

duckdb $DBFILE < $MIGRATION_FILE
