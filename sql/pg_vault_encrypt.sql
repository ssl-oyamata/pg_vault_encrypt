-- SELECT encrypt('宇宙人になりたい');
SELECT decrypt(encrypt('宇宙人になりたい'));

-- SELECT encrypt('I want to be an alien');
SELECT decrypt(encrypt('I want to be an alien'));

DROP TABLE IF EXISTS test;
CREATE TABLE test(id int , data cipher);
INSERT INTO test values(1, 'jp');
INSERT INTO test values(2, '宇宙人になりたい');
INSERT INTO test values(3, 'I want to be an alien');
INSERT INTO test values(4, 'I want to be a alien2'::text);
INSERT INTO test values(5, 'I want to be a alien3'::varchar);
INSERT INTO test values(6, 'I want to be a alien4'::char(32));

SELECT * FROM test;

SELECT * FROM test where data = '宇宙人になりたい';
SELECT * FROM test where data LIKE '宇宙人%';
SELECT * FROM test where data LIKE '%になりたい';
SELECT * FROM test where data LIKE '%宇宙人%'::varchar;
SELECT * FROM test where data LIKE '%宇宙まん%';
SELECT * FROM test where data = 'I want to be a alien4'::char(32);

--　INSERT and UPDATE,DELETE (1,000 records)
TRUNCATE test;
INSERT INTO test SELECT i, 'data' || i::text FROM generate_series(1, 1000) AS i;
SELECT * FROM test WHERE data = 'data999';
UPDATE test SET data = 'updatedata999' WHERE data = 'data999';
SELECT * FROM test WHERE data = 'data999';
SELECT * FROM test WHERE data = 'updatedata999';
DELETE FROM test WHERE data = 'updatedata999';
SELECT * FROM test WHERE data = 'updatedata999';

-- INSERT 1MB,2MB,4MB,8MB,16MB,32MB data
TRUNCATE test;
-- 1MB
INSERT INTO test
SELECT  1, string_agg(str, '') FROM
  (SELECT i, md5(i::text) AS str FROM generate_series(1, 1024 * 1024 /32), generate_series(1, 1) AS i) AS t
GROUP BY i;
-- 2MB
INSERT INTO test
SELECT  2, string_agg(str, '') FROM
  (SELECT i, md5(i::text) AS str FROM generate_series(1, 1024 * 1024 * 2 /32), generate_series(1, 1) AS i) AS t
GROUP BY i;
--- 4MB
INSERT INTO test
SELECT  4, string_agg(str, '') FROM
  (SELECT i, md5(i::text) AS str FROM generate_series(1, 1024 * 1024 * 4 /32), generate_series(1, 1) AS i) AS t
GROUP BY i;
--- 8MB
INSERT INTO test
SELECT  8, string_agg(str, '') FROM
  (SELECT i, md5(i::text) AS str FROM generate_series(1, 1024 * 1024 * 8 /32), generate_series(1, 1) AS i) AS t
GROUP BY i;
--- 16MB
INSERT INTO test
SELECT  16, string_agg(str, '') FROM
  (SELECT i, md5(i::text) AS str FROM generate_series(1, 1024 * 1024 * 16 /32), generate_series(1, 1) AS i) AS t
GROUP BY i;
--- 32MB
INSERT INTO test
SELECT  32, string_agg(str, '') FROM
  (SELECT i, md5(i::text) AS str FROM generate_series(1, 1024 * 1024 * 32 /32), generate_series(1, 1) AS i) AS t
GROUP BY i;
SELECT octet_length(data) FROM test;

-- Configuration error
SET pg_vault_encrypt.vault_token = "not key";
INSERT INTO test values(99, 'test');
SELECT * FROM test;
SET pg_vault_encrypt.vault_token TO DEFAULT ;

SET pg_vault_encrypt.vault_addr = "http://192.168.0.40:8080";
INSERT INTO test values(99, 'test');
SELECT * FROM test;
SET pg_vault_encrypt.vault_addr TO DEFAULT ;

SET pg_vault_encrypt.vault_transit_engine_path = "dummy";
INSERT INTO test values(99, 'test');
SELECT * FROM test;
SET pg_vault_encrypt.vault_transit_engine_path TO DEFAULT ;

SET pg_vault_encrypt.vault_transit_key_name = "dummy";
INSERT INTO test values(99, 'test');
SELECT * FROM test;
SET pg_vault_encrypt.vault_transit_key_name TO DEFAULT ;

DROP TABLE test;