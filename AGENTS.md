# Working on this profile (for AI assistants)

This repository can be public. It holds only `profile.age` (the profile, encrypted), the
encrypted vaults (`<name>.age`, listed in `.openself/config`), the public keys in
`.openself/recipients`, and the tools. The readable profile is in `profile/`, and each vault in
`<name>/`: separate git repositories that are never committed here.

Do:

- Read and edit the profile in `profile/`, following `openself/SPEC.md`: the owner's own words,
  never guesses, open questions as `⚑` flags.
- Commit each change in the profile: `./self commit profile <id> "<what>" --actor claude`.
- Run `make check` before and after a change.
- Run `make push` only when the owner asks. It encrypts with the public keys only and needs no
  secret.

Never:

- `git add` or commit anything in this repository by hand, and never use `--no-verify`.
- Read, print or ask for the secret key, the Bitwarden session or password, or decrypt
  `profile.age`. Decrypting (`make pull`) is the owner's.
- Run `make trust` / `./self trust`, add keys to `.openself/recipients`, or add the label
  `new-recipient` to a pull request. Who can read the profile is the owner's call.
- Change the guard workflow, rulesets or repository settings to get something through.
- Copy profile or vault text into this repository, a commit message, an issue or a pull request.

## Requests from the web app

`make ai` starts Claude Code told to run `./self assistant watch` as a background monitor (another
assistant can run it too). While it runs, the AI chip in the web app (`make serve`) is green. Each
line it prints is a request the owner made there:

    REQUEST #N entry=<id> file=<path>: <what the owner wants> | about: <the text it is about>

For each one:

1. Read the entry in `profile/` and its open `⚑` flags.
2. Interview the owner here in the chat: short questions, one topic at a time, about what the
   request names (a flag's question, a missing field, or the whole entry).
3. Write the answers into the entry in the owner's own words (SPEC rules 0 to 2): their verbatim
   words under the "own words" section, a resolved flag gets `(løst <date>)`/`(resolved <date>)`
   and the answer in quotes. Never fill in anything the owner did not say.
4. `./self commit profile <id> "<what>" --actor claude`, then `make check`.
5. `./self assistant done N --note "<what changed>"`. The web app shows the note.

Every answer the owner saves to a `⚑` question in the web app also comes as a line:

    ANSWER #N entry=<id> file=<path>: the owner answered «<question>» with «<answer>»

The answer is already in the flag. Carry it into the entry where it settles something: a field, a
date, a sentence that said otherwise. Add a `⚑ retting:` line when a value changes or is
confirmed. If the answer is unclear or opens a new question, ask the owner here first. Then commit
and mark it done as above.

If the owner does not answer, ask once and wait. A request is never done by guessing.

The guard (git pre-commit and pre-push hooks, installed by every push and pull, and run again
before each upload) refuses anything but the encrypted profile and its tools, and any file here
that quotes the profile. If `make push` stops at a key that is not approved, tell the owner.
