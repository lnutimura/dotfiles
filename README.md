# dotfiles

My configs for a MacBook Pro and an Ubuntu 26.04 desktop, managed with
[chezmoi](https://www.chezmoi.io/) and themed with
[mistpine](https://github.com/mistpine/mistpine) throughout.

| | macOS | Ubuntu 26.04 |
|---|---|---|
| [Terminal](#terminal) | Ghostty + herdr | Ghostty + herdr |
| [Shell](#shell) | zsh + Starship | fish + Tide |
| [Editor](#neovim) | Neovim 0.12 | Neovim 0.12 |
| [Desktop](#window-managers) | macOS | i3 (X11) and sway (Wayland) |
| [Packages](#install) | Homebrew | apt, snap |

**Contents:** [Terminal](#terminal) · [Shell](#shell) · [Neovim](#neovim) ·
[Window managers](#window-managers) · [Theme](#theme) · [Fonts](#fonts) ·
[Install](#install) · [Daily use](#daily-use) ·
[Ubuntu notes](#ubuntu-notes) · [Repository layout](#repository-layout)

> [!WARNING]
> These are personal settings. Read before you apply them.

## Terminal

<p align="center">
  <img src="https://raw.githubusercontent.com/mistpine/mistpine.ghostty/main/assets/screenshots/shell.png" alt="Ghostty with the mistpine theme" width="80%">
</p>

- **[Ghostty](https://ghostty.org/)** (`ghostty/`): JetBrainsMono Nerd
  Font Mono at 12 pt, a blinking block cursor, and the mistpine theme.
  Left Option acts as Alt on macOS. `alt+left/right` and
  `ctrl+shift+left/right` are unbound so they reach the app inside
  (herdr moves tabs with the latter).
- **[herdr](https://herdr.dev/)** (`herdr/`): a workspace manager for
  running AI coding agents side by side. Its prefix is `ctrl+t`, with
  tmux-style splits (`prefix "` and `prefix %`), `ctrl+shift+left/right`
  to move tabs, an agent sidebar, and mistpine colors. The install script
  sets it up, and `herdr update` keeps it current.

tmux is retired. Its config stays in the repo for history but is never
deployed.

## Shell

**fish on Ubuntu** (`private_fish/`), with plugins from
[Fisher](https://github.com/jorgebucaran/fisher):

- [Tide](https://github.com/IlanCosman/tide) prompt
- [z](https://github.com/jethrokuan/z) for directory jumping
- [fzf.fish](https://github.com/PatrickF1/fzf.fish), plus `ctrl+f` to jump
  to any repo under `ghq root` or to `~/.config`
- `vim` → `nvim`, `g` → `git`, `ll` → `exa -l -g --icons`

**zsh on macOS**, with the [Starship](https://starship.rs/) prompt
(`starship/starship.toml`; set
`STARSHIP_CONFIG=~/.config/starship/starship.toml`).

## Neovim

<p align="center">
  <img src="https://raw.githubusercontent.com/mistpine/mistpine.nvim/main/assets/preview.png" alt="Neovim with mistpine.nvim" width="80%">
</p>

A Neovim 0.12+ config (`nvim/`) with no plugin manager.
[`vim.pack`](https://neovim.io/doc/user/pack.html#vim.pack) installs the
plugins, and `nvim-pack-lock.json` pins all 34.

- **LSP:** native `vim.lsp`, with
  [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) defaults and
  overrides in `after/lsp/`. The servers are gopls, pyright, ruff, lua_ls,
  jsonls, yamlls, taplo, marksman, dockerls and tofu_ls.
- **Tools:** [mason](https://github.com/mason-org/mason.nvim) installs the
  servers, formatters, linters and the tree-sitter CLI into nvim's own
  PATH, so both machines get the same versions.
- **Editing:** blink.cmp, conform, nvim-lint, nvim-treesitter (main) with
  textobjects, mini, dial, inc-rename.
- **UI:** telescope, snacks, noice, lualine, bufferline, incline,
  gitsigns, and
  [mistpine.nvim](https://github.com/mistpine/mistpine.nvim).

See [`nvim/README.md`](home/private_dot_config/nvim/README.md) for the
module layout and how to add, update or remove plugins.

## Window managers

<p align="center">
  <img src="https://raw.githubusercontent.com/mistpine/mistpine.sway/main/assets/preview.png" alt="sway with mistpine" width="80%">
</p>

On Ubuntu, i3 (X11) and sway (Wayland) are both installed; pick one at the
login screen. Both include **`wm/common.conf`** for keybindings,
workspaces, gaps and the resize mode, so a change there applies to both.

| | i3 (X11) | sway (Wayland) |
|---|---|---|
| Bar | [Polybar](https://github.com/polybar/polybar) | [Waybar](https://github.com/Alexays/Waybar) |
| Compositor | [picom](https://github.com/yshui/picom) | built in |
| Lock and idle | xss-lock + i3lock | swaylock + swayidle |
| Wallpaper | feh | swaybg |
| Screenshots | | grim + slurp → clipboard (`Print`) |
| Launcher | [rofi](https://github.com/davatorium/rofi) 2.0 | rofi 2.0 |

**Main keys** (`Super` is the modifier):

| Keys | Action |
|---|---|
| `Super+Return` | Ghostty |
| `Super+d` | rofi |
| `Super+q` | close window |
| `Super+h/j/k/l` | focus left/down/up/right |
| `Super+Shift+h/j/k/l` | move window |
| `Super+v` / `Super+Shift+v` | split vertically / horizontally |
| `Super+s` / `w` / `e` | stacked / tabbed / toggle split |
| `Super+f` | fullscreen |
| `Super+1…0` | workspace 1–10 (`+Shift` moves the window) |

After editing, check both configs:

```sh
i3 -C -c ~/.config/i3/config && sway --unsupported-gpu -C -c ~/.config/sway/config
```

## Theme

Every app uses [mistpine](https://github.com/mistpine/mistpine), with cool
misty grays over a deep blue-green night and muted, earthy accents. Each
app has its own port:
[Ghostty](https://github.com/mistpine/mistpine.ghostty) ·
[Neovim](https://github.com/mistpine/mistpine.nvim) ·
[sway and i3](https://github.com/mistpine/mistpine.sway) ·
[Waybar](https://github.com/mistpine/mistpine.waybar) ·
[Polybar](https://github.com/mistpine/mistpine.polybar) ·
[swaylock](https://github.com/mistpine/mistpine.swaylock) ·
[rofi](https://github.com/mistpine/mistpine.rofi).
herdr uses mistpine colors in `herdr/config.toml`.

## Fonts

| Font | Used by | How to get it |
|---|---|---|
| JetBrainsMono Nerd Font | Ghostty, swaylock | Brewfile on macOS; [Nerd Fonts](https://www.nerdfonts.com/) on Ubuntu |
| InconsolataGo Nerd Font | Polybar, Waybar | [Nerd Fonts](https://www.nerdfonts.com/) (not packaged) |
| FontAwesome | bar icons | `fonts-font-awesome` (apt) |

## Install

```sh
# chezmoi isn't in Ubuntu's archive; the official installer works on both
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

git clone https://github.com/lnutimura/dotfiles ~/ghq/github.com/lnutimura/dotfiles
chezmoi init --source ~/ghq/github.com/lnutimura/dotfiles
chezmoi diff    # review before the first apply
chezmoi apply
```

`chezmoi apply` writes the configs for the current OS and runs the setup
scripts:

| Script | macOS | Ubuntu |
|---|---|---|
| Packages | installs Homebrew if needed, then `brew bundle` | `apt install`s whatever is missing from `packages/apt*.txt` (sudo only then); Neovim from the snap, because the archive has 0.11 |
| fish plugins | | installs Fisher and syncs `fish_plugins` |
| herdr | official installer if missing | official installer if missing |
| Git hooks | enables the gitleaks pre-commit hook | enables the gitleaks pre-commit hook |

The package scripts rerun only when their list changes.

**Still manual:**

- [asdf](https://asdf-vm.com/guide/getting-started.html), which provides
  node for mason's npm-based servers
- Nerd Fonts on Ubuntu (see [Fonts](#fonts))
- [gitleaks](https://github.com/gitleaks/gitleaks) on Ubuntu (it's in the
  Brewfile on macOS)

## Daily use

chezmoi copies files into `~`; it doesn't link them. After a change, get
it back into the repo:

| To | Run |
|---|---|
| Edit a config and apply it | `chezmoi edit --apply ~/.config/sway/config` |
| Copy changes made in `~` back to the repo | `chezmoi re-add` (also after `vim.pack.update()` or `fisher install`) |
| See what differs before committing | `chezmoi status` |
| Track a new file | `chezmoi add ~/.config/foo/config` (one OS only? add it to `home/.chezmoiignore`) |
| Add a package | edit `packages/apt.txt` or `packages/Brewfile`, then `chezmoi apply` |
| Pull from the other machine | `chezmoi update` (`git pull` + `apply`) |
| List what this machine manages | `chezmoi managed` |

## Ubuntu notes

- **X11 packages.** `xorg` and `xserver-xorg-input-libinput` are
  installed by name. GNOME on 26.04 is Wayland-only, so a release upgrade
  autoremoves them, and i3 then starts with no keyboard or mouse. Check
  after an upgrade.
- **picom.** Use the archive build (12.x). A build against older Ubuntu
  libraries breaks after an upgrade.
- **Wallpaper.** i3 and sway both draw `~/.local/share/wallpaper`, a
  per-machine symlink that chezmoi doesn't manage. Point it at an image
  once:

  ```sh
  ln -sfn <image> ~/.local/share/wallpaper
  ```
- **NVIDIA and sway.** sway refuses the proprietary driver unless started
  with `--unsupported-gpu`, and has no environment variable for it. Add a
  login-screen entry that passes the flag, then log in to "Sway
  (NVIDIA)". This file lives outside `~`, so chezmoi doesn't manage it:

  ```sh
  sudo tee /usr/local/share/wayland-sessions/sway-nvidia.desktop <<'EOF'
  [Desktop Entry]
  Name=Sway (NVIDIA)
  Exec=sway --unsupported-gpu
  Type=Application
  DesktopNames=sway;wlroots
  EOF
  ```
- **Monitor.** The output line in `sway/config` names this machine's
  monitor (`DP-2`); list yours with `swaymsg -t get_outputs`.
- **Firefox.** Use the build from
  [Mozilla's apt repo](https://support.mozilla.org/kb/install-firefox-linux#w_install-firefox-deb-package-for-debian-based-distributions),
  not the snap. On NVIDIA + Wayland the snap can't reach the GPU
  (`DMABUF: FEATURE_FAILURE_NO_DRM_DEVICE`), so it renders and decodes
  video on the CPU, and the 4K frames it hands to sway stall input.
- **Tray.** Waybar's tray only supports StatusNotifierItem, so sway
  starts `nm-applet --indicator`; `autostart/nm-applet.desktop` keeps dex
  from starting a second copy without it.
- **tree-sitter.** Neovim gets the tree-sitter CLI from mason, because
  nvim-treesitter needs 0.26.1 or later and Ubuntu's `tree-sitter-cli` is
  0.25. Don't install the apt one. Building parsers needs a C compiler
  (`build-essential`, in `apt.txt`).

## Repository layout

```
.
├── home/                    chezmoi source state (see .chezmoiroot)
│   ├── .chezmoiignore       which files each OS gets
│   ├── private_dot_config/  → ~/.config
│   └── run_*                setup scripts
├── packages/                apt.txt, apt-no-recommends.txt, Brewfile
└── .githooks/pre-commit     gitleaks on staged changes
```

Each file in `home/` maps to a path in `~`, e.g.
`home/private_dot_config/sway/config` is `~/.config/sway/config`. The
name prefixes set names and permissions: `dot_` becomes `.`, `private_`
removes group and other access, `executable_` adds `+x`, and `symlink_`
creates a symlink. `.chezmoiignore` keeps the desktop configs on Linux
and zsh and Starship on macOS; everything else goes to both.
