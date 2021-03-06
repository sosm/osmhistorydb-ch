from datetime import datetime
from datetime import timedelta
import psycopg2
import argparse

class DBClipper:
    def __init__(self):
        self.boundary = None

    def deleteChangesets(self, conn):
        cur = conn.cursor()
        print("Deleting Changesets")
        cur.execute("select last_timestamp from osm_changeset_state")
        date = (cur.fetchall()[0][0] - timedelta(hours=3)).strftime("%Y-%m-%dT%H:%M:%S")
        cur.execute("delete from osm_changeset where created_at >= %s and not st_intersects(st_setsrid(osm_changeset.geom, 4326), st_setsrid(st_geomfromgeojson(%s), 4326));", (date, self.boundary,))
        cur.execute("delete FROM osm_changeset WHERE created_at >= %s and NOT EXISTS (SELECT 1 FROM nodes WHERE changeset_id = osm_changeset.id) and not exists (select 1 from ways where changeset_id = osm_changeset.id) and not exists (select 2 from relations where changeset_id = osm_changeset.id);", (date,))
        print("Deleting Changesets finished")
        conn.commit()
        cur.close()

    def get_boundary(self):
        return self.boundary

    
if __name__ == '__main__':
    beginTime = datetime.now()
    endTime = None
    timeCost = None
    
    argParser = argparse.ArgumentParser(description="Delete all Changesets outside of Switzerland")
    argParser.add_argument('-H', '--host', action='store', dest='dbHost', help='Database hostname')
    argParser.add_argument('-p' '--password', action='store', dest='dbPassword', help='Database Password')
    argParser.add_argument('-u' '--user', action='store', dest='dbUser', help='Database Username')
    argParser.add_argument('-d' '--database', action='store', dest='dbName', help='Target Database')
    argParser.add_argument('-P' '--port', action='store', dest='dbPort', help='Database Port')
    argParser.add_argument('-b' '--boundary', action='store', dest='boundary', help='Boundarys of Area to keep Data, as file', required=True)

    args = argParser.parse_args()
    conn = psycopg2.connect(dbname=args.dbName, user=args.dbUser, password=args.dbPassword, host=args.dbHost, port=args.dbPort)
    cur = conn.cursor()

    clipper = DBClipper()
    with open(args.boundary, "r") as file:
        clipper.boundary = file.read()
        print("read file")

    clipper.deleteChangesets(conn)

    # Ending
    conn.close()
    endTime = datetime.now()
    timeCost = endTime - beginTime
    print("Timecost: ", timeCost)
