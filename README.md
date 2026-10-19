# My OpenSelf profile

This repository holds an [OpenSelf](https://github.com/mortennordbye/openself) profile: one
person's record (career first), kept as files they own. The profile itself is never stored here
in the clear. Only `profile.age` is committed: the whole profile, every version, encrypted with
[age](https://age-encryption.org) to the keys in `.openself/recipients`.

## How it works

```mermaid
flowchart LR
  subgraph mac["Your machine"]
    direction TB
    app["make serve<br/>the web app"]
    ai["AI assistant<br/>follows AGENTS.md"]
    profile[("profile/<br/>the readable profile<br/>with its own git history")]
    age["profile.age<br/>everything, encrypted"]
    guard{{"guard<br/>git hooks: pre-commit, pre-push"}}
    app -- "edit" --> profile
    ai -- "edit, commit" --> profile
    profile -- "make push<br/>encrypt with the public keys" --> age
    age -- "make pull<br/>decrypt with the key" --> profile
  end
  subgraph gh["GitHub: this repository, can be public"]
    remote["profile.age<br/>.openself/recipients<br/>README, Makefile, tools"]
  end
  subgraph bw["Bitwarden"]
    key["Secure note<br/>OpenSelf age key"]
  end
  age -- "git push" --> guard
  guard -- "only if nothing is unencrypted" --> remote
  remote -- "git pull" --> age
  key -. "only to decrypt<br/>asks for your master password" .-> age
```

- **`profile/`** is the profile you read and edit, with its own git history. It exists only on
  your machine and is never committed to this repository.
- **`make push`** packs all of it, every version, into one file and encrypts it to the public keys
  in `.openself/recipients`: `profile.age`. That needs no secret, so an AI assistant can do it too.
- **The guard** checks every commit and push to this repository and refuses anything that is not
  encrypted. Only `profile.age`, the public keys and the tools ever reach GitHub.
- **`make pull`** downloads `profile.age` and decrypts it into `profile/`. Only that needs the
  secret key, from Bitwarden (or the Keychain); it asks for your master password.

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
again on every outgoing commit before each upload. It refuses a commit or push with anything from
`profile/`, a file that is not part of a home (add safe ones to `.openself/allow`), a README or
other allowed file that quotes your profile (your name, email, phone, employers, customers), a
`profile.age` that is not encrypted, or anything but public keys in `.openself/recipients`. What
it cannot read, it refuses. `make push` commits only `profile.age`, the recipients and
`.gitignore`, whatever else you have staged. Run `make check` to see it for yourself.

The same check runs on GitHub (`.github/workflows/guard.yml`) on every push and pull request, with
the guard taken from `main`, so a pull request cannot change what checks it. A push that skipped
the hooks turns red and GitHub emails you. A pull request that adds a key to
`.openself/recipients` stays red until you add the label `new-recipient` to it, so you know about
every new reader.

### Lock main (recommended)

Make GitHub refuse anything on `main` that has not passed the guard there, even from you:

```
gh api -X PATCH repos/<you>/<your-repo> -F allow_auto_merge=true -F delete_branch_on_merge=true
gh api -X POST repos/<you>/<your-repo>/rulesets --input - <<'JSON'
{"name": "main: pull request with the guard green", "target": "branch", "enforcement": "active",
 "conditions": {"ref_name": {"include": ["~DEFAULT_BRANCH"], "exclude": []}},
 "rules": [{"type": "deletion"}, {"type": "non_fast_forward"},
   {"type": "pull_request", "parameters": {"required_approving_review_count": 0,
     "dismiss_stale_reviews_on_push": false, "require_code_owner_review": false,
     "require_last_push_approval": false, "required_review_thread_resolution": false,
     "allowed_merge_methods": ["merge", "squash"]}},
   {"type": "required_status_checks", "parameters": {"strict_required_status_checks_policy": false,
     "required_status_checks": [{"context": "guard", "integration_id": 15368}]}}]}
JSON
printf '# how make push uploads: through a pull request that merges itself once the guard passes\npush = pull-request\n' > .openself/config
git add .openself/config && git commit -m "Push through pull requests"   # the last direct push; open a PR for it once main is locked
```

From then on `make push` sends the snapshot to the branch `openself/snapshot` and opens a pull
request that GitHub merges by itself (a merge commit) once the guard passes; `make pull`
fast-forwards to it. It needs the GitHub CLI (`brew install gh`, `gh auth login`). GitHub only
offers content rules to organisation repositories, so other branches cannot be locked the same
way: a bad push there is public, but it cannot reach `main`, and the check turns red.

A key in `.openself/recipients` is only used once you have approved it on this machine. A key that
arrives with a pull (from another machine, or from someone who should not be adding one) stops
`make push` with the key listed. If it is yours, `make trust`; if not, remove it.

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
`.openself/recipients` from a machine that can already decrypt, `make trust` and `make push` there,
then `make pull` here. The new machine's key is the only one it ever made, so `make trust` there
should list only that key; anything else, stop and find out what it is.

### When something goes wrong

- *could not get the key … Is Bitwarden unlocked?*: run the command in a terminal (it asks for the
  password), or `export BW_SESSION=$(bw unlock --raw)` first. In the app, restart it with
  `make serve`.
- *Bitwarden already has a note named … with a different key*: there are two keys. Do not
  overwrite either; find out which one opens `profile.age` (`make pull` with each) first.
- *not encrypting: .openself/recipients has keys this machine has not approved*: someone or
  something added a key. If it is one of your machines, `make trust`. If you do not know it,
  remove it from `.openself/recipients` and push; it never got anything encrypted to it.
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
