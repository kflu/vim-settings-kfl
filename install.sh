#!/bin/bash

SCRIPT=`readlink -f $0`
DIR=`dirname $SCRIPT`
ln -s -f "$DIR"/COPY_TO_HOME/_vimrc ~/.vimrc

mkdir ~/vundle
pushd ~/vundle
git clone https://github.com/gmarik/Vundle.vim.git
popd
