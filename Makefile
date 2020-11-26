DBNAME=postgres # test setting
export CGO_CFLAGS = -I$(shell pg_config --includedir-server)
PGMOD=$(abspath out/vault_encrypt_mod.so)

all: $(PGMOD)

$(PGMOD): *.c *.go Makefile
	go build -buildmode=c-shared -o $(PGMOD)

install: $(PGMOD)
	psql $(DBNAME) --set=MOD=\'$(PGMOD)\' -f install.sql

clean:
	rm -rf out