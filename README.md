# dotfiles

my personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

one repo serves two machines:

* **macos:** ghostty, herdr, neovim, zsh, starship
* **ubuntu 26.04:** ghostty, herdr, neovim, fish, i3 and sway, polybar
  and waybar, picom, rofi

## layout

* `home/` is the chezmoi source state (`.chezmoiroot`): each file maps
  to a path in `~`, e.g. `home/private_dot_config/sway/config` is
  `~/.config/sway/config`. the prefixes set names and permissions
  (`dot_` → `.`, `private_` → no group/other access, `executable_` →
  `+x`, `symlink_` → a symlink).
* `home/.chezmoiignore` decides what each machine gets: the desktop
  configs are linux-only, zsh and starship are macos-only, and
  everything else goes to both. tmux is retired; its config is kept for
  history but never deployed.
* `home/run_*` scripts install packages on `chezmoi apply`, and rerun
  only when their list changes.
* `packages/` holds those lists: `apt.txt`, `apt-no-recommends.txt`
  (sway, without foot and wmenu) and `Brewfile`.

## bootstrap

```sh
# chezmoi isn't in the ubuntu archive; the official installer works on
# both systems
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

git clone https://github.com/lnutimura/dotfiles ~/ghq/github.com/lnutimura/dotfiles
chezmoi init --source ~/ghq/github.com/lnutimura/dotfiles
chezmoi diff    # review before the first apply
chezmoi apply
```

`apply` writes the configs and runs the scripts. on ubuntu it
`apt install`s whatever is missing from `packages/apt*.txt` (asking for
sudo only then), installs neovim from the snap (the archive has 0.11),
and installs fisher plus the plugins in `fish_plugins`. on macos it
installs homebrew if needed and runs `brew bundle`. on both it enables
the gitleaks pre-commit hook in this clone.

## daily workflow

chezmoi copies files into `~`; it doesn't link them. so after changing a
config, get the change back into the repo:

* **edit through chezmoi:** `chezmoi edit --apply ~/.config/sway/config`
  edits the repo file and applies it.
* **or edit in place, then copy back:** `chezmoi re-add` copies every
  managed file that changed in `~` into the repo. run it after
  `vim.pack.update()` (`nvim-pack-lock.json`) and `fisher install`
  (`fish_plugins`) too, since they rewrite their own files.
* **before committing:** `chezmoi status` lists what still differs
  between `~` and the repo.
* **new file:** `chezmoi add ~/.config/foo/config`. if it belongs to one
  system only, add it to `home/.chezmoiignore`.
* **new package:** add it to `packages/apt.txt` or `packages/Brewfile`;
  the next `chezmoi apply` installs it.
* **from the other machine:** `chezmoi update` (`git pull` + `apply`),
  or `git pull` then `chezmoi diff` and `chezmoi apply`.
* **what this machine manages:** `chezmoi managed`.

## manual installs

not covered by the scripts:

* [herdr](https://herdr.dev/) (both)
* [asdf](https://asdf-vm.com/guide/getting-started.html) (both)
* [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter) for
  `nvim-treesitter` on ubuntu (`sudo apt install tree-sitter-cli`;
  macos gets it from the Brewfile)
* JetBrainsMono and InconsolataGo fonts from
  [nerd fonts](https://www.nerdfonts.com/) on ubuntu (not packaged;
  polybar needs InconsolataGo). macos gets JetBrainsMono from the
  Brewfile.

## ubuntu notes

* `xorg` and `xserver-xorg-input-libinput` are installed by name. gnome
  on 26.04 is wayland-only, so a release upgrade autoremoves them, and
  i3 then starts with no keyboard or mouse. check after an upgrade.
* use the archive `picom` (12.x). a build against older ubuntu
  libraries breaks after an upgrade.
* i3 and sway both draw `~/.local/share/wallpaper`, a per-machine
  symlink that chezmoi doesn't manage. point it at an image once:

  ```sh
  ln -sfn <image> ~/.local/share/wallpaper
  ```

## ubuntu: sway next to i3

sway runs next to i3; pick it at the login screen. keybindings,
workspaces and the resize mode live in `~/.config/wm/common.conf`
(`home/private_dot_config/wm/common.conf`), which both `i3/config` and
`sway/config` include, so change them there and check both afterwards:

```sh
i3 -C -c ~/.config/i3/config && sway --unsupported-gpu -C -c ~/.config/sway/config
```

* sway refuses the proprietary nvidia driver unless started with
  `--unsupported-gpu`, and has no environment variable for it. add a
  login-screen entry that passes the flag, then log in to
  "Sway (NVIDIA)". this file lives outside `~`, so chezmoi doesn't
  manage it:

  ```sh
  sudo tee /usr/local/share/wayland-sessions/sway-nvidia.desktop <<'EOF'
  [Desktop Entry]
  Name=Sway (NVIDIA)
  Exec=sway --unsupported-gpu
  Type=Application
  DesktopNames=sway;wlroots
  EOF
  ```
* the output line in `sway/config` names this machine's monitor
  (`DP-2`); list yours with `swaymsg -t get_outputs`.
* use firefox from [mozilla's apt repo](https://support.mozilla.org/kb/install-firefox-linux#w_install-firefox-deb-package-for-debian-based-distributions),
  not the snap. on nvidia + wayland the snap cannot reach the gpu
  (`DMABUF: FEATURE_FAILURE_NO_DRM_DEVICE`), so it renders and decodes
  video on the cpu, and the 4k frames it hands to sway stall input.
* waybar's tray only supports StatusNotifierItem, so sway starts
  `nm-applet --indicator`; `autostart/nm-applet.desktop` keeps dex from
  starting a second copy without it.

## git hooks

a pre-commit hook runs [gitleaks](https://github.com/gitleaks/gitleaks)
on staged changes and blocks commits that contain secrets. `chezmoi
apply` enables it once per clone (`core.hooksPath .githooks`); install
gitleaks itself first (the Brewfile has it on macos).
