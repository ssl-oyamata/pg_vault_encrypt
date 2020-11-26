create or replace function encrypt(cstring)
  returns cstring as :MOD,'encrypt'
  LANGUAGE C STRICT;

create or replace function decrypt(cstring)
returns cstring as :MOD,'decrypt'
LANGUAGE C STRICT;

-- VARIABLE TYPE
create or replace function cipherin(cstring)
  returns cipher as :MOD,'encryptin'
  LANGUAGE C STABLE;

create or replace function cipherout(cipher)
returns cstring as :MOD,'decryptout'
LANGUAGE C STABLE;

CREATE TYPE cipher(
INPUT = cipherin,
OUTPUT = cipherout,
STORAGE = extended,
internallength = VARIABLE
);

-- FIXED TYPE
-- create or replace function encryptCstring(cstring)
--   returns cipher1024 as :MOD,'encrypt'
--   LANGUAGE C STABLE;
--
-- create or replace function decryptCstring(cipher1024)
-- returns cstring as :MOD,'decrypt'
-- LANGUAGE C STABLE;
--
-- CREATE TYPE cipher1024(
-- INPUT = encryptcstring,
-- OUTPUT = decryptcstring,
-- STORAGE = plain,
-- internallength = 1024
-- );

-- Definition of conversion function
CREATE FUNCTION cipher_to_text(cipher) RETURNS text AS
  'SELECT textin(cipherout($1))' LANGUAGE sql IMMUTABLE STRICT;

-- Implicit cast definition
CREATE CAST (cipher AS text)
  WITH FUNCTION cipher_to_text(cipher) AS IMPLICIT;
