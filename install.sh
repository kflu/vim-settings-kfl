#!/bin/sh
# shellcheck disable=SC2059
set -euf

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
        git clone https://github.com/gpakosz/.tmux.git
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

# {{{ linux-settings-kfl

# Customized left/right pane style, disables funky unicode characters so tmux
# displays properly with double width east asian encodings
tmux_conf_theme_status_left="#S | #{?uptime_y, #{uptime_y}y,}#{?uptime_d, #{uptime_d}d,}#{?uptime_h, #{uptime_h}h,}#{?uptime_m, #{uptime_m}m,} "
tmux_conf_theme_status_right=" %R , %d %b | #{username}#{root} | #{hostname} "

tmux_conf_copy_to_os_clipboard=true
set -sg repeat-time 400                   # increase repeat timeout

# Revert .tmux.conf's use of screen-compatible prefix c-a
set -ug prefix2
unbind C-a

bind-key -T copy-mode   !  command-prompt -p "cmd:" "send-keys -X copy-selection-no-clear \; run-shell \"tmux show-buffer | %1\" "
bind-key -T copy-mode-vi   !  command-prompt -p "cmd:" "send-keys -X copy-selection-no-clear \; run-shell \"tmux show-buffer | %1\" "
# easy swapping panes
bind-key -T prefix  C-s display-panes \; command-prompt -p "<pane1>:,<pane2>:" "swap-pane -s %1 -t %2"

# Make tmux copy mode more persistent:
#
# - copy action does not escape copy mode
# - pressing esc key does not escape copy mode (use 'q' isntead)
#
# Must wrap binding in `run -b 'tmux ...'` in order to override ones already
# defined in .tmux.conf
# See: https://github.com/gpakosz/.tmux/issues/571
run -b 'tmux bind-key -T copy-mode-vi Escape     send-keys -X clear-selection 2> /dev/null || true'
run -b 'tmux bind-key -T copy-mode-vi q          send-keys -X cancel 2> /dev/null || true'
run -b 'tmux bind -T copy-mode-vi y send -X copy-selection 2> /dev/null || true'

# Use ASCII chars for pane separators. -q to noop for older tmux where it's not
# supported
set -gq pane-border-lines simple


# }}} linux-settings-kfl
EOF
)

(  # -- vim settings --
    echo "Installing vim-settings-kfl"
    cd "$HOME" || return 1
    git clone https://github.com/kflu/vim-settings-kfl.git
    sh "$HOME/vim-settings-kfl/install.sh"
) || true

(  # -- oh my zsh --
    echo "Installing ohmyzsh..."

    CHSH=no \
    RUNZSH=no \
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
) || true

( # -- fzf --
    echo "Installing fzf..."
    cd "$HOME" || return 1
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
) || true

( # -- recipes --
    ln -s -f "$DIR/recipes" "$HOME/.recipes"
    ln -s "$DIR/rr" "$HOME/rr"
) || true

# Update file content enclosed by $marker. If marker enclosure doesn't exist,
# append the enclosure, and put content in it.
# It ensures the $file to exist by touching it.
# <this> <file> <marker> <content_in_markers>
uppend_file_content() (
    file="$1"; shift
    marker="$1"; shift
    content="$1"; shift

    touch "$file"
    tmp="$file.uppend_file_content.$(date +"%Y%m%d_%H%M%S")"
    cp "$file" "$tmp"
    echo "[uppend_file_content] Backed up to $tmp"

    (
        has_marker=
        state=
        while read -r line; do
            case "$state" in
                '')
                    echo "$line"
                    { echo "$line" | grep -Fq "$marker"; } && state=BEGIN
                    ;;
                BEGIN)
                    { echo "$line" | grep -Fq "$marker"; } && {
                        state=
                        has_marker=1
                        echo "$content"
                        echo "$line"  # closing marker
                    }
                    ;;
            esac
        done <"$tmp"
        if [ -z "$has_marker" ]; then
            echo "$marker"
            echo "$content"
            echo "$marker"
        fi
    ) >"$file"
)

uppend_file_content ~/.profile "# == profile.mine ==" "source $DIR/profile.mine"
uppend_file_content ~/.zprofile "# == profile.mine ==" "source $DIR/profile.mine"
uppend_file_content ~/.zshrc "# == zshrc.mine ==" "source $DIR/zshrc.mine"
uppend_file_content ~/.bashrc "# == bashrc.mine ==" "source $DIR/bashrc.mine"
