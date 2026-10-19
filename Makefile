# OpenSelf home. `make` lists the commands.
.PHONY: help serve pull push check bitwarden keys trust vault vaults

help:
	@echo "make serve      open the web app (asks for the Bitwarden password if the key is there)"
	@echo "make pull       download and decrypt the profile into profile/"
	@echo "make push       check, then encrypt profile/ into profile.age, commit and upload"
	@echo "make check      the guard (nothing unencrypted can be published) and the profile lint"
	@echo "make keys       make this machine's key and add its public key to the recipients"
	@echo "make trust      approve recipients this machine has not seen yet (a new machine's key)"
	@echo "make bitwarden  move the key into Bitwarden and read it from there from now on"
	@echo "make vault NAME=docs  a vault: docs/, any files, pushed encrypted as docs.age"
	@echo "make vaults     the vaults, and which have changes to push"

serve:
	./self serve

pull:
	./self pull

push: check
	./self push

check:
	./self guard
	@if [ -d profile ]; then ./self lint profile --quiet; fi

keys:
	./self keys

trust:
	./self trust

bitwarden:
	./self keys --bitwarden

vault:
	@test -n "$(NAME)" || { echo "usage: make vault NAME=<name>"; exit 1; }
	./self vault add $(NAME)

vaults:
	./self vault list
