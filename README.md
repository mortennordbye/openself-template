# My OpenSelf profile

This repository holds an [OpenSelf](https://github.com/mortennordbye/openself) profile: one
person's record (career first), kept as files they own. The profile itself is never stored here
in the clear. Only `profile.age` is committed: the whole profile, every version, encrypted with
[age](https://age-encryption.org) to the keys in `.openself/recipients`.

## Start

1. On GitHub: **Use this template** to make your own repository (public is fine, it only ever
   holds the encrypted file), then clone it with the framework:

   ```
   git clone --recurse-submodules git@github.com:<you>/<your-repo>.git
   cd <your-repo>
   ```

2. Install age 1.3 or newer (`brew install age`, or https://github.com/FiloSottile/age/releases).
3. Make your key: `make keys`. On macOS it goes in the Keychain. **Back it up**; without it nobody,
   including you, can read the profile again. To keep it only in Bitwarden instead, run
   `make bitwarden` once: it saves the key as a secure note, checks it, and from then on openself
   asks for your master password when it needs the key.
4. Write your profile: `make serve` opens a local web app. The first time, it asks for your name
   and language and creates `profile/`.
5. Save it to GitHub: `make push` checks, encrypts the profile into `profile.age`, commits and pushes.

On another machine: clone, copy your key there (`./self keys` makes a new one; add its public key
to `.openself/recipients` from a machine that can already decrypt, and push), then `./self pull`.

## Day to day

| | |
|---|---|
| `make serve` | the web app: edit, history, the profile as of a date |
| `make push` | check, encrypt and upload |
| `make pull` | download and decrypt |
| `make check` | the guard and the profile lint; the prompts are open questions |

`make` with no target lists them all; each is a thin wrapper around `./self`.

Tools that read profiles (CV builders, assistants) point at the decrypted `profile/` folder. AI
assistants follow `AGENTS.md`: they edit and commit in `profile/` and may push, which needs only
the public keys, but never decrypt or touch the key.

## Nothing unencrypted is ever published

`./self guard` runs as git pre-commit and pre-push hooks, installed by every push and pull, and
again before each upload. It refuses a commit or push with anything from `profile/`, a file that
is not part of a home (add safe ones to `.openself/allow`), a `profile.age` that is not encrypted,
or anything but public keys in `.openself/recipients`. Run `make check` to see it for yourself.

## Updating OpenSelf

The framework is a git submodule pinned to a version. To get a newer one:

```
git submodule update --remote openself && git commit -am "Update OpenSelf" && git push
```

Your profile is never touched by an update; format changes come with a migration.

## What stays visible

A public repository with only `profile.age` still shows that it exists, when you push, and the
size in 64 KiB steps. Encrypted files stay in public history for good, so a key that leaks later
opens every old version. Use a private repository if that matters more to you.
