# Dotfiles

This was originally forked from Victoria Drake's [dotfiles](https://github.com/victoriadrake/dotfiles) repo.

## Linux

My preferred starting configuration. Currently using [Pop!_OS 20.10](https://pop.system76.com/).

The installation script (`scripts/install.sh`) will install a suggested serving of programs and applications using scripts in the `scripts/programs/` directory. Please verify that you want these before running the script.

Add or delete programs in `scripts/install.sh` and `scripts/programs/` to modify your installation.

## Usage

After installing your fresh OS, [create any SSH keys](https://docs.github.com/en/github-ae@latest/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) you need to access GitHub.

If not generating new keys, place the ones you need in `.ssh/`. Remember to run `ssh-add` as well as `chmod 600 <key_name>`. Then clone this repository:

```sh
git clone git@github.com:mvogelgesang/dotfiles.git

# Or use HTTPS
git clone https://github.com/mvogelgesang/dotfiles.git
```

You may optionally like to pass the `--depth` argument to clone only a few of the [most recent commits](https://github.com/mvogelgesang/dotfiles/commits/master).

Close Firefox if it's open, then run the installation script.

```sh
cd dotfiles/scripts/
./install.sh
```



Uncomment the relevant lines in `.bashrc`, then restart your terminal to see changes, or run:

```sh
cd ~
source .bashrc
```

## Random Helpful Stuff (TM)

### Clone all your remote repositories

Given a list of repository URLs, `gh-repos.txt`, run:

```sh
xargs -n1 git clone < gh-repos.txt
```

Use the `firewood` Bash alias (see `.bashrc`) to collect remote branches.

See [How to write Bash one-liners for cloning and managing GitHub and GitLab repositories](https://victoria.dev/blog/how-to-write-bash-one-liners-for-cloning-and-managing-github-and-gitlab-repositories/) for more.

### Saving and loading configuration settings

Optionally, load `settings.dconf` with:

```sh
dconf load /org/gnome/ < .config/dconf/settings.dconf
```

Back up new settings with:

```sh
dconf dump /org/gnoe/ > .config/dconf/settings.dconf
```

Run `man dconf` on your machine for more.

## Your personal CLI tool Makefile

See the Makefile in this repository for some helpful command aliases. Read about [self-documenting Makefiles on my blog](https://victoria.dev/blog/how-to-create-a-self-documenting-makefile/).

## Recommended additions

- GNOME Tweaks
- [Emoji Selector](https://extensions.gnome.org/extension/1162/emoji-selector/) ❤️✨🦄
- [Clipboard Indicator](https://extensions.gnome.org/extension/779/clipboard-indicator/)

## Mac

The [Mac setup web development](https://www.robinwieruch.de/mac-setup-web-development/) guide from Robin Wieruch provided the foundation for these scripts.

### Manual Actions

### Scripted Actions
