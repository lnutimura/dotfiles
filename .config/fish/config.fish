set -U fish_greeting

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# aliases
alias g git

alias ls "ls -p -G"
alias la "ls -A"
alias ll "exa -l -g --icons"
alias lla "ll -a"

if command -qv nvim
    alias vim nvim
    alias gvim "nvim --listen ~/.cache/nvim/godot.pipe"
end

# environment variables
set -gx EDITOR nvim

set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH
set -gx PATH ~/.cargo/bin $PATH
set -gx PATH ~/go/bin $PATH
set -gx PATH /usr/local/go/bin $PATH
set -gx PATH node_modules/.bin $PATH

set -gx TERM xterm-256color

if status is-interactive
end

# asdf
source ~/.asdf/asdf.fish
