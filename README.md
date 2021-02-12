# OSM History DB of Switzerland (osmhistorydb-ch)

## Overview
This is a project to implement a geospatial database containing the history (lineage) of OSM data objects, initiated by members of the SOSM community. 

The 'OSM History DB' being updated periodically from the original OSM database and it consists of a PostgreSQL database and software tools like ope and changesetmd and other dependencies.

There are many applications for this OSM History DB and the first one is to serve data for the '[Project of the Month Switzerland](https://wiki.openstreetmap.org/wiki/DE:Project_of_the_month_Switzerland)' application. Another application could be to make [timelapse videos](https://wiki.openstreetmap.org/wiki/Timelapse_videos) with it.


## Installation

The code written for this project is openly available on this repo - but it's currently for ourselves and not prepared to be installed elsewhere.  

For more technical info see the issues and the [Wiki](https://github.com/sosm/osmhistorydb-ch/wiki).

Dependencies (most surely incomplete :-O):
- [ope](https://github.com/osmcode/osm-postgresql-experiments/blob/master/README.md)
- [changesetmd](https://github.com/ToeBee/ChangesetMD)
- Python 3
- shell scripts 
- cron jobs
- (Debian OS)


## License

Copyright (C) 2021 (tbd.)

Those programs and scripts published in this repository are available under the [ISC license](https://en.wikipedia.org/wiki/ISC_license) (see the file LICENSE.txt). 
Existing programs and libraries have their own license which may be different from this one.


## Authors and Contact

There are many authors involved in this project and is maintained by many. Contact: @sfkeller.
