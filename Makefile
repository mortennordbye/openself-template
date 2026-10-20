# OpenSelf home. `make` lists the commands.
.PHONY: help serve ai pull push check bitwarden keys trust vault vaults

help:
	@echo "make serve      open the web app (asks for the Bitwarden password if the key is there)"
	@echo "make ai         start Claude Code here, watching the web app's requests (the AI chip turns green)"
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

# Connect an assistant: Claude Code in this folder, told to watch the web app's requests (AGENTS.md).
AI_PROMPT = Watch the OpenSelf web app for requests: run './self assistant watch' as a background monitor for this whole session, start it again whenever it stops, and handle each request as AGENTS.md says (openself/SPEC.md: the owner's own words, never guesses).
ai:
	@command -v claude >/dev/null 2>&1 || { echo "Claude Code is not installed (https://claude.com/claude-code)."; \
	  echo "Another assistant works too: ask it to read AGENTS.md and run ./self assistant watch in the background."; exit 1; }
	@claude "$(AI_PROMPT)"

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
