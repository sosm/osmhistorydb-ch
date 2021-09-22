-- Deletes all duplicate rows. Warning: VERY time consuming.
CREATE INDEX ON nodes (id, version);
CREATE INDEX ON ways (id, version);
CREATE INDEX ON relations (id, version);

-- users
DELETE FROM users
WHERE ctid IN (
SELECT ctid FROM users
EXCEPT
SELECT DISTINCT ON (uid) ctid FROM users
);

-- nodes
DELETE FROM nodes
WHERE ctid IN (
SELECT ctid FROM nodes
EXCEPT
SELECT DISTINCT ON (id, version) ctid FROM nodes
);

-- ways
DELETE FROM ways
WHERE ctid IN (
SELECT ctid FROM ways
EXCEPT
SELECT DISTINCT ON (id, version) ctid FROM ways
);

-- relations
DELETE FROM relations
WHERE ctid IN (
SELECT ctid FROM relations
EXCEPT
SELECT DISTINCT ON (id, version) ctid FROM relations
);
