##
## ZSH customizations
##

# Path to your oh-my-zsh installation.
export ZSH=/Users/saurabh/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="sj"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git)
plugins=(virtualenvwrapper)

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Command history format
export HISTTIMEFORMAT="%d/%m/%y:%T "

if [ -f ~/.zshrc_squirro ]; then
    source ~/.zshrc_squirro
else
    echo 'Custom Squirro specific alias file does not exist'
fi

source $ZSH/oh-my-zsh.sh

##
## Look and feel of prompt
##

function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}
precmd() { print "" }
local current_dir='${PWD/#$HOME/~}'

# source git display script
source ~/.git-prompt.sh

# decorating RPROMPT with useful info
function get_load() {
  ps -A -o %cpu | awk '{s+=$1} END {print s "%"}' 
  #uptime | awk '{print $11}' | tr ',' ' '
}
RPROMPT='%{$fg_bold[red]%}[$(get_load)%, $(python ~/dotfiles/zsh_shortcuts.py)] %{$fg_bold[green]%}%*%{$reset_color%}'

# colors for bash prompt
export CLICOLOR=1

# colors for `ls` command
export LSCOLORS=ExFxBxDxCxegedabagacad

##
## Development Aliases
##

alias dir='ls -lGFh'

alias u1='cd ..'
alias u2='cd ../../'
alias u3='cd ../../../'
alias u4='cd ../../../..'

alias cp='cp -iv'
alias mv='mv -iv'

alias findfile='find . -iname '

alias nt='mvim --remote-tab'

alias master_submodules='git submodule foreach git pull origin master'
alias update_submodules='git submodule update --init --recursive'

alias grep='grep --color'

alias pwdc= 'pwd | pbcopy'

alias lnosetests="nosetests --logging-filter=-sqlalchemy"

alias curlj='curl -H "Accept: application/json" -H "Content-Type: application/json"'

alias agnt='ag --py --ignore-dir="test*"'

##
## PATH variables
##

export PATH="/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/Library/Frameworks/Python.framework/Versions/2.7/bin:/Users/saurabh/spark-1.5.1/bin:/Users/saurabh/torch/install/bin:/Users/saurabh/.luarocks/bin:/Users/saurabh/torch/install/bin:/Users/saurabh/.virtualenvs/deeplearning/bin:/Library/Frameworks/Python.framework/Versions/2.7/bin:/Users/saurabh/spark-1.5.1/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/saurabh/bin:/Users/saurabh/bin"

# Ensure user-installed binaries take precedence
export PATH=/usr/local/bin:$PATH

export PATH=/Users/saurabh/spark-1.5.1/bin:$PATH
export PATH="$PATH:$HOME/bin"
export PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"

# Needed for ipython qtconsole
export PYTHONPATH=/usr/local/lib/python:$PYTHONPATH

##
## Development functions
##

function json_ready() {
    echo $1 | sed 's/u"/"/' | sed 's/'\''/"/g' | sed 's/[Tt]rue/"True"/' | sed 's/[Ff]alse/"False"/'
}

##
## Docker settings
##
alias ds='docker-machine start default'
alias de='eval $(docker-machine env default)'
alias dst='docker-machine stop default'

##
## `dtags` settings, 'https://github.com/joowani/dtags'
##
command -v dtags-activate > /dev/null 2>&1 && eval "`dtags-activate zsh`"

##
## fzf settings
##

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Use ~~ as the trigger sequence instead of the default **
# export FZF_COMPLETION_TRIGGER='~~'

# Options to fzf command
export FZF_CTRL_R_OPTS="--exact"
# export FZF_COMPLETION_OPTS='+c -x'

#
# Setting ag as the default source for fzf
export FZF_DEFAULT_COMMAND='ag -g "" --ignore-dir="*node_modules*"' 

# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Reference: https://github.com/junegunn/fzf/wiki/examples#opening-files
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# Reference: https://github.com/junegunn/fzf/wiki/examples
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m -e | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}

##
## Git Config
##

# Config for setting up dotfiles git directory
alias config='/usr/bin/git --git-dir=/Users/saurabh/.cfg/ --work-tree=/Users/saurabh'

# Config for setting up Squirro dotfiles git directory
alias config_squirro='/usr/bin/git --git-dir=/Users/saurabh/.cfg_squirro/ --work-tree=/Users/saurabh'

rebase_and_push() {
    git checkout master
    git pull
    git checkout $1
    GIT_SEQUENCE_EDITOR=true git rebase -i origin/master

    # try one without force push
    git push origin $1
}

delete_merged() {
    git checkout master
    git pull
    git branch -d $1
}

fixup() {
    echo Last commit message: $(git log -1 --pretty=oneline)
    # git commit --fixup=$(git log -1 | grep commit | sed  "s/commit //")
    git commit --fixup=$(git rev-parse HEAD)
}

# Taken from: https://jasonneylon.wordpress.com/2011/04/22/opening-github-in-your-browser-from-the-terminal/
# Adapted for typos
# Usage: type `gh`<enter> in bash
gh() {
  giturl=$(git config --get remote.origin.url)
  if [ "$giturl" = "" ]; then
     echo "Not a git repository or no remote.origin.url set"
     exit 1;
  fi

  giturl=${giturl/git\@github\.com\:/https://github.com/}
  giturl=${giturl/\.git/\/compare/}
  branch="$(git symbolic-ref HEAD 2>/dev/null)" ||
  branch="(unnamed branch)"     # detached HEAD
  branch=${branch##refs/heads/}
  param="?expand=1"
  giturl=$giturl/$branch$param
  open $giturl
}

# Git commit history browser:
# Ref: https://gist.github.com/junegunn/f4fca918e937e6bf5bad
fshow() {
  local out shas sha q k
  while out=$(
      git log --graph --color=always \
          --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
      fzf --ansi --multi --no-sort --reverse --query="$q" \
          --print-query --expect=ctrl-d --toggle-sort=\`); do
    q=$(head -1 <<< "$out")
    k=$(head -2 <<< "$out" | tail -1)
    shas=$(sed '1,2d;s/^[^a-z0-9]*//;/^$/d' <<< "$out" | awk '{print $1}')
    [ -z "$shas" ] && continue
    if [ "$k" = ctrl-d ]; then
      git diff --color=always $shas | less -R
    else
      for sha in $shas; do
        git show --color=always $sha | less -R
      done
    fi
  done
}

##
## Miscellaneous
##

export ARCHFLAGS="-arch x86_64"

# Remove recurrring password prompt for ssh key (on Mac)
ssh-add -K ~/.ssh/id_rsa

# Clear network routes after connecting to office vpn
clearroute() {
    sudo ifconfig en0 down
    sudo route flush
    sudo ifconfig en0 up
}
