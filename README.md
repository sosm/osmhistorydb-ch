# OSM History DB of Switzerland (osmhistorydb-ch)

## Overview
This is a project to implement a geospatial database containing the history (lineage) of OSM data objects, initiated by members of the SOSM community. 

The 'OSM History DB' being updated periodically from the original OSM database and it consists of a PostgreSQL database and software tools like ope and changesetmd and other dependencies.

There are many applications for this OSM History DB and the first one is to serve data for the '[Project of the Month Switzerland](https://wiki.openstreetmap.org/wiki/DE:Project_of_the_month_Switzerland)' application. Another application could be to make [timelapse videos](https://wiki.openstreetmap.org/wiki/Timelapse_videos) with it.


## Installation

The code written for this project is openly available on this repo - but it's currently for ourselves and not prepared to be installed elsewhere.  

Dependencies (most surely incomplete :-O):
- [ope](https://github.com/osmcode/osm-postgresql-experiments/)
- [changesetmd](https://github.com/ToeBee/ChangesetMD)
- Python 3
- Python 2
- PostgreSQL
- shell scripts 
- cron jobs
- (Debian OS)

1. Create a Database
   1. `psql -U {user}`
   2. `CREATE DATABASE {DB};`
   3. `\c {DB}`
   4. `CREATE EXTENSION postgis;`
   5. `CREATE EXTENSION hstore;`
2. Setup ChangesetMD
   1. `apt install build-essential cmake libboost-dev libexpat1-dev zlib1g-dev libbz2-dev` or equivalent
   2. `git clone https://github.com/ToeBee/ChangesetMD`
   3. `pip2 install psycopg2 lxml bz2file pyosmium`
   4. Download [changesets](https://planet.osm.org/planet/changesets-latest.osm.bz2)
   6. `python2 changesetmd.py -d {DB} -c -f {changesets-?.osm.bz2}`
   7. `psql -U {user} -d {DB}`
   8. `\c {DB}`
   9. `update osm_changeset_state set last_sequence = {?};`
3. Setup OPE
   1. `git clone https://github.com/lbuchli/osm-postgresql-experiments`
   2. `mkdir build && cd build`
   3. `cmake ..`
   4. `make install`
4. Setup OSMHistoryDB-CH
   1. `git clone https://github.com/lbuchli/osmhistorydb-ch`
   2. `cd osm-postgresql-experiments/OSM_Objects`
   3. Download [osh](https://osm-internal.download.geofabrik.de/europe/switzerland-internal.osh.pbf)
   4. `pyosmium-get-changes -O {switzerland-internal.osh.pbf} -f sequence.state`
   5. Adjust paths in `insert_expanded.sh`
5. Initialize DB
   1. `ope -H {switzerland-internal.osh.pbf} nodes=n%I.v.d.c.t.i.T.Gp ways=w%I.v.d.c.t.i.T.N. relations=r%I.v.d.c.t.i.T.M. users=u%i.u.`
   2. `psql -U {user} -d {DB} -f users.sql`
   3. `psql -U {user} -d {DB} -f relations.sql`
   4. `psql -U {user} -d {DB} -f ways.sql`
   5. `psql -U {user} -d {DB} -f nodes.sql`
   6. `psql -U {user} -d {DB} -f osmhistorydb-ch/OSM_Objects/indexes.sql`
   7. `python3 osmhistorydb-ch/OSM_Objects/osm_pg_db_clipper.py -d {DB} -b osmhistorydb-ch/OSM_Objects/borders.geojson -f {switzerland-internal.osh.pbf}`
6. Cronjob
   1. Create cache directory: `mkdir /var/cache/osmhistory-replication`
   2. `*/10 * * * * bash cd {osmhistorydb-ch}/OSM_Objects/ && ./insert_expanded.sh` 




## License

Copyright (C) 2021 (tbd.)

Those programs and scripts published in this repository are available under the [ISC license](https://en.wikipedia.org/wiki/ISC_license) (see the file LICENSE.txt). 
Existing programs and libraries have their own license which may be different from this one.


## Authors and Contact

There are many authors involved in this project and it's maintained by many. Contact: @sfkeller.
