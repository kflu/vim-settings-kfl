#!/bin/sh

DIR="$( cd "`dirname "$0"`" && pwd )"

err() {
    echo "$1" 2>&1
    exit 1
}

has_git() {
    git --version 2>&1 > /dev/null
}

# Install files under in $1/ to $2/ via symlink
install_links() (
    local src="$1"; shift
    local dest="$1"; shift

    cd "$src"
    find . -type f | while read fn; do
        local ln_src="`pwd`/$fn"
        local ln_dest="$dest/$fn"
        mkdir -p "$( dirname "$ln_dest" )"
        echo "$ln_src => $ln_dest"
        ln -s -f "$ln_src" "$ln_dest"
    done
) 

install_links "$DIR/home" "$HOME"
touch ~/.Xresources.dpi

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

# ---------
# ADDITIONAL PACKAGES
# ---------

( # --- set up tmux ---
    has_git || err "[err] git not found: cannot set up tmux"
    cd $HOME
    if ! [ -d ~/.tmux ]; then
        git clone https://github.com/kflu/.tmux.git
    fi
    ln -s -f .tmux/.tmux.conf "$HOME/.tmux.conf"
    cp "$HOME/.tmux/.tmux.conf.local" "$HOME"
    printf "\n" >> "$HOME/.tmux.conf.local"
    printf "set -g mouse on\n" >> "$HOME/.tmux.conf.local"
)

mkdir -v -p \
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

( # --- youtube-vlc ----
    has_git || err "[err] git not found: cannot set up youtube-vlc"
    if [ ! -e ~/.youtube-vlc ]; then
        git clone https://github.com/kflu/youtube-vlc.git ~/.youtube-vlc
    fi
    ln -s -f ~/.youtube-vlc/bin/youtube-vlc ~/install/share/bin/youtube-vlc
)
