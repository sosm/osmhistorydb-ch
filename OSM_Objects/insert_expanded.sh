#!/bin/bash

# insert.sh, but the updating process of the changesets is also included,
# that only one entry in cronjobs is necessary. REPDIR has to be created and
# sequence.state added in it. ope and changesetmd.py must either be added to the
# path variable or the path must be added here.

REPDIR="replication"
DB="changesets"

mkdir -p $REPDIR
exec &> $REPDIR/insert_logs.txt
set -e

changesets() {
    echo "Save new Changesets into Database"
    python3 changesetmd.py -d $DB -r -g
    echo "Deleting Changesets outside Switzerland"
    python3 osm_changeset_deleter.py -d $DB -b $REPDIR/borders.geojson
}

osm_objects() {
    echo "Saving Changedata in $REPDIR/changes.osm.gz (using $REPDIR/sequence.state)"
    pyosmium-get-changes -f $REPDIR/sequence.state -o $REPDIR/changes.osm.gz
    echo "Creating Insertfiles from $REPDIR/changes.osm.gz in $REPDIR/"
    ope -H -a $REPDIR/changes.osm.gz $REPDIR/nodes=n%I.v.d.c.t.i.T.x.y. $REPDIR/ways=w%I.v.d.c.t.i.T.N. $REPDIR/relations=r%I.v.d.c.t.i.T.M. $REPDIR/users=u%i.u.
    echo "Editing sql Files"
    sed -i 's/DROP TABLE IF EXISTS ".*" CASCADE;//' $REPDIR/*.sql
    sed -i 's/(/IF NOT EXISTS (/' $REPDIR/*.sql
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
}

main() {
    osm_objects
    changesets
}

main
