#!/bin/sh

DIR="$( cd "`dirname "$0"`"; pwd )"
ln -s -f "$DIR"/COPY_TO_HOME/_vimrc "$HOME/.vimrc"

# ~/vim-plug is where we put all the plugins managed by vim-plug
# However vim-plug itself is installed into ~/.vim/autoload
mkdir "$HOME/vim-plug"

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

curl -fLo ~/.vim/doc/plug.txt --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/doc/plug.txt

# build helptags for vim-plug
vim -es - <<'EOF'
helptags ~/.vim/doc
qa
EOF
