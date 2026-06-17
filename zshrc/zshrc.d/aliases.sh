#--------------------------------
#           Aliases
#--------------------------------
alias lz='lazygit'
alias cat='bat'
alias nvc='cd ~/.config/nvim'
alias clear='clear && fastfetch'
alias q='exit'
alias Q='tmux kill-session && quit'
alias c='clear'
alias nf='fastfetch'
alias pf='fastfetch'
alias ff='fastfetch'
alias shutdown='systemctl poweroff'
alias v='$EDITOR'
alias vim='$EDITOR'
alias wifi='nmtui'
alias sound='pavucontrol'

alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lsa='ls -la'
alias lt='ls --tree'
alias tree='lt'

#--------------------------------
#        File Handlers
#--------------------------------
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
alias f='y'
alias F='fzf --preview="bat --color=always {}"'

#--------------------------------
#        Scripts
#--------------------------------
export SCRIPT_DIR="$HOME/.config/scripts"
# Call scripts
alias update='$SCRIPT_DIR/installupdates.sh'

#--------------------------------
#        Vim Motions
#--------------------------------
# Enable vi keybindings
bindkey -v

# Optional: make cursor shape reflect mode (requires a compatible terminal)
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]]; then
    echo -ne '\e[2 q'   # block cursor
  else
    echo -ne '\e[6 q'   # beam cursor
  fi
}
zle -N zle-keymap-select

# Set the initial cursor shape when zsh starts
echo -ne '\e[6 q'

# Optional: fix cursor when leaving zsh
function zle-line-finish {
  echo -ne '\e[6 q'
}
zle -N zle-line-finish

