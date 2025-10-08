# Prefer bash even if macOS launches zsh by default.
if command -v bash >/dev/null 2>&1; then
  exec "$(command -v bash)" -l
fi

. ~/bin/dotfiles/zsh/config
. ~/bin/dotfiles/zsh/aliases
