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

--- Comparison operators
CREATE or REPLACE FUNCTION cipher_eq(cipher, cipher) RETURNS bool AS
'SELECT textin(cipherout($1)) = textin(cipherout($2))' LANGUAGE sql IMMUTABLE STRICT;

CREATE OPERATOR = (
    leftarg = cipher,
    rightarg = cipher,
    procedure = cipher_eq,
    commutator = =,
    RESTRICT = eqsel
);

CREATE or REPLACE FUNCTION cipher_ne(cipher, cipher) RETURNS bool AS
'SELECT textin(cipherout($1)) != textin(cipherout($2))' LANGUAGE sql IMMUTABLE STRICT;

CREATE OPERATOR <> (
    leftarg = cipher,
    rightarg = cipher,
    procedure = cipher_ne,
    RESTRICT = neqsel
);

CREATE or REPLACE FUNCTION cipher_lt(cipher, cipher) RETURNS bool AS
'SELECT textin(cipherout($1)) < textin(cipherout($2))' LANGUAGE sql IMMUTABLE STRICT;

CREATE OPERATOR < (
    leftarg = cipher,
    rightarg = cipher,
    procedure = cipher_lt,
    RESTRICT = scalarltsel
);

CREATE or REPLACE FUNCTION cipher_gt(cipher, cipher) RETURNS bool AS
'SELECT textin(cipherout($1)) > textin(cipherout($2))' LANGUAGE sql IMMUTABLE STRICT;

CREATE OPERATOR > (
    leftarg = cipher,
    rightarg = cipher,
    procedure = cipher_gt,
    RESTRICT = scalargtsel
);

CREATE or REPLACE FUNCTION cipher_le(cipher, cipher) RETURNS bool AS
'SELECT textin(cipherout($1)) <= textin(cipherout($2))' LANGUAGE sql IMMUTABLE STRICT;

CREATE OPERATOR <= (
    leftarg = cipher,
    rightarg = cipher,
    procedure = cipher_le,
    RESTRICT = scalargtsel
);

CREATE or REPLACE FUNCTION cipher_ge(cipher, cipher) RETURNS bool AS
'SELECT textin(cipherout($1)) >= textin(cipherout($2))' LANGUAGE sql IMMUTABLE STRICT;

CREATE OPERATOR >= (
    leftarg = cipher,
    rightarg = cipher,
    procedure = cipher_ge,
    RESTRICT = scalargtsel
);

CREATE or REPLACE FUNCTION cipher_cmp(cipher, cipher)
returns integer language sql immutable as $$
    select case
        when textin(cipherout($1)) = textin(cipherout($2)) then 0
        when textin(cipherout($1)) < textin(cipherout($2)) then -1
        else 1
    end
$$;

CREATE OPERATOR CLASS cipher_ops
    DEFAULT FOR TYPE cipher USING btree AS
        OPERATOR 1 <,
        OPERATOR 2 <=,
        OPERATOR 3 =,
        OPERATOR 4 >=,
        OPERATOR 5 >,
        FUNCTION 1 cipher_cmp(cipher, cipher);