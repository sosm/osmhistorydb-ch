#!/bin/bash

REPDIR="replication"
DB="osmhistory"

exec &> $REPDIR/logfile.txt
set -e


echo "Saving Changedata in $REPDIR/changes.osm.gz (using $REPDIR/sequence.state)"
pyosmium-get-changes -f $REPDIR/sequence.state -o $REPDIR/changes.osm.gz
echo "Creating Insertfiles from $REPDIR/changes.osm.gz in $REPDIR/"
ope -H -a $REPDIR/changes.osm.gz $REPDIR/nodes=n%I.v.d.c.t.i.T.x.y. $REPDIR/ways=w%I.v.d.c.t.i.T.N. $REPDIR/relations=r%I.v.d.c.t.i.T.M. $REPDIR/users=u%i.u.
echo "Writing Data to Database $DB"
psql -d $DB -f $REPDIR/nodes.sql
psql -d $DB -f $REPDIR/ways.sql
psql -d $DB -f $REPDIR/relations.sql
psql -d $DB -f $REPDIR/users.sql
echo "Starting $REPDIR/osm_pg_db_clipper.py"
python3 $REPDIR/osm_pg_db_clipper.py -d $DB -b $REPDIR/borders.geojson
echo "Deleting changefiles in $REPDIR/"
rm $REPDIR/changes.osm.gz
rm $REPDIR/ways.*
rm $REPDIR/nodes.*
rm $REPDIR/relations.*
rm $REPDIR/users.*
echo "Finished"