#!/bin/bash

# insert.sh, but the updating process of the changesets is also included,
# that only one entry in cronjobs is necessary. REPDIR has to be created and
# sequence.state added in it. ope and changesetmd.py must either be added to the
# path variable or the path must be added here.

REPDIR="/var/cache/osmhistory-replication" # postgresql has private tmp enabled and thus cannot read from our tmp.
CHANGESETMD="/home/lukas/workspace/ChangesetMD/changesetmd.py"
DB="osmhistory"

exec &> insert_logs.txt
set -e

changesets() {
    echo "Save new Changesets into Database"
    python2 $CHANGESETMD -d $DB -r -g
    echo "Deleting Changesets outside Switzerland"
    python3 osm_changeset_deleter.py -d $DB -b borders.geojson
}

osm_objects() {
    echo "Saving Changedata in $REPDIR/changes.osm.gz (using sequence.state)"
    pyosmium-get-changes -f sequence.state -o $REPDIR/changes.osm.gz
    echo "Creating Insertfiles from $REPDIR/changes.osm.gz in $REPDIR/"
    ope -H $REPDIR/changes.osm.gz $REPDIR/nodes=n%I.v.d.c.t.i.T.Gp $REPDIR/ways=w%I.v.d.c.t.i.T.N. $REPDIR/relations=r%I.v.d.c.t.i.T.M. $REPDIR/users=u%i.u.
    echo "Writing Data to Database $DB"
    psql -d $DB -c "\\copy \"temp_nodes\" from '$REPDIR/nodes.pgcopy'"
    psql -d $DB -c "\\copy \"temp_ways\" from '$REPDIR/ways.pgcopy'"
    psql -d $DB -c "\\copy \"temp_relations\" from '$REPDIR/relations.pgcopy'"
    psql -d $DB -c "\\copy \"temp_users\" from '$REPDIR/users.pgcopy'"
    psql -d $DB -f import.sql
    echo "Starting osm_pg_db_clipper.py"
    python3 osm_pg_db_clipper.py -d $DB -b borders.geojson -f $REPDIR/changes.osm.gz
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

