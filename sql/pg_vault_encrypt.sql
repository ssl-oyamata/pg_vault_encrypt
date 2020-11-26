-- SELECT encrypt('宇宙人になりたい');
SELECT decrypt(encrypt('宇宙人になりたい'));

-- SELECT encrypt('I want to be an alien');
SELECT decrypt(encrypt('I want to be an alien'));

create table test(id int , data cipher);
insert into test values(1, 'jp');
insert into test values(2, '宇宙人になりたい');
insert into test values(3, 'I want to be an alien');

SELECT * FROM test;

SELECT * FROM test where data = '宇宙人になりたい';
SELECT * FROM test where data LIKE '宇宙人%';
SELECT * FROM test where data LIKE '%になりたい';
SELECT * FROM test where data LIKE '%宇宙人%';
SELECT * FROM test where data LIKE '%宇宙まん%';

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