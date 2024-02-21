export ZSH_CONFIG="$HOME/.config/zsh"
mkdir -p "$ZSH_CONFIG"

binary="$ZSH_CONFIG/libclyde/target/release/libclyde"
if [ -f "$binary" ]; then
	eval "$($binary $ZSH_CONFIG/config.toml)"
else
	pushd $ZSH_CONFIG/libclyde > /dev/null
	cargo build --release
	popd > /dev/null
fi


. "$ZSH_CONFIG/p10k.zsh"
. "$CONFIG/user-dirs.dirs"

fo() {
	for annoyances in $(pgrep -f "$@"); do
		kill -9 "$annoyances"
	done
}

alias fuckoff=fo

clone() {
	if [ ! -d "$2" ]; then
		git clone --depth=1 --single-branch "$@"
	fi
}

pdir="$ZSH_CONFIG/test/"

clone https://github.com/romkatv/zsh-defer.git $ZSH_CONFIG/test/zsh-defer
. $pdir/zsh-defer/zsh-defer.plugin.zsh

pushd $pdir > /dev/null
clone https://github.com/romkatv/powerlevel10k powerlevel10k
clone https://github.com/Aloxaf/fzf-tab fzf-tab
clone https://github.com/zdharma-continuum/fast-syntax-highlighting fast-syntax-highlighting
clone https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions
clone https://github.com/jeffreytse/zsh-vi-mode zsh-vi-mode
clone https://github.com/joshskidmore/zsh-fzf-history-search zsh-fzf-history-search
clone https://github.com/zsh-users/zsh-completions zsh-completions
popd > /dev/null

source $pdir/powerlevel10k/powerlevel10k.zsh-theme

zsh-defer source $pdir/zsh-autosuggestions/zsh-autosuggestions.zsh
zsh-defer source $pdir/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
zsh-defer source $pdir/zsh-vi-mode/zsh-vi-mode.plugin.zsh
# no cost and breaks if defer
source $pdir/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh
zsh-defer source $pdir/fzf-tab/fzf-tab.plugin.zsh
zsh-defer source $pdir/zsh-completions/zsh-completions.plugin.zsh

autoload -Uz compinit; compinit -C
(autoload -Uz compinit && compinit &)