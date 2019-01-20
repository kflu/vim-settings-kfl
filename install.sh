SCRIPT=`realpath $0`
DIR=`dirname $SCRIPT`
ln -v -s -f $DIR/.screenrc ~/.screenrc
ln -v -s -f $DIR/.gitconfig ~/.gitconfig
ln -v -s -f $DIR/.Xclients ~/.Xclients
ln -v -s -f $DIR/.Xresources ~/.Xresources
touch ~/.Xresources.dpi

mkdir -v -p ~/.fluxbox
cp $DIR/fluxbox/_init ~/.fluxbox/init  # copy the base init over: only set default style
ln -v -s -f $DIR/fluxbox/keys ~/.fluxbox/keys
ln -v -s -f $DIR/fluxbox/menu ~/.fluxbox/menu
ln -v -s -f $DIR/fluxbox/apps ~/.fluxbox/apps
ln -v -s -f $DIR/fluxbox/startup ~/.fluxbox/startup
ln -v -s -f $DIR/fluxbox/windowmenu ~/.fluxbox/windowmenu
ln -v -s -f -t ~/.fluxbox $DIR/fluxbox/styles

cat $DIR/fluxbox/styles/startrek.tar.gz | tar xzO > $DIR/fluxbox/styles/startrek.gitignore.xpm
ln -v -s -f $DIR/fluxbox/styles/startrek.gitignore.xpm $DIR/fluxbox/styles/Dyne/pixmaps/startrek.gitignore.xpm

mkdir -v -p ~/.urxvt/ext
ln -v -s -f $DIR/.urxvt/ext/font-size ~/.urxvt/ext/font-size

mkdir -v -p ~/install/share/bin
find "$DIR/install/share/bin" -type f -not -name '*~' | while read fn; do
    target="`basename $fn`"
    ln -v -s -f "$fn" "$HOME/install/share/bin/$target"
done

mkdir -v -p ~/install/share/man
# install markdown docs
find "$DIR/install/share/man" -type f -not -name '*~' | while read fn; do
    target="`basename $fn`"
    ln -v -s -f "$fn" "$HOME/install/share/man/$target"
done


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

# setup git
git --version 2>&1 > /dev/null
GIT_FOUND=$?
if [ "$GIT_FOUND" -ne 0 ]; then
    if [ `uname` -eq "Linux" ]; then
        apt-get update && apt-get install git
    fi
fi

# setup tmux
oldpath=`pwd`; cd $HOME
if ! [ -d ~/.tmux ]; then
    git clone https://github.com/kflu/.tmux.git
fi
ln -v -s -f .tmux/.tmux.conf ~/.tmux.conf
cp ~/.tmux/.tmux.conf.local ~
printf "\n"
printf "set -g mouse on\n" >> ~/.tmux.conf.local

mkdir -v -p ~/rc.d/sh/pre \
         ~/rc.d/sh/post \
         ~/rc.d/bash/post \
         ~/rc.d/bash/pre \
         ~/rc.d/zsh/post \
         ~/rc.d/zsh/pre

# This works for v2.7 but not v2.3. I can't find a way to support x11 copy across versions.
# So let's disable it, and use manual xclip trick.
# printf 'bind -Tcopy-mode-vi M-y send -X copy-pipe "xclip -i -sel p -f | xclip -i -sel c" \; display-message "copied to system clipboard"' >> ~/.tmux.conf.local
# printf "\n" >> ~/.tmux.conf.local

cd $oldpath

