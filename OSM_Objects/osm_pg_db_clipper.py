from datetime import datetime
from datetime import timedelta
import re
import subprocess
import psycopg2
import argparse

class DBClipper:
    def __init__(self, first_date):
        self.boundary = None
        self.osm_file = None
        self.first_date = first_date

    def deleteNodes(self, conn):
        cur = conn.cursor()
        print("Deleting Nodes ...")
        cur.execute("DELETE FROM nodes c WHERE created >= %s AND NOT ST_CONTAINS(ST_SetSRID(ST_GeomFromGeoJSON(%s), 4326), c.geom);", (self.first_date, self.boundary,))
        print("Deleting Nodes finished")
        conn.commit()
        cur.close()

    def deleteWays(self, conn):
        cur = conn.cursor()
        print("Deleting Ways ...")
        cur.execute("DELETE FROM ways w WHERE created >= %s AND NOT EXISTS (SELECT 1 FROM nodes WHERE id = ANY (w.nodes));", (self.first_date,))
        print("Deleting Ways finished")
        conn.commit()
        cur.close()
    
    def deleteRelations(self, conn):
        cur = conn.cursor()
        print("Deleting Relations ...")
        cur.execute("DELETE FROM relations r WHERE created >= %s AND NOT EXISTS (select 1 from nodes, jsonb_array_elements(r.members) ids WHERE id = (ids ->> 'ref') :: bigint) OR created >= %s AND NOT EXISTS (SELECT 1 FROM ways, jsonb_array_elements(r.members) ids WHERE id = (ids ->> 'ref') :: bigint);", (self.first_date, self.first_date,))
        print("Deleting Relations finished")
        conn.commit()
        cur.close()

    def get_boundary(self):
        return self.boundary

    
if __name__ == '__main__':
    beginTime = datetime.now()
    endTime = None
    timeCost = None
    
    argParser = argparse.ArgumentParser(description="work in progress")
    argParser.add_argument('-H', '--host', action='store', dest='dbHost', help='Database hostname')
    argParser.add_argument('-p' '--password', action='store', dest='dbPassword', help='Database Password')
    argParser.add_argument('-u' '--user', action='store', dest='dbUser', help='Database Username')
    argParser.add_argument('-d' '--database', action='store', dest='dbName', help='Target Database')
    argParser.add_argument('-P' '--port', action='store', dest='dbPort', help='Database Port')
    argParser.add_argument('-b' '--boundary', action='store', dest='boundary', help='Boundarys of Area to keep Data, as file', required=True)
    argParser.add_argument('-f' '--file', action='store', dest='osm_file', help='The osm File', required=True)

    args = argParser.parse_args()
    osmium_fileinfo = subprocess.run(['osmium fileinfo ' + args.osm_file + ' -e'], stdout=subprocess.PIPE, shell=True).stdout.decode('utf-8')
    first_date = re.search('First: (.+)Z.*', osmium_fileinfo).group(1)
    # rewind by three hours for safety
    first_date = datetime.strptime(first_date, "%Y-%m-%dT%H:%M:%S") - timedelta(hours=3)
    first_date = datetime.strftime(first_date, "%Y-%m-%dT%H:%M:%S")
    conn = psycopg2.connect(dbname=args.dbName, user=args.dbUser, password=args.dbPassword, host=args.dbHost, port=args.dbPort)
    cur = conn.cursor()

    clipper = DBClipper(first_date)
    with open(args.boundary, "r") as file:
        clipper.boundary = file.read()
        print("read file")

    clipper.deleteNodes(conn)
    clipper.deleteWays(conn)
    clipper.deleteRelations(conn)

    # Ending
    conn.close()
    endTime = datetime.now()
    timeCost = endTime - beginTime
    print("Timecost: ", timeCost)
