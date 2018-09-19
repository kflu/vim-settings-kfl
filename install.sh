#!/usr/bin/env bash

SCRIPT=`realpath $0`
DIR=`dirname $SCRIPT`
ln -s -f "$DIR"/COPY_TO_HOME/_vimrc ~/.vimrc

mkdir ~/vundle
git clone https://github.com/gmarik/Vundle.vim.git ~/vundle/Vundle.vim

mkdir ~/vim-plug
git clone https://github.com/junegunn/vim-plug.git ~/vim-plug
