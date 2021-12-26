#!/bin/sh

DIR="$( cd "`dirname "$0"`" && pwd )"

err() {
    echo "$1" 2>&1
    exit 1
}

has_git() {
    git --version > /dev/null 2>&1 
}

# Install files under in $1/ to $2/ via symlink
install_links() (
    mkdir -p "$HOME/.local/share/bin"
    mkdir -p "$HOME/.local/share/man"
    mkdir -p "$HOME/.local/bin"

    src="$1"; shift
    dest="$1"; shift

    cd "$src" || return 1
    find . -type f | while read fn; do
        ln_src="`pwd`/$fn"
        ln_dest="$dest/$fn"
        mkdir -p "$( dirname "$ln_dest" )"
        echo "$ln_src => $ln_dest"
        ln -s -f "$ln_src" "$ln_dest"
    done
) 

install_links "$DIR/home" "$HOME"
touch ~/.Xresources.dpi

# ---------
# ADDITIONAL PACKAGES
# ---------

( # --- set up tmux ---
    has_git || err "[err] git not found: cannot set up tmux"
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

mkdir -p \
    "$HOME/rc.d/sh/pre" \
    "$HOME/rc.d/sh/post" \
    "$HOME/rc.d/bash/post" \
    "$HOME/rc.d/bash/pre" \
    "$HOME/rc.d/zsh/post" \
    "$HOME/rc.d/zsh/pre"

# --- Clipboard ----
# This works for v2.7 but not v2.3. I can't find a way to support x11 copy across versions.
# So let's disable it, and use manual xclip trick.
# printf 'bind -Tcopy-mode-vi M-y send -X copy-pipe "xclip -i -sel p -f | xclip -i -sel c" \; display-message "copied to system clipboard"' >> ~/.tmux.conf.local
# printf "\n" >> ~/.tmux.conf.local

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

( # --- youtube-vlc ----
    echo "Installing youtube-vlc..."
    cd "$HOME" || return 1
    has_git || err "[err] git not found: cannot set up youtube-vlc"
    if [ ! -e ~/.youtube-vlc ]; then
        git clone https://github.com/kflu/youtube-vlc.git ~/.youtube-vlc
    fi
    ln -s -f ~/.youtube-vlc/bin/youtube-vlc ~/.local/share/bin
)


if [ ! -f ~/.profile ] || ! grep -q "profile.mine" ~/.profile; then
    printf "\n. $DIR/profile.mine\n" >> ~/.profile
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

