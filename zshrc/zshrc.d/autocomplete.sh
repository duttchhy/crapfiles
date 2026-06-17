# tldr-based zsh tab completion
# Parses subcommands from `tldr <cmd>` output and offers them as completions.
# Caches results in ~/.cache/tldr-complete/ for 24 hours to avoid slowness.
#
# INSTALL:
#   1. Source this file in your ~/.zshrc:
#        source /path/to/tldr_complete.zsh
#   2. Add commands you want completed to the compdef lines at the bottom.
#   3. Reload: source ~/.zshrc

_tldr_complete() {
    local cmd="$words[1]"
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/tldr-complete"
    local cache_file="$cache_dir/$cmd"

    mkdir -p "$cache_dir"

    # Rebuild cache if missing or older than 24 hours
    if [[ ! -f "$cache_file" ]] || \
       [[ -n "$(find "$cache_file" -mmin +1440 2>/dev/null)" ]]; then
        tldr "$cmd" 2>/dev/null \
            | grep -oP "(?<=\`)[a-z]+ \K[a-z][-a-z]*(?=[ \`])" \
            | sort -u > "$cache_file"
    fi

    # Read suggestions from cache
    local -a suggestions
    suggestions=("${(@f)$(cat "$cache_file" 2>/dev/null)}")

    [[ ${#suggestions[@]} -eq 0 ]] && return

    compadd -a suggestions
}

# Add any commands you want tldr-powered completions for:
compdef _tldr_complete tailscale
compdef _tldr_complete docker
compdef _tldr_complete git
compdef _tldr_complete kubectl
compdef _tldr_complete systemctl
