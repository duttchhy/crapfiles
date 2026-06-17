#!/usr/bin/env bash
# install.sh — dotfiles bootstrap for Arch / CachyOS / EndeavourOS
# Usage: bash install.sh

set -euo pipefail

# ── Colours ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}${BOLD}==> ${RESET}${BOLD}$*${RESET}"; }
success() { echo -e "${GREEN}${BOLD}  ✓ ${RESET}$*"; }
warn()    { echo -e "${YELLOW}${BOLD}  ! ${RESET}$*"; }
die()     { echo -e "${RED}${BOLD}  ✗ ${RESET}$*" >&2; exit 1; }

# ── Sanity checks ──────────────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] && die "Do not run this script as root. It will sudo where needed."
command -v pacman &>/dev/null || die "pacman not found — this script targets Arch-based systems only."

# ── AUR helper ────────────────────────────────────────────────────────────────
# neovim-nightly-bin lives in the AUR; we need yay or paru.
ensure_aur_helper() {
  if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
  elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
  else
    info "No AUR helper found — installing yay..."
    local tmp
    tmp=$(mktemp -d)
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    AUR_HELPER="yay"
    success "yay installed"
  fi
  success "AUR helper: $AUR_HELPER"
}

# ── pacman packages ────────────────────────────────────────────────────────────
PACMAN_PKGS=(
  git
  zsh
  tmux
  fastfetch
  # ghostty is available in the Arch extra repo as of 2025
  ghostty
  # build essentials (needed by several plugin managers / treesitter parsers)
  base-devel
  cmake
  unzip
  curl
  wget
  # Zinit runtime dependencies
  git
)

install_pacman_packages() {
  info "Installing pacman packages..."
  sudo pacman -Syu --needed --noconfirm "${PACMAN_PKGS[@]}"
  success "pacman packages installed"
}

# ── Neovim nightly ─────────────────────────────────────────────────────────────
# neovim-nightly-bin (AUR) ships the nightly AppImage, which includes
# vim.pack (vim.loader) unavailable in stable 0.9.x releases.
install_neovim_nightly() {
  info "Installing Neovim nightly from AUR..."

  # Remove any stable neovim that might conflict
  if pacman -Q neovim &>/dev/null; then
    warn "Stable neovim detected — removing before installing nightly..."
    sudo pacman -Rns --noconfirm neovim || true
  fi

  "$AUR_HELPER" -S --needed --noconfirm neovim-nightly-bin
  success "Neovim nightly installed: $(nvim --version | head -1)"
}

# ── Zinit (zsh plugin manager) ─────────────────────────────────────────────────
install_zinit() {
  info "Installing Zinit..."
  local zinit_home="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
  if [[ -d "$zinit_home" ]]; then
    warn "Zinit already present at $zinit_home — skipping"
    return
  fi
  mkdir -p "$(dirname "$zinit_home")"
  git clone https://github.com/zdharma-continuum/zinit.git "$zinit_home"
  success "Zinit installed"
}

# ── tmux Plugin Manager ────────────────────────────────────────────────────────
install_tpm() {
  info "Installing tmux Plugin Manager (TPM)..."
  local tpm_dir="$HOME/.dotfiles/tmux/plugins/tpm"
  if [[ -d "$tpm_dir" ]]; then
    warn "TPM already present — skipping"
    return
  fi
  git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  success "TPM installed at $tpm_dir"
  echo ""
  warn "Remember to press  prefix + I  inside a tmux session to install your plugins."
}

# ── Symlinks ───────────────────────────────────────────────────────────────────
# Safe symlink: backs up any pre-existing real file before linking.
safe_link() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    warn "Backing up existing $dst → ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
}

create_symlinks() {
  info "Creating symlinks..."
  local df="$HOME/.dotfiles"

  safe_link "$df/ghostty/config"   "$HOME/.config/ghostty"
  safe_link "$df/zsh/.zshrc"       "$HOME/.zshrc"
  safe_link "$df/zsh/.zshenv"      "$HOME/.zshenv"
  safe_link "$df/tmux/.tmux.conf"  "$HOME/.tmux.conf"
  safe_link "$df/fastfetch/config" "$HOME/.config/fastfetch"
  safe_link "$df/nvim"             "$HOME/.config/nvim"

  success "Symlinks created"
}

# ── Set zsh as default shell ───────────────────────────────────────────────────
set_default_shell() {
  if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    info "Setting zsh as default shell..."
    chsh -s "$(command -v zsh)"
    success "Default shell set to zsh — takes effect on next login"
  else
    success "zsh is already the default shell"
  fi
}

# ── Main ───────────────────────────────────────────────────────────────────────
main() {
  echo -e "\n${BOLD}Dotfiles bootstrap — Arch / CachyOS / EndeavourOS${RESET}\n"

  ensure_aur_helper
  install_pacman_packages
  install_neovim_nightly
  install_zinit
  install_tpm
  create_symlinks
  set_default_shell

  echo ""
  echo -e "${GREEN}${BOLD}All done!${RESET}"
  echo -e "  • Start a new zsh session (or  ${BOLD}exec zsh${RESET}) for Zinit to bootstrap plugins"
  echo -e "  • Open tmux and press  ${BOLD}prefix + I${RESET}  to install tmux plugins"
  echo -e "  • Open Neovim — lazy.nvim (or your pack manager) will auto-install on first run"
}

main "$@"
