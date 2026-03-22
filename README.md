Installation:

Clone the repository to ~/bin:

    git clone <repo-url> ~/bin/dotfiles

Run the install script:

    ./install.sh

This will:
- Symlink dotfiles (.bash_profile, .gitconfig, .gitignore, .githelpers, .irbrc) to ~
- Symlink scripts (ec, emacs) to ~/bin
- Change default shell to bash
- Install Homebrew packages (brew bundle)
- Install SDKMAN and RVM

Existing files are backed up to ~/.dotfiles_backup/ before being replaced.
