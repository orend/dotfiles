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

# --- Symlink scripts to ~/bin ---
echo "Symlinking scripts to ~/bin..."
mkdir -p "$HOME/bin"
link_file "$DOTFILES_DIR/ec"    "$HOME/bin/ec"
link_file "$DOTFILES_DIR/emacs" "$HOME/bin/emacs"
chmod +x "$DOTFILES_DIR/ec" "$DOTFILES_DIR/emacs"

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
  chsh -s "$BASH_PATH"
  echo "  Default shell changed to $BASH_PATH (takes effect on next login)"
else
  echo "  Default shell is already $BASH_PATH"
fi

# --- Install Homebrew packages ---
echo "Installing Homebrew packages..."
if command -v brew >/dev/null 2>&1; then
  (cd "$DOTFILES_DIR" && brew bundle)
else
  echo "  Homebrew not found — skipping. Install from https://brew.sh"
fi

# --- Install SDKMAN ---
echo "Installing SDKMAN..."
if [ -d "$HOME/.sdkman" ]; then
  echo "  SDKMAN already installed"
else
  curl -s "https://get.sdkman.io" | bash
fi

# --- Install RVM ---
echo "Installing RVM..."
if [ -d "$HOME/.rvm" ]; then
  echo "  RVM already installed"
else
  curl -sSL https://get.rvm.io | bash
fi

echo "Done! Open a new terminal to pick up changes."
