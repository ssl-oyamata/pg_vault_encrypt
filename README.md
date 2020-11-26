# pg_vault_encrypt - cipher type
## Overview
pg_vault_encrypt is a PostgreSQL extension module that uses [Vault's Transit Secrets Engine](https://www.vaultproject.io/docs/secrets/transit)
to provide a cipher type (user-defined type) that encrypts and decrypts table data.

## Version
* 0.0.1 - In Development

## Installation
```
$ go get -t -v github.com/hashicorp/vault/api/
$ git clone https://github.com/ssl-oyamata/pg_vault_encrypt.git
$ cd pg_vault_encrypt
$ make
$ vi Makefile
DBNAME=[Your Database]
$ make install
```

### Configuration Examples
Vault Transit Secrets Engine Settings
```
$ export VAULT_ADDR=http://192.168.0.30:8200
$ vault secrets enable -path=encryption transit
$ vault write -f encryption/keys/pgtest
```

PostgreSQL settings
```
$ vim $PGDATA/postgresql.conf
# Add settings for extensions here
session_preload_libraries = '/var/lib/pgsql/pg_vault_encrypt/out/vault_encrypt_mod.so'
pg_vault_encrypt.vault_addr = 'http://192.168.0.30:8200'
pg_vault_encrypt.vault_transit_engine_path = 'encryption'
pg_vault_encrypt.vault_transit_key_name = 'pgtest'
pg_vault_encrypt.vault_tls_skip_verify = 'false'
※ It doesn't work with shared_preload_libraries!
$ pg_ctl restart
```

### Operation sample
```
$ psql
=# SET pg_vault_encrypt.vault_token = 's.v8AYIpHOXGvNSKSpEfcsL1Dk';
SET
=# SELECT encrypt('宇宙人になりたい');
                                      encrypt
-----------------------------------------------------------------------------------
 vault:v1:zDBzQkzGAj4aw1LOEMqwT+lLSZwXM7AOMGQ8SJQuoGa1+4+73LdpTdGK6Ix5/cvEL0LX3w==
(1 行)
=# SELECT decrypt(encrypt('宇宙人になりたい'));
     decrypt
------------------
 宇宙人になりたい
(1 行)

=# CREATE TABLE test(id int , data cipher);
=# INSERT INTO test values(1, 'jp');
=# INSERT INTO test values(2, '宇宙人になりたい');
=# SELECT * FROM test;
 id |      email
----+------------------
  1 | jp
  2 | 宇宙人になりたい
(2 行)

=# SELECT * FROM test where data = '宇宙人になりたい';
 id |       data
----+------------------
  2 | 宇宙人になりたい

=# SELECT * FROM test where data = '宇宙人になりたい';
ERROR:  Cannot decrypt data (vault:v1:6NefQnYqaE2Ztze4TCB8iCk4ypodiLFDrJ7Q7kpy): Error making API request.

URL: PUT https://192.168.0.30:8200/v1/encryption/decrypt/pgtest
Code: 403. Errors:

* permission denied
CONTEXT:  SQL function "cipher_to_text" statement 1
```

## Environment
|Category|Module Name|
|:--|:--:|
|OS|CentOS Linux release 7.8.2003|
|DBMS|PostgreSQL 12|
|Go |1.13|
|Vault |1.5|

## Created by
[git-itake](https://github.com/git-itake), [ssl-oyamata](https://github.com/ssl-oyamata)