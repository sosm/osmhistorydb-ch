CREATE EXTENSION IF NOT EXISTS file_fdw;

CREATE SERVER IF NOT EXISTS import_changeset FOREIGN DATA WRAPPER file_fdw;

CREATE FOREIGN TABLE IF NOT EXISTS import_nodes (
    "id" BIGINT NOT NULL, -- %COL:nodes:id%
    "version" INTEGER NOT NULL, -- %COL:nodes:version%
    "deleted" BOOLEAN NOT NULL, -- %COL:nodes:deleted%
    "changeset_id" INTEGER NOT NULL, -- %COL:nodes:changeset_id%
    "created" TIMESTAMP (0) WITHOUT TIME ZONE, -- %COL:nodes:created%
    "uid" INTEGER, -- %COL:nodes:uid%
    "tags" JSONB, -- %COL:nodes:tags%
    "geom" GEOMETRY(POINT, 4326) -- %COL:nodes:geom%
) SERVER import_changeset
OPTIONS ( filename '/var/cache/osmhistory-replication/nodes.pgcopy', format 'text' );

CREATE FOREIGN TABLE IF NOT EXISTS import_ways (
    "id" BIGINT NOT NULL, -- %COL:ways:id%
    "version" INTEGER NOT NULL, -- %COL:ways:version%
    "deleted" BOOLEAN NOT NULL, -- %COL:ways:deleted%
    "changeset_id" INTEGER NOT NULL, -- %COL:ways:changeset_id%
    "created" TIMESTAMP (0) WITHOUT TIME ZONE, -- %COL:ways:created%
    "uid" INTEGER, -- %COL:ways:uid%
    "tags" JSONB, -- %COL:ways:tags%
    "nodes" BIGINT[] -- %COL:ways:nodes%
) SERVER import_changeset
OPTIONS ( filename '/var/cache/osmhistory-replication/ways.pgcopy', format 'text' );

CREATE FOREIGN TABLE IF NOT EXISTS import_relations (
    "id" BIGINT NOT NULL, -- %COL:relations:id%
    "version" INTEGER NOT NULL, -- %COL:relations:version%
    "deleted" BOOLEAN NOT NULL, -- %COL:relations:deleted%
    "changeset_id" INTEGER NOT NULL, -- %COL:relations:changeset_id%
    "created" TIMESTAMP (0) WITHOUT TIME ZONE, -- %COL:relations:created%
    "uid" INTEGER, -- %COL:relations:uid%
    "tags" JSONB, -- %COL:relations:tags%
    "members" JSONB -- %COL:relations:members%
) SERVER import_changeset
OPTIONS ( filename '/var/cache/osmhistory-replication/relations.pgcopy', format 'text' );

CREATE FOREIGN TABLE IF NOT EXISTS import_users (
    "uid" INTEGER, -- %COL:users:uid%
    "username" TEXT -- %COL:users:username%
) SERVER import_changeset
OPTIONS ( filename '/var/cache/osmhistory-replication/users.pgcopy', format 'text' );

INSERT INTO nodes (SELECT * FROM import_nodes) ON CONFLICT DO NOTHING;
INSERT INTO ways (SELECT * FROM import_ways) ON CONFLICT DO NOTHING;
INSERT INTO relations (SELECT * FROM import_relations) ON CONFLICT DO NOTHING;
INSERT INTO users (SELECT * FROM import_users) ON CONFLICT (uid) DO UPDATE SET username = EXCLUDED.username;
