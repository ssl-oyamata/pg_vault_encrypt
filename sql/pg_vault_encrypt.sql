-- SELECT encrypt('宇宙人になりたい');
SELECT decrypt(encrypt('宇宙人になりたい'));

-- SELECT encrypt('I want to be an alien');
SELECT decrypt(encrypt('I want to be an alien'));

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
-- SET pg_vault_encrypt.vault_token = "not key";
-- SELECT * FROM test;
-- SET pg_vault_encrypt.vault_token TO DEFAULT ;
--
-- SET pg_vault_encrypt.vault_addr = "http://192.168.0.40:8080";
-- SELECT * FROM test;
-- SET pg_vault_encrypt.vault_addr TO DEFAULT ;
--
-- SET pg_vault_encrypt.vault_transit_engine_path = "dummy";
-- SELECT * FROM test;
-- SET pg_vault_encrypt.vault_transit_engine_path TO DEFAULT ;
--
-- SET pg_vault_encrypt.vault_transit_key_name = "dummy";
-- SELECT * FROM test;
-- SET pg_vault_encrypt.vault_transit_key_name TO DEFAULT ;

DROP TABLE test;