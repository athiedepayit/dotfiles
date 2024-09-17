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
alias aeroconfig='$EDITOR ~/.config/aerospace/aerospace.toml'

alias pull='git pull origin `git branch --show-current`'
alias push='git push origin `git branch --show-current`'
alias devbranch='git checkout develop'

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
export PS1='\u@\h \w $(__git_ps1 " %s")\n\A \$ '

bind -x '"\C-f":~/.local/bin/sessions.sh'
