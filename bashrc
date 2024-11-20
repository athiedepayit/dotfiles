eval "$(/opt/homebrew/bin/brew shellenv)"
source /opt/homebrew/etc/bash_completion
source $HOME/.local/share/git-prompt.sh
source $HOME/.local/share/.iterm2_shell_integration.bash

alias todo='$EDITOR ~/Notes/todo.md'
alias daily='$EDITOR ~/Notes/daily/$(date +%Y-%m-%d).md'
alias editrc='$EDITOR ~/.bashrc'
alias vimrc='\vim ~/.vimrc'
alias nvrc='nvim ~/.config/nvim/init.lua'
if command -v nvim > /dev/null; then
	alias vim='nvim'
fi
alias reload='. ~/.bashrc'
alias ls='ls --color=auto'
alias ll='ls -lt'
alias tf='terraform'

alias ffchromepull="cd '$HOME/Library/Application Support/Firefox/Profiles/6vc4lg84.default-release/chrome' && git pull"
alias aeroconfig='$EDITOR ~/.config/aerospace/aerospace.toml'
alias pull='git pull origin `git branch --show-current`'
alias push='git push origin `git branch --show-current`'
alias devbranch='git checkout develop'
alias main='git checkout main && pull'
alias master='git checkout master && pull'

function exitcode() {
    ec=$?
    if [ $ec -eq 0 -o $ec -eq 130 ];then
	printf ""
    else
	printf "\e[1;31m$ec\e[0m "
    fi
}

if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
if ! [[ "$PATH" =~ "$HOME/.cargo/bin" ]]
then
    PATH="$PATH:$HOME/.cargo/bin"
fi
if ! [[ "$PATH" =~ "$HOME/go/bin" ]]
then
    PATH="$PATH:$HOME/go/bin"
fi
export PATH
export EDITOR=nvim
export PS1='$(exitcode)\u@\h \w $(__git_ps1 " %s")\n\A \$ '

bind -x '"\C-f":~/.local/bin/sessions.sh'

alias docker='podman'

alias k=kubectl
alias kctx='kubectl config use-context'
alias kgctx='kubectl config get-contexts'
alias kctest='kubectl config set-context test'

alias km='kubectl -n monitoring'
alias kl='kubectl -n logging'
alias ks='kubectl -n kube-system'
alias ka='kubectl -n argo-workflows'

[ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

