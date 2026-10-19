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

On another machine, see [On a new machine](#on-a-new-machine).

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

## Your key

The secret key is the only thing that opens `profile.age`. Lose it and the profile is gone; leak
it and every version you ever pushed can be read. Only decrypting needs it (`make pull`, and Pull
in the app). Encrypting (`make push`) uses the public keys in `.openself/recipients`, so pushing
never touches the key.

openself looks for it in this order:

1. `OPENSELF_IDENTITY=<file>`, for tests and one-off use.
2. The command in `~/.config/openself/identity-command`. After `make bitwarden` that is
   `bw get notes "OpenSelf age key"`: the key is the Bitwarden **Secure note "OpenSelf age key"**,
   one line starting with `AGE-SECRET-KEY-`. If you rename the note, change the command too.
3. The macOS Keychain, service `openself`, account `age-identity` (where `make keys` puts it).
4. `~/.config/openself/identity.txt`, readable only by you (other systems).

With Bitwarden, a locked vault is fine: openself asks for your master password in the terminal and
keeps the session only while that command runs. `make serve` asks once at start, so Pull works in
the app for as long as it runs.

### On a new machine

With the key in Bitwarden:

```
git clone --recurse-submodules git@github.com:<you>/<your-repo>.git && cd <your-repo>
brew install age bitwarden-cli
bw login
mkdir -p ~/.config/openself
echo 'bw get notes "OpenSelf age key"' > ~/.config/openself/identity-command
make pull
```

Without Bitwarden: `make keys` makes a new key for this machine. Add the public key it prints to
`.openself/recipients` from a machine that can already decrypt, `make push` there, then `make pull`
here.

### When something goes wrong

- *could not get the key … Is Bitwarden unlocked?*: run the command in a terminal (it asks for the
  password), or `export BW_SESSION=$(bw unlock --raw)` first. In the app, restart it with
  `make serve`.
- *Bitwarden already has a note named … with a different key*: there are two keys. Do not
  overwrite either; find out which one opens `profile.age` (`make pull` with each) first.
- *openself guard: refusing …*: read the list it prints. It means a commit or push would have
  published something unencrypted or unexpected. Remove that from the commit; never use
  `--no-verify`.

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
