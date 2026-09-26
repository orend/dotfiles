source ~/bin/dotfiles/bashrc
export PATH="/opt/homebrew/opt/node/bin:$PATH"


# >>> ai-platform-dev-utilities >>>
alias claude="ucode claude --provider mmic.inference_tables.mminfra-prod-bedrock --workspace https://modmed-dashboards.cloud.databricks.com"
# <<< ai-platform-dev-utilities <<<


# >>> ai-platform-dev-utilities:path >>>
export PATH="/Users/oren.dobzinski/.local/bin:$PATH"
# <<< ai-platform-dev-utilities:path <<<

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
