# dotfiles

Personal configuration files for macOS and Linux. Uses symlinks so the repo
is always in sync with what's live on disk — edit in one place, commit, done.

> **Legacy note:** This repo originally ran on Pop!\_OS (forked from
> [victoriadrake/dotfiles](https://github.com/victoriadrake/dotfiles)). Linux
> scripts are preserved in `scripts/linux/` for reference but are no longer
> the primary focus.

---

## Repository layout

```
dotfiles/
├── claude/
│   ├── settings.json          # Claude Code user preferences & permissions
│   └── skills/                # Personal Claude Code skills (slash commands)
│       └── sync-gdoc/
│           └── SKILL.md
├── mac/
│   ├── .zshrc                 # macOS shell config (oh-my-zsh + starship)
│   └── Brewfile               # Homebrew packages (brew bundle)
├── shared/
│   ├── .gitconfig             # Git identity & aliases
│   ├── .gitignore             # Global gitignore
│   └── .gitmessage            # Commit message template
├── scripts/                   # Legacy Linux setup scripts (reference only)
│   └── linux/
├── .gitignore                 # Repo-level ignores (secrets, runtime files)
├── install.sh                 # Bootstrap script — symlinks everything into place
└── README.md
```

---

## What is and isn't tracked

| Tracked ✅ | Not tracked ❌ |
|-----------|--------------|
| `claude/settings.json` | `claude/history.jsonl` (private conversations) |
| `claude/skills/` | `claude/plugins/` (auto-managed cache) |
| `mac/.zshrc` | `claude/certs/` (private key material) |
| `shared/.gitconfig` | `*.local` files (machine-specific overrides) |
| `mac/Brewfile` | SSH keys, `.env` files, tokens |

**Rule of thumb:** if a file contains a secret, a session, a cache, or a
machine-specific value that differs between machines — don't track it.

---

## Bootstrap order (new machine)

Do these steps **in order**. Each step unblocks the next.

### 1. Generate SSH keys

```bash
mkdir -p ~/.ssh && cd ~/.ssh
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub | pbcopy   # macOS — copies public key to clipboard
```

Add the public key to [GitHub](https://github.com/settings/keys) before
proceeding. Without this, the git clone in step 2 will fail over SSH.

### 2. Clone the repo

```bash
# SSH (preferred — requires step 1 to be done first)
git clone git@github.com:mvogelgesang/dotfiles.git ~/dotfiles

# HTTPS fallback (if SSH keys aren't set up yet)
git clone https://github.com/mvogelgesang/dotfiles.git ~/dotfiles
```

### 3. Run the install script

```bash
cd ~/dotfiles

# Preview what will happen without making changes
bash install.sh --dry-run

# Apply
bash install.sh
```

The script symlinks tracked files to the locations tools expect. It will warn
(and skip) if something already exists at the target — it never silently
overwrites.

### 4. Handle pre-existing files

If the script warns that a file already exists (e.g. `~/.claude/settings.json`
was created before you cloned dotfiles), back it up and re-run:

```bash
mv ~/.claude/settings.json ~/.claude/settings.json.bak
bash install.sh
# Review the .bak against the tracked version and merge any differences
```

### 5. Machine-local overrides

Some config can't be the same on every machine (work email vs personal email,
internal hostnames, etc.). Use `.local` files — they are gitignored by default.

**Git identity example** — `shared/.gitconfig` sets defaults; create
`~/.gitconfig.local` for overrides:

```ini
# ~/.gitconfig.local  (gitignored — never committed)
[user]
    email = work-email@company.com
    signingkey = <work gpg key>
```

Then in `shared/.gitconfig`, include it at the bottom:

```ini
[include]
    path = ~/.gitconfig.local
```

**Shell example** — add `~/.zshrc.local` for machine-specific exports and
source it at the bottom of `mac/.zshrc`:

```zsh
# at the bottom of mac/.zshrc
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

---

## Adding new dotfiles

### Add a new config file

1. Copy the file into the appropriate directory in this repo:
   ```bash
   cp ~/.config/starship.toml ~/dotfiles/shared/starship.toml
   ```

2. Add a `link` line to `install.sh` in the relevant section:
   ```bash
   link "shared/starship.toml" "$HOME/.config/starship.toml"
   ```

3. Remove the original (it will be replaced by the symlink):
   ```bash
   rm ~/.config/starship.toml
   bash install.sh   # creates the symlink
   ```

4. Verify the symlink:
   ```bash
   ls -la ~/.config/starship.toml
   # → ~/.config/starship.toml → /Users/you/dotfiles/shared/starship.toml
   ```

5. Commit:
   ```bash
   cd ~/dotfiles && git add -A && git commit -m "chore: add starship config"
   git push
   ```

### Add a new Claude Code skill

1. Create the skill directory and file:
   ```bash
   mkdir -p ~/dotfiles/claude/skills/<skill-name>
   # write ~/dotfiles/claude/skills/<skill-name>/SKILL.md
   ```

2. The `claude/skills` directory is already symlinked to `~/.claude/skills` —
   the new skill is immediately available without re-running `install.sh`.

3. Commit:
   ```bash
   cd ~/dotfiles
   git add claude/skills/<skill-name>
   git commit -m "feat(skills): add <skill-name>"
   git push
   ```

### Add a Homebrew package

```bash
brew install <package>
cd ~/dotfiles && brew bundle dump --file mac/Brewfile --force
git add mac/Brewfile && git commit -m "chore(brew): add <package>"
git push
```

---

## Day-to-day workflow

Because everything is symlinked, you edit config files in their normal
locations (`~/.zshrc`, `~/.claude/settings.json`, etc.) and the changes are
automatically reflected in `~/dotfiles`. Just commit and push:

```bash
cd ~/dotfiles
git add -A
git commit -m "chore: <describe the change>"
git push
```

On another machine:
```bash
cd ~/dotfiles && git pull
# Symlinks mean changes take effect immediately
# If new files were added to install.sh, re-run it:
bash install.sh
```

---

## Pitfalls

### App overwrites the symlink
Some apps write settings by creating a temp file and renaming it over the
original, which **replaces the symlink with a real file**. Claude Code's
`settings.json` can do this.

**Detection:**
```bash
ls -la ~/.claude/settings.json
# Should show: → /Users/you/dotfiles/claude/settings.json
# If it shows a file size instead, the symlink was broken
```

**Fix:**
```bash
cp ~/.claude/settings.json ~/dotfiles/claude/settings.json   # save any new changes
rm ~/.claude/settings.json
bash ~/dotfiles/install.sh                                    # re-create symlink
```

### Secrets in config files
Always audit files before the first commit and after adding new tools:
```bash
cd ~/dotfiles
grep -r "token\|secret\|password\|key" --include="*.json" --include="*.toml" --include="*.ini" -l
```

### Merge conflicts in settings.json
If Claude Code writes to `settings.json` on two machines before you push/pull,
you'll get a JSON merge conflict. Resolve manually. Avoid this by pulling
before starting a session and pushing when done.

### The bootstrap problem
You need SSH keys to clone the repo, but the repo contains your SSH config.
Always generate SSH keys first (step 1 above) before cloning. Document the
passphrase in your password manager.

---

## Cron jobs (Claude Code scheduler)

Claude Code scheduled tasks live in `.claude/scheduled_tasks.json` inside each
workspace — not in this dotfiles repo. They are workspace-specific and
auto-expire after 7 days.

Active jobs are documented in the
[notebook meta/patterns.md](https://github.com/mvogelgesang/notebook/blob/main/meta/patterns.md).
