#!/bin/bash
# install.sh — bootstrap a new machine from this dotfiles repo
# Usage: bash install.sh [--dry-run]
#
# What it does:
#   1. Detects OS (macOS / Linux)
#   2. Symlinks tracked config files to the locations tools expect
#   3. On macOS: optionally runs brew install for listed packages
#
# What it does NOT do:
#   - Generate SSH keys (do that first — see README § Bootstrap Order)
#   - Store or expose secrets
#   - Overwrite a symlink that already points somewhere else (it warns instead)

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# ── Helpers ──────────────────────────────────────────────────────────────────

log()  { echo "  $*"; }
ok()   { echo "✅ $*"; }
warn() { echo "⚠️  $*"; }
info() { echo "ℹ️  $*"; }

# Create a symlink from $1 (repo path) → $2 (target path on disk)
# Skips if the link already exists and points to the right place.
# Warns and skips if something else is already at the target.
link() {
  local src="$DOTFILES_DIR/$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    warn "Source not found, skipping: $src"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    if [[ "$(readlink "$dst")" == "$src" ]]; then
      info "Already linked: $dst"
      return
    else
      warn "Symlink exists but points elsewhere: $dst → $(readlink "$dst"). Skipping."
      return
    fi
  fi

  if [[ -e "$dst" ]]; then
    warn "File exists (not a symlink): $dst. Skipping — back it up and re-run if you want to replace it."
    return
  fi

  if $DRY_RUN; then
    log "[dry-run] ln -sf $src $dst"
  else
    ln -sf "$src" "$dst"
    ok "Linked: $dst → $src"
  fi
}

# ── Detect OS ────────────────────────────────────────────────────────────────

OS="unknown"
[[ "$(uname)" == "Darwin" ]] && OS="mac"
[[ "$(uname)" == "Linux" ]]  && OS="linux"
info "Detected OS: $OS"
echo ""

# ── Claude Code ──────────────────────────────────────────────────────────────

echo "── Claude Code ─────────────────────────────────────────────────────────────"
link "claude/skills"        "$HOME/.claude/skills"
link "claude/settings.json" "$HOME/.claude/settings.json"
echo ""

# ── Shell ────────────────────────────────────────────────────────────────────

echo "── Shell ────────────────────────────────────────────────────────────────────"
if [[ "$OS" == "mac" ]]; then
  link "mac/.zshrc" "$HOME/.zshrc"
elif [[ "$OS" == "linux" ]]; then
  link "shared/.zshrc" "$HOME/.zshrc"
fi
echo ""

# ── Git ──────────────────────────────────────────────────────────────────────

echo "── Git ──────────────────────────────────────────────────────────────────────"
link "shared/.gitconfig"  "$HOME/.gitconfig"
link "shared/.gitignore"  "$HOME/.gitignore"
link "shared/.gitmessage" "$HOME/.gitmessage"
echo ""

# ── macOS-only: Homebrew packages ────────────────────────────────────────────

if [[ "$OS" == "mac" ]]; then
  echo "── Homebrew ─────────────────────────────────────────────────────────────────"
  if ! command -v brew &>/dev/null; then
    if $DRY_RUN; then
      log "[dry-run] Would install Homebrew"
    else
      info "Installing Homebrew…"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
  else
    info "Homebrew already installed"
  fi

  if [[ -f "$DOTFILES_DIR/mac/Brewfile" ]]; then
    if $DRY_RUN; then
      log "[dry-run] Would run: brew bundle --file mac/Brewfile"
    else
      info "Running brew bundle…"
      brew bundle --file "$DOTFILES_DIR/mac/Brewfile"
    fi
  else
    info "No Brewfile found at mac/Brewfile — skipping brew bundle"
  fi
  echo ""
fi

echo "────────────────────────────────────────────────────────────────────────────"
echo "Done. Open a new terminal session to pick up shell changes."
echo ""
echo "Next steps:"
echo "  • Copy mac/settings.json.example → mac/settings.local.json and fill in"
echo "    any machine-specific values (paths, tokens, etc.)"
echo "  • If claude/settings.json was skipped above (file already existed),"
echo "    back up ~/.claude/settings.json, remove it, and re-run install.sh"
