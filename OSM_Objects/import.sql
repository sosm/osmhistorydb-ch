INSERT INTO nodes (SELECT * FROM temp_nodes) ON CONFLICT DO NOTHING;
INSERT INTO ways (SELECT * FROM temp_ways) ON CONFLICT DO NOTHING;
INSERT INTO relations (SELECT * FROM temp_relations) ON CONFLICT DO NOTHING;
INSERT INTO users (SELECT * FROM temp_users) ON CONFLICT (uid) DO UPDATE SET username = EXCLUDED.username;

DELETE FROM temp_nodes;
DELETE FROM temp_ways;
DELETE FROM temp_relations;
DELETE FROM temp_users;
