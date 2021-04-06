CREATE INDEX idx_nodes_id ON nodes USING btree (id);
CREATE INDEX idx_relations_id ON relations USING btree (id);
CREATE INDEX idx_ways_id ON ways USING btree (id);
CREATE INDEX node_geom_idx ON nodes USING GIST (geom);
CREATE INDEX ON nodes (created);
CREATE INDEX ON ways (created);
CREATE INDEX ON relations (created);
