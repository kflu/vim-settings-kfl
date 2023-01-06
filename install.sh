#!/bin/sh

USAGE="$(cat <<EOF
EOF
)"
while getopts 'hv' opt; do case "$opt" in
    v)    set -x ;;
    h|*)  echo "$USAGE" >&2; exit 1 ;;
esac done
shift $((OPTIND-1))

DIR="$( cd "`dirname "$0"`"; pwd )"
vimrc="$HOME/.vimrc"
vimfiles="$HOME/.vim"
 
ln -s -f "$DIR"/COPY_TO_HOME/_vimrc "$vimrc"
mkdir -p "$vimfiles"
# ~/vim-plug is where we put all the plugins managed by vim-plug
# However vim-plug itself is installed into ~/.vim/autoload
mkdir -p "$HOME/vim-plug"

mkdir -p "$vimfiles/autoload" && \
curl -fL \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    >"$vimfiles/autoload/plug.vim"

mkdir -p "$vimfiles/doc" && \
curl -fL \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/doc/plug.txt \
    >"$vimfiles/doc/plug.txt"

case "$(uname -s)" in
    *NT*)
        (
        cd "$HOME"
        ln "$(realpath .vimrc)" "$(realpath _vimrc)"
        cmd /c mklink /d vimfiles .vim
        )
        ;;
esac


# build helptags for vim-plug
vim -es - <<EOF
helptags $HOME/$vimfiles/doc
qa
EOF
