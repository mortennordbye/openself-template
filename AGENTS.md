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

The guard (git pre-commit and pre-push hooks, installed by every push and pull, and run again
before each upload) refuses anything but the encrypted profile and its tools, and any file here
that quotes the profile. If `make push` stops at a key that is not approved, tell the owner.
