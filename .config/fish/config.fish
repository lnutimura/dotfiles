set -U fish_greeting

# Theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# Aliases
alias g git

alias ls "ls -p -G"
alias la "ls -A"
alias ll "exa -l -g --icons"
alias lla "ll -a"

if command -qv nvim
    alias vim nvim
end

# Environment variables
set -gx EDITOR nvim

set -gx nvm_default_version v20.0.0

set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH

set -gx PATH node_modules/.bin $PATH

set -gx TERM xterm-256color

# NVM
function __check_rvm --on-variable PWD --description 'Do nvm stuff'
    status --is-command-substitution; and return

    if test -f .nvmrc; and test -r .nvmrc;
        nvm use
    else
    end
end

if status is-interactive
end
