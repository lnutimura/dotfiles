# dotfiles

my personal dotfiles

## requirements

* [alacritty-theme](https://github.com/alacritty/alacritty-theme)
* [alacritty](https://alacritty.org/)
* [asdf](https://asdf-vm.com/guide/getting-started.html)
* [fd](https://github.com/sharkdp/fd)
* [fish](https://fishshell.com/)
* [fisher](https://github.com/jorgebucaran/fisher)
* [i3](https://i3wm.org/)
* [neovim](https://github.com/neovim/neovim)
* [picom](https://github.com/yshui/picom)
* [polybar](https://github.com/polybar/polybar)
* [rg](https://github.com/BurntSushi/ripgrep)
* [rofi](https://github.com/davatorium/rofi)
* [tmux](https://github.com/tmux/tmux)
* [tpm](https://github.com/tmux-plugins/tpm)
* [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter)
* [z](https://github.com/rupa/z)

## ubuntu 26.04 (i3 session)

install the X session and everything the i3 and polybar configs call
from the ubuntu archive:

```sh
sudo apt install \
  xorg xserver-xorg-input-libinput \
  i3 dex xss-lock network-manager-gnome \
  picom feh polybar rofi \
  pulseaudio-utils wireplumber x11-xserver-utils psmisc arandr \
  fonts-font-awesome
```

* install `xorg` and `xserver-xorg-input-libinput` by name. gnome on
  26.04 is wayland-only, so a release upgrade autoremoves them, and i3
  then starts with no keyboard or mouse.
* use the archive `picom` (12.x). a build against older ubuntu
  libraries breaks after an upgrade.
* polybar also needs the InconsolataGo font from
  [nerd fonts](https://www.nerdfonts.com/), which is not packaged.
* i3 sets the wallpaper by running `~/.fehbg`, which is kept per
  machine. create it once with one image per monitor:

  ```sh
  feh --bg-fill <primary-image> <secondary-image>
  ```
