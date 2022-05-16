#!/bin/sh
# shellcheck disable=SC2059

DIR="$(cd "$(dirname "$0")" && pwd)"

# Install files under in $1/ to $2/ via symlink
install_links() (
    mkdir -p "$HOME/.local/share/bin"
    mkdir -p "$HOME/.local/share/ref"
    mkdir -p "$HOME/.local/bin"

    src="$1"; shift
    dest="$1"; shift

    cd "$src" || return 1
    find . -type f | while read -r fn; do
        ln_src="$(pwd)/$fn"
        ln_dest="$dest/$fn"
        mkdir -p "$(dirname "$ln_dest")"
        echo "$ln_src => $ln_dest"
        ln -s -f "$ln_src" "$ln_dest"
    done
) 

install_links "$DIR/home" "$HOME"
touch ~/.Xresources.dpi

mkdir -p \
    "$HOME/rc.d/sh/pre" \
    "$HOME/rc.d/sh/post" \
    "$HOME/rc.d/bash/post" \
    "$HOME/rc.d/bash/pre" \
    "$HOME/rc.d/zsh/post" \
    "$HOME/rc.d/zsh/pre"

# ---------
# ADDITIONAL PACKAGES
# ---------

( # --- set up tmux ---
    cd "$HOME" || return 1
    if ! [ -d ~/.tmux ]; then
        git clone https://github.com/kflu/.tmux.git
    fi
    ln -s -f .tmux/.tmux.conf "$HOME/.tmux.conf"
    cp "$HOME/.tmux/.tmux.conf.local" "$HOME"

    {
        printf "\n"
        printf "set -g mouse on\n"
        printf "set-option -g history-limit 500000\n"
    } >> "$HOME/.tmux.conf.local"

	# `!` to send selection to shell command
	cat <<'EOF' >> "$HOME/.tmux.conf.local"
bind-key -T copy-mode   !  command-prompt -p "cmd:" "send-keys -X copy-selection-no-clear \; run-shell \"tmux show-buffer | %1\" "
bind-key -T copy-mode-vi   !  command-prompt -p "cmd:" "send-keys -X copy-selection-no-clear \; run-shell \"tmux show-buffer | %1\" "
EOF
)

(  # -- vim settings --
    echo "Installing vim-settings-kfl"
    cd "$HOME" || return 1
    git clone https://github.com/kflu/vim-settings-kfl.git
    sh "$HOME/vim-settings-kfl/install.sh"
)

(  # -- oh my zsh --
    echo "Installing ohmyzsh..."

    CHSH=no \
    RUNZSH=no \
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
)

( # -- fzf --
    echo "Installing fzf..."
    cd "$HOME" || return 1
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
)

( # -- recipes --
    ln -s -f "$DIR/recipes" "$HOME/.recipes"
)

# Update file content enclosed by $marker. If marker enclosure doesn't exist,
# append the enclosure, and put content in it.
# It ensures the $file to exist by touching it.
uppend_file_content() {
    file="$1"; shift
    marker="$1"; shift
    content="$1"; shift

    touch "$file"
    tmp="$file.uppend_file_content.$(date +"%Y%m%d_%H%M%S")"
    cp "$file" "$tmp"
    echo "[uppend_file_content] Backed up to $tmp"

    (
    cat <<EOF

has_marker = False
state = ""
for line in open("$tmp").read().splitlines():
    if not state:
        print(line)
        if "$marker" in line:
            state = "BEGIN"
    elif state == "BEGIN":
        if "$marker" in line:
            state = ""
            has_marker = True
            print("""$content""")
            print(line)  # closing marker
    else:
        assert False, state

if not has_marker:
    print("$marker")
    print("""$content""")
    print("$marker")

EOF
    ) | python3 >"$file"
}

uppend_file_content ~/.profile "# == profile.mine == " "source $DIR/profile.mine"
uppend_file_content ~/.zprofile "# == profile.mine ==" "source $DIR/profile.mine"
uppend_file_content ~/.zshrc "# == zshrc.mine ==" "source $DIR/zshrc.mine"
uppend_file_content ~/.bashrc "# == bashrc.mine ==" "source $DIR/bashrc.mine"
