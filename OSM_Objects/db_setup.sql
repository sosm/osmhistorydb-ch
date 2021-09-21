CREATE TABLE temp_nodes (
    "id" BIGINT NOT NULL, -- %COL:nodes:id%
    "version" INTEGER NOT NULL, -- %COL:nodes:version%
    "deleted" BOOLEAN NOT NULL, -- %COL:nodes:deleted%
    "changeset_id" INTEGER NOT NULL, -- %COL:nodes:changeset_id%
    "created" TIMESTAMP (0) WITHOUT TIME ZONE, -- %COL:nodes:created%
    "uid" INTEGER, -- %COL:nodes:uid%
    "tags" JSONB, -- %COL:nodes:tags%
    "geom" GEOMETRY(POINT, 4326) -- %COL:nodes:geom%
);

CREATE TABLE temp_ways (
    "id" BIGINT NOT NULL, -- %COL:ways:id%
    "version" INTEGER NOT NULL, -- %COL:ways:version%
    "deleted" BOOLEAN NOT NULL, -- %COL:ways:deleted%
    "changeset_id" INTEGER NOT NULL, -- %COL:ways:changeset_id%
    "created" TIMESTAMP (0) WITHOUT TIME ZONE, -- %COL:ways:created%
    "uid" INTEGER, -- %COL:ways:uid%
    "tags" JSONB, -- %COL:ways:tags%
    "nodes" BIGINT[] -- %COL:ways:nodes%
);

CREATE TABLE temp_relations (
    "id" BIGINT NOT NULL, -- %COL:relations:id%
    "version" INTEGER NOT NULL, -- %COL:relations:version%
    "deleted" BOOLEAN NOT NULL, -- %COL:relations:deleted%
    "changeset_id" INTEGER NOT NULL, -- %COL:relations:changeset_id%
    "created" TIMESTAMP (0) WITHOUT TIME ZONE, -- %COL:relations:created%
    "uid" INTEGER, -- %COL:relations:uid%
    "tags" JSONB, -- %COL:relations:tags%
    "members" JSONB -- %COL:relations:members%
);

CREATE TABLE temp_users (
    "uid" INTEGER, -- %COL:users:uid%
    "username" TEXT -- %COL:users:username%
);

ALTER TABLE "nodes" ADD PRIMARY KEY(id, version); -- %PK:nodes%
ALTER TABLE "relations" ADD PRIMARY KEY(id, version); -- %PK:relations%
ALTER TABLE "users" ADD PRIMARY KEY(uid); -- %PK:users%
ALTER TABLE "ways" ADD PRIMARY KEY(id, version); -- %PK:ways%

CREATE INDEX idx_nodes_id ON nodes USING btree (id);
CREATE INDEX idx_relations_id ON relations USING btree (id);
CREATE INDEX idx_ways_id ON ways USING btree (id);
CREATE INDEX node_geom_idx ON nodes USING GIST (geom);
CREATE INDEX ON nodes (created);
CREATE INDEX ON ways (created);
CREATE INDEX ON relations (created);
