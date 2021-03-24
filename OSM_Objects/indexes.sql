CREATE INDEX idx_nodes_id ON public.nodes USING btree (id);
CREATE INDEX idx_relations_id ON public.relations USING btree (id);
CREATE INDEX idx_ways_id ON public.ways USING btree (id);
CREATE INDEX node_geom_idx ON nodes USING GIST (geom);
