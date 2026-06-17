# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"
export RPS1="%{$reset_color%}"

eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"
# -----------------------------------------------------
# oh-my-zsh plugins
# -----------------------------------------------------
plugins=(
    git
    sudo
    web-search
    zsh-autosuggestions
    zsh-syntax-highlighting
    fast-syntax-highlighting
    copyfile
    copybuffer
    dirhistory
    spaceship-vi-mode
)

# Set-up oh-my-zsh
source $ZSH/oh-my-zsh.sh

# -----------------------------------------------------
# Load modular configuration
# -----------------------------------------------------

for f in ~/.config/zshrc/zshrc.d/*; do
    if [ ! -d $f ]; then
        c=`echo $f | sed -e "s=.config/zshrc=.config/zshrc/custom="`
        [[ -f $c ]] && source $c || source $f
    fi
done

# -----------------------------------------------------
# TMUX
# -----------------------------------------------------
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [[ -z "$TMUX" ]]; then
    exec tmux
fi

# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# pnpm
export PNPM_HOME="/home/bram/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# opencode
export PATH=/home/bram/.opencode/bin:$PATH
