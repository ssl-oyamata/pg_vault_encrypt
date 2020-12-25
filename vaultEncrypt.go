//must be main package
package main

/*
#include "postgres.h"

#cgo LDFLAGS: -Wl,--unresolved-symbols=ignore-all

static void ereport_debug(char *s)
{
	ereport(DEBUG1,
			(errmsg("%s", s)));
}

static void ereport_info(char *s)
{
	ereport(INFO,
			(errmsg("%s", s)));
}

static void ereport_error(char *s)
{
	ereport(ERROR,
			(errmsg("%s", s)));
}
*/
import "C"
import (
	"crypto/tls"
	"encoding/base64"
	"fmt"
	"github.com/hashicorp/vault/api"
	"net/http"
)

var httpClient = &http.Client{Transport: &http.Transport{TLSClientConfig: &tls.Config{}}}

func NewVaultClient(vaultAddr string, vaultToken string, inSecure bool) *api.Client {
	config := &api.Config{Address: vaultAddr, HttpClient: httpClient}
	tlsConfig := &api.TLSConfig{Insecure: inSecure}
	err := config.ConfigureTLS(tlsConfig)
	if err != nil {
		C.ereport_error(C.CString(fmt.Sprintf("Failed Vault  ConfigureTLS %s", err)))
	}
	client, err := api.NewClient(config)
	C.ereport_debug(C.CString(fmt.Sprintf("vaultAddr : %s", vaultAddr)))
	if err != nil {
		C.ereport_error(C.CString(fmt.Sprintf("Cannot Create NewClient (%v): %s", vaultAddr, err)))
	}
	client.SetToken(vaultToken)
	return client
}

//export VaultEncrypt
func VaultEncrypt(text *C.char, vaultAddr *C.char, vaultToken *C.char, enginePath *C.char, keyName *C.char, tlsSkipVerify C.int, encryptResult **C.char) {
	plainText := C.GoString(text)
	addr := C.GoString(vaultAddr)
	token := C.GoString(vaultToken)
	skipVerify := tlsSkipVerify != 0
	encryptPath := fmt.Sprintf("%v%s%v", C.GoString(enginePath), "/encrypt/", C.GoString(keyName))
	C.ereport_debug(C.CString(fmt.Sprintf("Vault encryptPath : %s", encryptPath)))

	client := NewVaultClient(addr, token, skipVerify)
	C.ereport_debug(C.CString(fmt.Sprintf("Create new vault client.")))

	base64Target := base64.StdEncoding.EncodeToString([]byte(plainText))
	targetData := map[string]interface{}{
		"plaintext": base64Target,
	}

	C.ereport_debug(C.CString(fmt.Sprintf("Request encryption to vault.")))
	CipherData, err := client.Logical().Write(encryptPath, targetData)
	if err != nil {
		C.ereport_error(C.CString(fmt.Sprintf("Cannot encrypt data : %s", err)))
	}
	base64Cipher, ok := CipherData.Data["ciphertext"]
	if !ok {
		C.ereport_error(C.CString(fmt.Sprintf("key ciphertext not found (%v)", CipherData.Data)))
	}
	//C.ereport_debug(C.CString(fmt.Sprintf("VaultEncrypt:cipher text: %s", base64Cipher.(string))))
	*encryptResult = C.CString(base64Cipher.(string))
	//C.ereport_debug(C.CString(fmt.Sprintf("======================================'%s'\n", *encryptResult)))
	//C.ereport_debug(C.CString(fmt.Sprintf("cipher text(enc_result): %s", C.GoString(*encryptResult))))
	return
}

//export VaultDecrypt
func VaultDecrypt(cipher *C.char, vaultAddr *C.char, vaultToken *C.char, enginePath *C.char, keyName *C.char, tlsSkipVerify C.int, decryptResult **C.char) {

	base64Cipher := C.GoString(cipher)
	addr := C.GoString(vaultAddr)
	token := C.GoString(vaultToken)
	skipVerify := tlsSkipVerify != 0
	decryptPath := fmt.Sprintf("%v%s%v", C.GoString(enginePath), "/decrypt/", C.GoString(keyName))
	C.ereport_debug(C.CString(fmt.Sprintf("Vault decryptPath : %s", decryptPath)))

	client := NewVaultClient(addr, token, skipVerify)
	C.ereport_debug(C.CString(fmt.Sprintf("Create new vault client.")))

	targetData := map[string]interface{}{
		"ciphertext": base64Cipher,
	}

	C.ereport_debug(C.CString(fmt.Sprintf("Request decryption to vault.")))
	plainData, err := client.Logical().Write(decryptPath, targetData)
	if err != nil {
		C.ereport_error(C.CString(fmt.Sprintf("Cannot decrypt data : %s", err)))
	}
	base64Text, ok := plainData.Data["plaintext"].(string)
	if !ok {
		C.ereport_error(C.CString(fmt.Sprintf("key plaintext not found (%v)", plainData.Data)))
	}
	decryptText, err := base64.StdEncoding.DecodeString(base64Text)
	if err != nil {
		C.ereport_error(C.CString(fmt.Sprintf("Cannot decode data (%v): %s", base64Text, err)))
	}
	//	C.ereport_debug(C.CString(fmt.Sprintf("decrypt text: %s", decryptText))
	*decryptResult = C.CString(fmt.Sprintf("%s", decryptText))
	C.ereport_debug(C.CString(fmt.Sprintf("decrypt text(dec_result): %s", C.GoString(*decryptResult))))
	return
}

func main() {
}
