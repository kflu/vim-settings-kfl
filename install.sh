#!/bin/sh

DIR="$( cd "`dirname "$0"`"; pwd )"
ln -s -f "$DIR"/COPY_TO_HOME/_vimrc "$HOME/.vimrc"

# cloning vim-plug repo into `autoload` folder because vim-plug repo has 
# `plug.vim` in the repo's root (this is different than Vundle)
mkdir ~/vim-plug/vim-plug
git clone https://github.com/junegunn/vim-plug.git ~/vim-plug/vim-plug/autoload
