CREATE or REPLACE FUNCTION encrypt(cstring)
RETURNS cstring AS :MOD,'encrypt'
LANGUAGE C STRICT;

CREATE or REPLACE FUNCTION decrypt(cstring)
RETURNS cstring AS :MOD,'decrypt'
LANGUAGE C STRICT;

-- VARIABLE TYPE
CREATE or REPLACE FUNCTION cipherin(cstring)
RETURNS cipher AS :MOD,'encryptin'
LANGUAGE C STABLE;

CREATE or REPLACE FUNCTION cipherout(cipher)
RETURNS cstring AS :MOD,'decryptout'
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

CREATE FUNCTION text_to_cipher(text) RETURNS cipher AS
  'SELECT cipherin(textout($1))' LANGUAGE sql IMMUTABLE STRICT;

CREATE FUNCTION bpchar_to_cipher(bpchar) RETURNS cipher AS
  'SELECT cipherin(bpcharout($1::text))' LANGUAGE sql IMMUTABLE STRICT;

CREATE FUNCTION varchar_to_cipher(varchar) RETURNS cipher AS
  'SELECT cipherin(varcharout($1))' LANGUAGE sql IMMUTABLE STRICT;

-- Cast definition
CREATE CAST (cipher AS text)
  WITH FUNCTION cipher_to_text(cipher) AS IMPLICIT;

CREATE CAST (text AS cipher)
  WITH FUNCTION text_to_cipher(text) AS IMPLICIT;

CREATE CAST (bpchar AS cipher)
  WITH FUNCTION bpchar_to_cipher(bpchar) AS ASSIGNMENT;

CREATE CAST (varchar AS cipher)
  WITH FUNCTION varchar_to_cipher(varchar) AS ASSIGNMENT;