if [ -f /usr/bin/fastfetch ]; then
	fastfetch
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export SPROMPT="Correct $fg[red]%R$reset_color to $fg[green]%r?$reset_color (Yes, No, Abort, Edit) "
export LIBVIRT_DEFAULT_URI="qemu:///system"

# Add in zsh plugins
source /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

fpath=(/usr/share/zsh/site-functions $fpath)

bindkey "${key[PageUp]}" history-search-backward
bindkey "${key[PageDown]}" history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt correct

# Completion styling
zstyle ':completion:*' menu no

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
alias c='clear'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/zen.toml)"