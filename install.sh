#!/bin/sh
# shellcheck disable=SC2059

DIR="$(cd "$(dirname "$0")" && pwd)"

# Install files under in $1/ to $2/ via symlink
install_links() (
    mkdir -p "$HOME/.local/share/bin"
    mkdir -p "$HOME/.local/share/man"
    mkdir -p "$HOME/.local/bin"

    src="$1"; shift
    dest="$1"; shift

    cd "$src" || return 1
    find . -type f | while read -r fn; do
        ln_src="$(pwd)/$fn"
        ln_dest="$dest/$fn"
        mkdir -p "$(dirname "$ln_dest")"
        echo "$ln_src => $ln_dest"
        ln -s -f "$ln_src" "$ln_dest"
    done
) 

install_links "$DIR/home" "$HOME"
touch ~/.Xresources.dpi

mkdir -p \
    "$HOME/rc.d/sh/pre" \
    "$HOME/rc.d/sh/post" \
    "$HOME/rc.d/bash/post" \
    "$HOME/rc.d/bash/pre" \
    "$HOME/rc.d/zsh/post" \
    "$HOME/rc.d/zsh/pre"

# ---------
# ADDITIONAL PACKAGES
# ---------

( # --- set up tmux ---
    cd "$HOME" || return 1
    if ! [ -d ~/.tmux ]; then
        git clone https://github.com/kflu/.tmux.git
    fi
    ln -s -f .tmux/.tmux.conf "$HOME/.tmux.conf"
    cp "$HOME/.tmux/.tmux.conf.local" "$HOME"

    {
        printf "\n"
        printf "set -g mouse on\n"
    } >> "$HOME/.tmux.conf.local"

	# `!` to send selection to shell command
	cat <<'EOF' >> "$HOME/.tmux.conf.local"
bind-key -T copy-mode   !  command-prompt -p "cmd:" "send-keys -X copy-selection-no-clear \; run-shell \"tmux show-buffer | %1\" "
bind-key -T copy-mode-vi   !  command-prompt -p "cmd:" "send-keys -X copy-selection-no-clear \; run-shell \"tmux show-buffer | %1\" "
EOF
)

(  # -- vim settings --
    echo "Installing vim-settings-kfl"
    cd "$HOME" || return 1
    git clone https://github.com/kflu/vim-settings-kfl.git
    sh "$HOME/vim-settings-kfl/install.sh"
)

(  # -- oh my zsh --
    echo "Installing ohmyzsh..."

    CHSH=no \
    RUNZSH=no \
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
)

( # -- fzf --
    echo "Installing fzf..."
    cd "$HOME" || return 1
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
)

if [ ! -f ~/.profile ] || ! grep -q "profile.mine" ~/.profile; then
    printf "\nsource $DIR/profile.mine\n" >> ~/.profile
fi

if [ ! -f ~/.zprofile ] || ! grep -q "profile.mine" ~/.zprofile; then
    printf "\nsource $DIR/profile.mine\n" >> ~/.zprofile
fi

if [ ! -f ~/.zshrc ] || ! grep -q "zshrc.mine" ~/.zshrc; then
    printf "\nsource $DIR/zshrc.mine\n" >> ~/.zshrc
fi

if [ ! -f ~/.bashrc ] || ! grep -q "bashrc.mine" ~/.bashrc; then
    printf "\nsource $DIR/bashrc.mine\n" >> ~/.bashrc
fi
