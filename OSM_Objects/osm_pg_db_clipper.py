from datetime import datetime
from datetime import timedelta
import psycopg2
import argparse

class DBClipper:
    def __init__(self):
        self.boundary = None

    def deleteNodes(self, conn):
        cur = conn.cursor()
        print("Deleting Nodes ...")
        cur.execute("delete FROM nodes c WHERE NOT ST_CONTAINS(ST_SetSRID(ST_GeomFromGeoJSON(\'" + clipper.boundary + "\'), 4326), ST_SetSRID(ST_MAKEPOINT(c.lon, c.lat), 4326));")
        print("Deleting Nodes finished")
        conn.commit()
        cur.close()

    def deleteWays(self, conn):
        cur = conn.cursor()
        print("Deleting Ways ...")
        # Query ist noch sehr langsam, muss optimiert werden
        cur.execute("DELETE FROM ways w WHERE NOT EXISTS (SELECT 1 FROM nodes WHERE id = ANY (w.nodes));")
        print("Deleting Ways finished")
        conn.commit()
        cur.close()
    
    def deleteRelations(self, conn):
        cur = conn.cursor()
        print("Deleting Relations ...")
        cur.execute("delete from relations r where not exists (select 1 from nodes, jsonb_array_elements(r.members) ids where id = (ids ->> 'ref') :: bigint) or not exists (select 1 from ways, jsonb_array_elements(r.members) ids where id = (ids ->> 'ref') :: bigint);")
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
    argParser.add_argument('-b' '--boundary', action='store', dest='boundary', help='Boundarys of Area to keep Data, as file')

    args = argParser.parse_args()
    conn = psycopg2.connect(dbname=args.dbName, user=args.dbUser, password=args.dbPassword, host=args.dbHost, port=args.dbPort)
    cur = conn.cursor()

    clipper = DBClipper()
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
