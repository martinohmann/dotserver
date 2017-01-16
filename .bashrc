#!/bin/bash
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

#
# prompt
#
parse_git_dirty() {
  local status
  status=$(git status --ignore-submodules=dirty --porcelain 2> /dev/null | tail -n1)
  [ -n "$status" ] &&  echo -ne " \033[00;33mx\033[00m"
}

venv_prompt() {
  [ -n "$VIRTUAL_ENV" ] && echo -ne " venv:(${VIRTUAL_ENV##*/})"
}

export VIRTUAL_ENV_DISABLE_PROMPT=1

# different prompts for root and normal user
if [ "$(id -u)" -eq 0 ]; then
  PS1="${debian_chroot:+($debian_chroot)}\
\[\033[00;31m\]\u\[\033[00;33m\]@\[\033[00;36m\]\h\[\033[00m\] \[\033[00;33m\]\w\
\[\033[00;31m\]\$(__git_ps1 \" git:(%s)\")\[\033[00;33m\]\$(venv_prompt) \[\033[00;37m\]# \[\033[00m\]"
else
  PS1="${debian_chroot:+($debian_chroot)}\
\[\033[00;32m\]\u\[\033[00;37m\]@\[\033[00;37m\]\h\[\033[00m\] \[\033[00;36m\]\w\
\[\033[00;31m\]\$(__git_ps1 \" git:(%s)\")\[\033[00;33m\]\$(venv_prompt) \[\033[00;37m\]% \[\033[00m\]"
fi

# unset GREP_OPTIONS since it is deprecated
unset GREP_OPTIONS

# complete history using arrow up and arrow down
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

#
# aliases
#
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias home='cd ~'
alias l='ls_color -lah'
alias la='ls_color -a'
alias ll='ls_color -l'
alias lsd='ls -d */'
alias bc='bc -l'
alias less='less -R'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  if [ -r ~/.dircolors ]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

#
# misc functions
#

# colored ls
ls_color() {
  # sed substitutions:
  # - colorize total size (white, underlined)
  # - colorize facl (magenta), hardlinks (red), user (yellow, bold),
  # 		group (yellow), size (green, bold unit), date (blue)
  # - colorize permissions (d/l: blue, u: yellow, g: cyan, o: green)
  # - recolorize unset permissions (black)
  /bin/ls -Fl --color=always "$@" | \
  sed 's/^total.*$/[4;37m&[0m/g
  s/^\([bcdlps-][rwxtsT-]\{9\}\)\(+\?\)\([ ]\+[^ ]\+\)\([ ]\+[^ ]\+\)\([ ]\+[^ ]\+\)\([ ]*[0-9]*[,]\{0,1\}\)\([ ]\+[0-9\.]\+\)\([KMGTPEZY]\?\)\([ ]\+[^ ]\+[ ]\+[^ ]\+[ ]\+[^ ]\+\)/\1[0;35m\2[0;31m\3[1;33m\4[0;33m\5[0;32m\6[1;32m\7[0;32m\8[0;34m\9[0m/g
    s/^\([bcdlps-]\)\([r-]\)\([w-]\)\([xs-]\)\([r-]\)\([w-]\)\([xs-]\)\([r-]\)\([w-]\)/[0;34m\1[0;33m\2[0;33m\3[0;33m\4[0;36m\5[0;36m\6[0;36m\7[0;32m\8[0;32m\9[0;32m/g
    s/\[0;3[4362]m-/[0;30m-[0;0m/g'
}

_fs() { #$1: name,  $2: search regexp, $3: file or directory
  local name=$1
  local grep_opts=-RIne
  [ "$name" = "fsi" ] && grep_opts=-RIine
  shift
  [ $# -lt 1 ] && { echo "usage: $name <regexp> [<directory or file>]"; return; }
  local dir=$2
  [ -z "$dir" ] && dir=$(pwd)

  egrep $grep_opts "$1" "$dir" #2> /dev/null
}

# find string in files recursively
fs() { #$1: search regexp, $2: file or directory
  _fs "$0" "$@"
}

# find string in files recursively (case insensitive)
fsi() { #$1: search regexp, $2: file or directory
  _fs "$0" "$@"
}

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
  # shellcheck source=/dev/null
  . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  # shellcheck disable=SC1091
  . /etc/bash_completion
fi

# setup ssh-agent
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval "$(ssh-agent)" > /dev/null 2>&1
  ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
ssh-add -l > /dev/null || ssh-add > /dev/null

# set editor
export EDITOR=vim
export SUDO_EDITOR=vim
