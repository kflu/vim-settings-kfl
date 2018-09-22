SCRIPT=`realpath $0`
DIR=`dirname $SCRIPT`
ln -s -f $DIR/.screenrc ~/.screenrc
ln -s -f $DIR/.gitconfig ~/.gitconfig
ln -s -f $DIR/.Xclients ~/.Xclients
ln -s -f $DIR/.Xresources ~/.Xresources

mkdir -p ~/.fluxbox
ln -s -f $DIR/fluxbox/keys ~/.fluxbox/keys
ln -s -f $DIR/fluxbox/menu ~/.fluxbox/menu
ln -s -f $DIR/fluxbox/apps ~/.fluxbox/apps
ln -s -f $DIR/fluxbox/startup ~/.fluxbox/startup
ln -s -f $DIR/fluxbox/windowmenu ~/.fluxbox/windowmenu

mkdir -p ~/bin
ln -s -f $DIR/bin/fbhtop ~/bin/fbhtop
ln -s -f $DIR/bin/fbterm ~/bin/fbterm

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
ln -s -f .tmux/.tmux.conf ~/.tmux.conf
cp ~/.tmux/.tmux.conf.local ~
printf "\n"
printf "set -g mouse on\n" >> ~/.tmux.conf.local

mkdir -p ~/rc.d/sh/pre \
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

