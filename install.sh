#!/bin/sh
set -e

DIR="$( cd "`dirname "$0"`"; pwd )"
case "$(uname -s)" in
    *NT*)
        vimrc="$HOME/_vimrc"
        vimfiles="$HOME/vimfiles"
        ;;
    *)
        vimrc="$HOME/.vimrc"
        vimfiles="$HOME/.vim"
        ;;
esac

ln -s -f "$DIR"/COPY_TO_HOME/_vimrc "$vimrc"
mkdir -p "$vimfiles"
# ~/vim-plug is where we put all the plugins managed by vim-plug
# However vim-plug itself is installed into ~/.vim/autoload
mkdir -p "$HOME/vim-plug"

mkdir -p "$vimfiles/autoload" && \
curl -fLo "$vimfiles/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

mkdir -p "$vimfiles/doc" && \
curl -fLo "$vimfiles/doc/plug.txt" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/doc/plug.txt

# build helptags for vim-plug
vim -es - <<EOF
helptags $HOME/$vimfiles/doc
qa
EOF
