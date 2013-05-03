SCRIPT=`readlink -f $0`
DIR=`dirname $SCRIPT`
ln -s -f "$DIR"/COPY_TO_HOME/_vimrc ~/.vimrc
ln -s -f "$DIR"/COPY_TO_HOME/vimfiles ~/.vim
