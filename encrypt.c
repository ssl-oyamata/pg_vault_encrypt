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
    char *str = PG_GETARG_CSTRING(0);
    PG_RETURN_CSTRING(VaultEncrypt(str, vault_addr, vault_token, vault_transit_engine_path, vault_transit_key_name, vault_tls_skip_verify));
}

Datum
    decrypt(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);
    PG_RETURN_CSTRING(VaultDecrypt(str, vault_addr, vault_token, vault_transit_engine_path, vault_transit_key_name, vault_tls_skip_verify));
}

Datum
    encryptin(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);
    PG_RETURN_TEXT_P(cstring_to_text((char *)(intptr_t)VaultEncrypt(str, vault_addr, vault_token, vault_transit_engine_path, vault_transit_key_name, vault_tls_skip_verify)));
}

Datum
    decryptout(PG_FUNCTION_ARGS)
{
    Datum txt = PG_GETARG_DATUM(0);
    PG_RETURN_CSTRING(VaultDecrypt(TextDatumGetCString(txt), vault_addr, vault_token, vault_transit_engine_path, vault_transit_key_name, vault_tls_skip_verify));
}