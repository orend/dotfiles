#!/bin/bash
set -e

DOTFILES_DIR="$HOME/bin/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Error: $DOTFILES_DIR not found. Clone the repo to ~/bin/dotfiles first."
  exit 1
fi

link_file() {
  local src="$1" dst="$2"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/"
    echo "  Backed up $dst → $BACKUP_DIR/"
  fi
  ln -s "$src" "$dst"
  echo "  Linked $dst → $src"
}

# --- Symlink dotfiles to home directory ---
echo "Symlinking dotfiles..."
link_file "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"
link_file "$DOTFILES_DIR/.gitconfig"    "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/.gitignore"    "$HOME/.gitignore"
link_file "$DOTFILES_DIR/.githelpers"   "$HOME/.githelpers"
link_file "$DOTFILES_DIR/.irbrc"        "$HOME/.irbrc"
link_file "$DOTFILES_DIR/.tmux.conf"   "$HOME/.tmux.conf"

# --- Symlink Claude Code config ---
echo "Symlinking Claude Code config..."
mkdir -p "$HOME/.claude" "$HOME/.claude/skills" "$HOME/.claude/agents"
link_file "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
link_file "$DOTFILES_DIR/claude/CLAUDE.md"     "$HOME/.claude/CLAUDE.md"

# --- Symlink Claude Code skills & agents from notes repo ---
NOTES_DIR="$HOME/lib/notes"
if [ -d "$NOTES_DIR/.claude/skills" ]; then
  echo "Symlinking Claude Code skills from notes repo..."
  for skill_dir in "$NOTES_DIR/.claude/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    link_file "$skill_dir" "$HOME/.claude/skills/$skill_name"
  done
fi
if [ -d "$NOTES_DIR/.claude/agents" ]; then
  echo "Symlinking Claude Code agents from notes repo..."
  for agent_file in "$NOTES_DIR/.claude/agents"/*.md; do
    [ -f "$agent_file" ] && link_file "$agent_file" "$HOME/.claude/agents/$(basename "$agent_file")"
  done
fi

# --- Symlink reference docs into per-project Claude memory ---
ENCODED_NOTES=$(echo "$NOTES_DIR" | sed 's|^/||; s|/|-|g; s|\.|-|g')
NOTES_MEMORY="$HOME/.claude/projects/-${ENCODED_NOTES}/memory"
if [ -d "$NOTES_MEMORY" ]; then
  echo "Symlinking reference docs into notes project memory..."
  link_file "$NOTES_DIR/repos/claude-config-layout.md" "$NOTES_MEMORY/reference_claude_config_layout.md"
fi

# --- Symlink scripts to ~/bin ---
echo "Symlinking scripts to ~/bin..."
mkdir -p "$HOME/bin"
link_file "$DOTFILES_DIR/ec"    "$HOME/bin/ec"
link_file "$DOTFILES_DIR/emacs" "$HOME/bin/emacs"
chmod +x "$DOTFILES_DIR/ec" "$DOTFILES_DIR/emacs"

# --- Install Homebrew packages ---
echo "Installing Homebrew packages..."
if command -v brew >/dev/null 2>&1; then
  (cd "$DOTFILES_DIR" && brew bundle)
else
  echo "  Homebrew not found — skipping. Install from https://brew.sh"
fi

# --- Change default shell to bash ---
echo "Setting default shell to bash..."
if [ -x /opt/homebrew/bin/bash ]; then
  BASH_PATH="/opt/homebrew/bin/bash"
elif [ -x /usr/local/bin/bash ]; then
  BASH_PATH="/usr/local/bin/bash"
else
  BASH_PATH="/bin/bash"
fi

if ! grep -qx "$BASH_PATH" /etc/shells; then
  echo "  Adding $BASH_PATH to /etc/shells (requires sudo)..."
  echo "$BASH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

if [ "$SHELL" != "$BASH_PATH" ]; then
  sudo dscl . -create "/Users/$(whoami)" UserShell "$BASH_PATH"
  echo "  Default shell changed to $BASH_PATH (takes effect on next login)"
else
  echo "  Default shell is already $BASH_PATH"
fi

# --- Install SDKMAN ---
echo "Installing SDKMAN..."
if [ -d "$HOME/.sdkman" ]; then
  echo "  SDKMAN already installed"
else
  curl -s "https://get.sdkman.io" | "$BASH_PATH"
fi

# --- Install RVM ---
echo "Installing RVM..."
if [ -d "$HOME/.rvm" ]; then
  echo "  RVM already installed"
else
  curl -sSL https://get.rvm.io | bash
fi

echo "Done! Open a new terminal to pick up changes."
