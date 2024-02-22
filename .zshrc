export ZSH_CONFIG="$HOME/.config/zsh"

if [ ! -d "$ZSH_CONFIG" ]; then
	mkdir -p "$ZSH_CONFIG"
fi

binary="$ZSH_CONFIG/libclyde/target/release/libclyde"
if [ -f "$binary" ]; then
	eval "$($binary $ZSH_CONFIG/config.toml)"
else
	pushd $ZSH_CONFIG/libclyde > /dev/null
	cargo build --release
	popd > /dev/null
fi

safesource() {
	if [ -f "$@" ]; then
		. "$@"
	fi
}
safesource "$ZSH_CONFIG/p10k.zsh"
safesource "$XDG_CONFIG_HOME/user-dirs.dirs"

fo() {
	for annoyances in $(pgrep -f "$@"); do
		kill -9 "$annoyances"
	done
}

alias fuckoff=fo

shallowclone() {
	if [ ! -d "$2" ]; then
		git shallowclone --depth=1 --single-branch "$@"
	fi
}

pdir="$ZSH_CONFIG/test/"

shallowclone https://github.com/romkatv/zsh-defer.git $ZSH_CONFIG/test/zsh-defer

# 0-1ms
. $pdir/zsh-defer/zsh-defer.plugin.zsh

pushd $pdir > /dev/null
shallowclone https://github.com/romkatv/powerlevel10k powerlevel10k
shallowclone https://github.com/Aloxaf/fzf-tab fzf-tab
shallowclone https://github.com/zdharma-continuum/fast-syntax-highlighting fast-syntax-highlighting
shallowclone https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions
shallowclone https://github.com/jeffreytse/zsh-vi-mode zsh-vi-mode
shallowclone https://github.com/joshskidmore/zsh-fzf-history-search zsh-fzf-history-search
shallowclone https://github.com/zsh-users/zsh-completions zsh-completions
popd > /dev/null

source $pdir/powerlevel10k/powerlevel10k.zsh-theme

zsh-defer source $pdir/zsh-autosuggestions/zsh-autosuggestions.zsh
zsh-defer source $pdir/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
zsh-defer source $pdir/zsh-vi-mode/zsh-vi-mode.plugin.zsh
# no cost and breaks if defer
source $pdir/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh
zsh-defer source $pdir/fzf-tab/fzf-tab.plugin.zsh
zsh-defer source $pdir/zsh-completions/zsh-completions.plugin.zsh

# 1ms
eval "$(zoxide init zsh)"

alias z=__zoxide_z
alias cd=__zoxide_z

# 6-7ms
autoload -Uz compinit; compinit -C
(autoload -Uz compinit && compinit &)
