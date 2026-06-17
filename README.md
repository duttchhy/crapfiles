```md
      :::::::::  :::    ::: ::::::::::: ::::::::::: ::::::::  :::    ::: :::    ::: :::   :::
     :+:    :+: :+:    :+:     :+:         :+:    :+:    :+: :+:    :+: :+:    :+: :+:   :+:
    +:+    +:+ +:+    +:+     +:+         +:+    +:+        +:+    +:+ +:+    +:+  +:+ +:+
   +#+    +:+ +#+    +:+     +#+         +#+    +#+        +#++:++#++ +#++:++#++   +#++:
  +#+    +#+ +#+    +#+     +#+         +#+    +#+        +#+    +#+ +#+    +#+    +#+
 #+#    #+# #+#    #+#     #+#         #+#    #+#    #+# #+#    #+# #+#    #+#    #+#
#########   ########      ###         ###     ########  ###    ### ###    ###    ###
```

# dotfiles

Personal configuration files for **Arch / CachyOS / EndeavourOS**, managed with symlinks and git submodules.
> No seriously, don't use them, they're sh**. 


## INSTALL

```sh
curl -fsSL https://raw.githubusercontent.com/duttchhy/crapfiles/refs/heads/master/install-script.sh | sh
```

```
~/.dotfiles/
├── ghostty/        # Terminal emulator config
├── zsh/            # Shell config & Zinit plugins
├── tmux/           # Multiplexer config & TPM
├── nvim/           # Neovim config (git submodule)
├── fastfetch/      # System info config
└─── install.sh      # Bootstrap script
```

---

## Requirements

| Tool | Source | Notes |
|---|---|---|
| `ghostty` | `pacman` | |
| `zsh` | `pacman` | Set as default shell by `install.sh` |
| `tmux` | `pacman` | Plugins managed by TPM |
| `nvim` | AUR (`neovim-nightly-bin`) | **Nightly required** — stable builds lack `vim.pack` |
| `fastfetch` | `pacman` | |
| `zinit` | git | Bootstrapped on first `zsh` launch |
| `yay` / `paru` | AUR / pre-installed | AUR helper — `yay` is installed automatically if neither is present |

---

## Fresh install

```bash
git clone --recurse-submodules https://github.com/YOU/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

`install.sh` will:

1. Install an AUR helper (`yay`) if none is found
2. Install all pacman packages
3. Install **Neovim nightly** from the AUR, removing any conflicting stable build
4. Bootstrap Zinit and TPM
5. Create all symlinks (backing up any existing files as `*.bak`)
6. Set `zsh` as the default shell

After the script finishes:

```bash
exec zsh                  # start a new zsh session — Zinit installs plugins on first run
tmux new -s main          # open tmux, then press  prefix + I  to install plugins
nvim                      # auto-installs on first open
```

---

## Neovim

The `nvim/` directory is a **git submodule** pointing to a separate repository, so it keeps its own history and can be updated independently.

```bash
# Pull latest nvim config
git submodule update --remote nvim
git commit -am "chore: bump nvim submodule"
```

`nvim/lazy-lock.json` is excluded via `.gitignore` — each machine resolves plugins to latest on first run. Remove that line from `.gitignore` if you want to pin versions across machines.

---

## Adding a new dotfile

```bash
# 1. Move the config into .dotfiles
mv ~/.config/foo ~/.dotfiles/foo

# 2. Symlink it back
ln -sf ~/.dotfiles/foo ~/.config/foo

# 3. Add an entry to install.sh → create_symlinks()

# 4. Commit
cd ~/.dotfiles && git add . && git commit -m "feat: add foo"
```

---

## Updating

```bash
cd ~/.dotfiles
git pull                            # pull dotfiles changes
git submodule update --remote nvim  # pull latest nvim config
```

---

## KDE Plasma KWIN stuff

Install the following:

- [Better Blur](https://github.com/xarblu/kwin-effects-better-blur-dx)
- [Krohnkite](https://github.com/esjeon/krohnkite)
- [Geometry Change](https://store.kde.org/p/2136283)
- [Klassy Window Decorations](https://github.com/paulmcauley/klassy)

---

## Machine-specific overrides

Any file matching `*.local` is gitignored. Source overrides from your `~/.zshrc`:

```bash
# ~/.dotfiles/zsh/.zshrc
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

Put anything machine-specific (work proxies, host-specific aliases, secrets) in `~/.zshrc.local`.
