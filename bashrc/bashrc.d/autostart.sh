# -----------------------------------------------------
# INIT
# -----------------------------------------------------
if [[ $- == *i* ]]; then
    fastfetch
fi

# -----------------------------------------------------
# Exports
# -----------------------------------------------------
export EDITOR=nvim
export ZSH="$HOME/.oh-my-zsh"
export PATH=$PATH:~/.cargo/bin/
export PATH=$PATH:~/.local/bin/

# -----------------------------------------------------
# Set-up FZF key bindings (CTRL R for fuzzy history finder)
# -----------------------------------------------------
source <(fzf --zsh)

# zsh history
HISTFILE=~/.local/share/zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# -----------------------------------------------------
# Ctrl F to fuzzy find
# -----------------------------------------------------
bindkey '^f' fzf-file-widget

# Or create a custom function
bindkey '^f' custom-fuzzy-finder
custom-fuzzy-finder() {
  local result
  result=$(find . -type f | fzf)
  [[ -n "$result" ]] && $EDITOR "$result"
}
zle -N custom-fuzzy-finder
