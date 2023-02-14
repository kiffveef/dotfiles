set -x XDG_CONFIG_HOME $HOME/.config
set -x RIPGREP_CONFIG_PATH $XDG_CONFIG_HOME/ripgreprc
fish_add_path $HOME/.anyenv/bin
fish_add_path $GOENV_ROOT/bin
fish_add_path $HOME/.cargo/bin

set -x EDITOR nvim

# brew
eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# prompt
starship init fish | source

# anyenv
eval (anyenv init - | source)
