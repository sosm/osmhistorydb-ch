printf "Starting Pulling Data \n"
pyosmium-get-changes -f [path]/sequence.state -o [path]/changes.osm.gz
printf "Starting creating insert files \n"
[path]/src/ope -H -a [path]/changes.osm.gz [path]/nodes=n%I.v.d.c.t.i.T.x.y. [path]/ways=w%I.v.d.c.t.i.T.N. [path]/relations=r%I.v.d.c.t.i.T.M. [path]/users=u%i.u.
printf "Starting inserting files in Database \n"
psql -U matteo -d historydb -f [path]/nodes.sql
psql -U matteo -d historydb -f [path]/ways.sql
psql -U matteo -d historydb -f [path]/relations.sql
psql -U matteo -d historydb -f [path]/users.sql
printf "Starting Deleting Objects outside of Switzerland \n"
python3 [path]/osm_pg_db_clipper.py -u matteo -p password -d historydb -b [path]/borders.geojson
printf "Cleaning up Files \n"
rm [path]/changes.osm.gz
rm [path]/ways.*
rm [path]/nodes.*
rm [path]/relations.*
rm [path]/users.*
printf "Finished \n"
