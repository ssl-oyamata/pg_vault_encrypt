#include "postgres.h"

#include <string.h>

#include "fmgr.h"
#include "utils/builtins.h"
#include "utils/guc.h"

PG_MODULE_MAGIC;

/* GUC variables */
static char *vault_addr = NULL;
static char *vault_token = NULL;
static char *vault_transit_engine_path = NULL;
static char *vault_transit_key_name = NULL;
static bool vault_tls_skip_verify = false;

PG_FUNCTION_INFO_V1(encrypt);
PG_FUNCTION_INFO_V1(decrypt);
PG_FUNCTION_INFO_V1(encryptin);
PG_FUNCTION_INFO_V1(decryptout);

/*
 * Module load callback
 */
void _PG_init(void)
{
    /* Define custom GUC variables. */
    DefineCustomStringVariable("pg_vault_encrypt.vault_addr",
                               "The address of the Vault server.",
                               NULL,
                               &vault_addr,
                               "",
                               PGC_SUSET,
                               0,
                               NULL,
                               NULL,
                               NULL);

    DefineCustomStringVariable("pg_vault_encrypt.vault_token",
                               "The token to communicate with the Vault server.",
                               NULL,
                               &vault_token,
                               "",
                               PGC_USERSET,
                               0,
                               NULL,
                               NULL,
                               NULL);

    DefineCustomStringVariable("pg_vault_encrypt.vault_transit_engine_path",
                               "The path of Transit Secret Engine.",
                               NULL,
                               &vault_transit_engine_path,
                               "",
                               PGC_SUSET,
                               0,
                               NULL,
                               NULL,
                               NULL);

    DefineCustomStringVariable("pg_vault_encrypt.vault_transit_key_name",
                               "The key name of Transit secret engine.",
                               NULL,
                               &vault_transit_key_name,
                               "",
                               PGC_SUSET,
                               0,
                               NULL,
                               NULL,
                               NULL);

    DefineCustomBoolVariable("pg_vault_encrypt.vault_tls_skip_verify",
                             "Do not verify Vault's presented certificate before communicating with it.",
                             NULL,
                             &vault_tls_skip_verify,
                             false,
                             PGC_SUSET,
                             0,
                             NULL,
                             NULL,
                             NULL);
    EmitWarningsOnPlaceholders("pg_vault_encrypt");
}

Datum
    encrypt(PG_FUNCTION_ARGS)
{
    char *enc_result = NULL;
    size_t enc_result_len = 0;

    char *str = PG_GETARG_CSTRING(0);

    /*** for debug info ****/
    ereport(DEBUG1, errmsg("encrypt:text      : '%s'\n", str));
    ereport(DEBUG1, errmsg("encrypt:text(addr): '%x'\n", str));
    ereport(DEBUG1, errmsg("encrypt:text(len) : '%d'\n", strlen(str)));

    ereport(DEBUG1, errmsg("encrypt:call VaultEncrypt\n"));

    (void)VaultEncrypt(str, vault_addr, vault_token, vault_transit_engine_path, vault_transit_key_name, vault_tls_skip_verify, &enc_result);

    ereport(DEBUG1, errmsg("encrypt:cipher_text      : '%s'\n", enc_result));
    ereport(DEBUG1, errmsg("encrypt:cipher_text(addr): '%x'\n", enc_result));
    enc_result_len = strlen(enc_result);
    ereport(DEBUG1, errmsg("encrypt:cipher_text(len) : '%d'\n", enc_result_len));

    PG_RETURN_CSTRING(enc_result);
}

Datum
    decrypt(PG_FUNCTION_ARGS)
{
    char *dec_result = NULL;
    size_t dec_result_len = 0;

    char *str = PG_GETARG_CSTRING(0);

    /*** for debug ****/
    ereport(DEBUG1, errmsg("decrypt:cipher_text      : '%s'\n", str));
    ereport(DEBUG1, errmsg("decrypt:cipher_text(addr): '%x'\n", str));
    ereport(DEBUG1, errmsg("decrypt:cipher_text(len) : '%d'\n", strlen(str)));

    ereport(DEBUG1, errmsg("decrypt:call VaultDecrypt\n"));

    (void)VaultDecrypt(str, vault_addr, vault_token, vault_transit_engine_path, vault_transit_key_name, vault_tls_skip_verify, &dec_result);

    ereport(DEBUG1, errmsg("decrypt:text      : '%s'\n", dec_result));
    ereport(DEBUG1, errmsg("decrypt:text(addr): '%x'\n", dec_result));
    dec_result_len = strlen(dec_result);
    ereport(DEBUG1, errmsg("decrypt:text(len) : '%d'\n", dec_result_len));

    PG_RETURN_CSTRING(dec_result);
}

Datum
    encryptin(PG_FUNCTION_ARGS)
{
    char *enc_result = NULL;
    size_t enc_result_len = 0;

    char *str = PG_GETARG_CSTRING(0);

    /*** for debug ****/
    ereport(DEBUG1, errmsg("encryptin:text      : '%s'\n", str));
    ereport(DEBUG1, errmsg("encryptin:text(addr): '%x'\n", str));
    ereport(DEBUG1, errmsg("encryptin:text(len) : '%d'\n", strlen(str)));

    ereport(DEBUG1, errmsg("encryptin:call VaultEncrypt\n"));

    (void)VaultEncrypt(str, vault_addr, vault_token, vault_transit_engine_path, vault_transit_key_name, vault_tls_skip_verify, &enc_result);

    ereport(DEBUG1, errmsg("encryptin:cipher_text      : '%s'\n", enc_result));
    ereport(DEBUG1, errmsg("encryptin:cipher_text(addr): '%x'\n", enc_result));
    enc_result_len = strlen(enc_result);
    ereport(DEBUG1, errmsg("encryptin:cipher_text(len) : '%d'\n", enc_result_len));

    PG_RETURN_TEXT_P(cstring_to_text(enc_result));
}

Datum
    decryptout(PG_FUNCTION_ARGS)
{
    char *dec_result = NULL;
    size_t dec_result_len = 0;

    Datum txt = PG_GETARG_DATUM(0);

    /*** for debug ****/
    ereport(DEBUG1, errmsg("decryptout:cipher_text      : '%s'\n", TextDatumGetCString(txt)));
    ereport(DEBUG1, errmsg("decryptout:cipher_text(addr): '%x'\n", TextDatumGetCString(txt)));
    ereport(DEBUG1, errmsg("decryptout:cipher_text(len) : '%d'\n", strlen(TextDatumGetCString(txt))));

    ereport(DEBUG1, errmsg("decryptout:call VaultDecrypt\n"));

    (void)VaultDecrypt(TextDatumGetCString(txt), vault_addr, vault_token, vault_transit_engine_path, vault_transit_key_name, vault_tls_skip_verify, &dec_result);

    ereport(DEBUG1, errmsg("decryptout:text      : '%s'\n", dec_result));
    ereport(DEBUG1, errmsg("decryptout:text(addr): '%x'\n", dec_result));
    dec_result_len = strlen(dec_result);
    ereport(DEBUG1, errmsg("decryptout:text(len) : '%d'\n", dec_result_len));

    PG_RETURN_CSTRING(dec_result);
}