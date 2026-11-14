# dotfiles

my personal dotfiles

## requirements

* [asdf](https://asdf-vm.com/guide/getting-started.html)
* [fd](https://github.com/sharkdp/fd)
* [fish](https://fishshell.com/)
* [fisher](https://github.com/jorgebucaran/fisher)
* [ghostty](https://ghostty.org/)
* [i3](https://i3wm.org/)
* [neovim](https://github.com/neovim/neovim)
* [picom](https://github.com/yshui/picom)
* [polybar](https://github.com/polybar/polybar)
* [rg](https://github.com/BurntSushi/ripgrep)
* [rofi](https://github.com/davatorium/rofi)
* [sway](https://swaywm.org/)
* [tmux](https://github.com/tmux/tmux)
* [tpm](https://github.com/tmux-plugins/tpm)
* [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter)
* [waybar](https://github.com/Alexays/Waybar)
* [z](https://github.com/rupa/z)

## ubuntu 26.04 (i3 session)

install the X session and everything the i3 and polybar configs call
from the ubuntu archive:

```sh
sudo apt install \
  xorg xserver-xorg-input-libinput \
  i3 dex xss-lock network-manager-gnome ghostty \
  picom feh polybar rofi \
  pulseaudio-utils wireplumber x11-xserver-utils psmisc \
  fonts-font-awesome
```

* install `xorg` and `xserver-xorg-input-libinput` by name. gnome on
  26.04 is wayland-only, so a release upgrade autoremoves them, and i3
  then starts with no keyboard or mouse.
* use the archive `picom` (12.x). a build against older ubuntu
  libraries breaks after an upgrade.
* polybar also needs the InconsolataGo font from
  [nerd fonts](https://www.nerdfonts.com/), which is not packaged.
* i3 and sway both draw `~/.local/share/wallpaper`, a per-machine
  symlink. point it at an image once:

  ```sh
  ln -sfn <image> ~/.local/share/wallpaper
  ```

## ubuntu 26.04 (sway session)

sway runs next to i3; pick it at the login screen. keybindings,
workspaces and the resize mode live in `.config/wm/common.conf`, which
both `i3/config` and `sway/config` include, so change them there and
check both afterwards:

```sh
i3 -C -c ~/.config/i3/config && sway -C -c ~/.config/sway/config
```

install sway and its helpers (recommends would add foot and wmenu,
which ghostty and rofi already cover):

```sh
sudo apt install --no-install-recommends \
  sway swaylock swayidle swaybg waybar \
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk wl-clipboard grim slurp
```

* sway refuses the proprietary nvidia driver unless started with
  `--unsupported-gpu`, and has no environment variable for it. add a
  login-screen entry that passes the flag, then log in to
  "Sway (NVIDIA)":

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
on staged changes and blocks commits that contain secrets. enable it
once per clone:

```sh
git config core.hooksPath .githooks
```
