# My OpenSelf profile

An [OpenSelf](https://github.com/mortennordbye/openself) profile: one person's record, kept as
files they own. Only `profile.age` is committed here, the whole profile with every version,
encrypted with [age](https://age-encryption.org). The readable copy, `profile/`, never leaves
the owner's machine.

**[Documentation](https://mortennordbye.github.io/openself/)** · [Getting started](https://mortennordbye.github.io/openself/getting-started/) ·
[How encryption works](https://mortennordbye.github.io/openself/concepts/sync/)

<a href="https://raw.githubusercontent.com/mortennordbye/openself/main/docs/assets/diagrams/sync-encryption.png"><img alt="How a home works: profile/ is edited on your machine, make push bundles every version and encrypts it with age to the public keys, the guard lets only encrypted files and keys reach GitHub, and make pull on another machine decrypts it with the secret key" src="https://raw.githubusercontent.com/mortennordbye/openself/main/docs/assets/diagrams/sync-encryption.png" width="420"></a>

## Start

1. On GitHub, **Use this template** (public is fine), then clone it with the framework:
   `git clone --recurse-submodules git@github.com:<you>/<your-repo>.git`
2. Install age 1.3 or newer: `brew install age`.
3. `make keys` makes your key. **Back it up** in a password manager; without it nobody can read
   the profile again. With Bitwarden, `make bitwarden` does that for you.
4. `make serve` opens the web app; the first time it creates `profile/`.
5. `make push` checks, encrypts and uploads.

The full walkthrough is [Getting started](https://mortennordbye.github.io/openself/getting-started/).

## Day to day

| | |
|---|---|
| `make serve` | the web app: edit, history, the profile as of a date |
| `make push` | check, encrypt and upload (needs only the public keys) |
| `make pull` | download and decrypt (needs your key) |
| `make check` | the guard and the profile lint |
| `make ai` | start Claude Code answering the web app's requests |
| `make vault NAME=docs` | encrypted storage for any other files |

`make` lists them all. AI assistants follow [AGENTS.md](AGENTS.md).

## Good to know

- **Nothing unencrypted is published.** A guard runs on every commit and push, here and on
  GitHub, and refuses anything but the encrypted files, the public keys and the tools.
- **Another machine:** [On a new machine](https://mortennordbye.github.io/openself/concepts/sync/#on-a-new-machine).
- **Lock `main`** so even you cannot push past the guard: [Lock main](https://mortennordbye.github.io/openself/concepts/sync/#lock-main).
- **Something went wrong:** [Troubleshooting](https://mortennordbye.github.io/openself/troubleshooting/).
- **Update OpenSelf:** `git submodule update --remote openself`, then commit and push. The
  profile is never touched.
- **Still visible:** that the repository exists, when you push, and the size in 64 KiB steps.

## License

The template files are under the [MIT license](LICENSE). It does not cover the profile: what is
inside `profile.age` and the vaults belongs to its owner.
