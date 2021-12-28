#!/bin/sh

( # --- youtube-vlc ----
    echo "Installing youtube-vlc..."
    cd "$HOME" || return 1
    if [ ! -e ~/.youtube-vlc ]; then
        git clone https://github.com/kflu/youtube-vlc.git ~/.youtube-vlc
    fi
    ln -s -f ~/.youtube-vlc/bin/youtube-vlc ~/.local/share/bin
)
