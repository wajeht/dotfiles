export PATH="/usr/local/sbin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# this is PS1 theme 
ZSH_THEME="powerlevel10k/powerlevel10k"

# plugs in for zsh
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
)

# oh-my-zsh.sh sources all the *.zsh files in $ZSH_CUSTOM/custom
# - I include: aliases.zsh, functions.zsh, prompt.zsh, ect.
source $ZSH/oh-my-zsh.sh

#  no idea what this is
autoload -U compinit && compinit

# start up 
neofetch

# custom function
function mkcd {
  last=$(eval "echo \$$#")
  if [ ! -n "$last" ]; then
    echo "Enter a directory name"
  elif [ -d $last ]; then
    echo "\`$last' already exists"
  else
    mkdir $@ && cd $last
  fi
}

# clolorize man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
alias batman="man"

# servers
alias myserver="ssh soapwa@www.jaw.cool -p 6969"
alias no_ssh_pass="ssh-add -K ~/.ssh/id_rsa"

# scripts
alias spam="python3 ~/.config/scripts/spam.py"
alias bblogin="python3 ~/.config/scripts/bb_login.py"
alias stay="bash ~/.config/scripts/stay.sh"

#db
alias start_mongo="brew services start mongodb-community"
alias stop_mongo="brew services stop mongodb-community"
alias start_psql="brew services start postgresql"
alias stop_psql="brew services stop postgresql"
alias start_mysql="brew services start mysql"
alias stop_mysql="brew services stop mysql"

# others
alias rmds="find . -name '.DS_Store' -type f -delete"
alias stk="ticker"
alias fun="cd ~/dev/fun"
alias docs="cd ~/dev/docs"
alias udpkg="bash ~/.config/scripts/update.bash"
alias img="imgcat"
alias ytdl="youtube-dl"
alias spec="neofetch"
alias hack="cmatrix"
alias python="/Library/Frameworks/Python.framework/Versions/3.8/bin/python3"
alias ls="lsd -lF"
alias lst="ls --tree"
alias lsa="lsd -lAFh"
alias cat="bat"
alias ix="xcode-select --install"
alias npc="cp -R ~/dev/fun/programming-challenge-starter programming-challenge-starter"
alias pc="cd ~/dev/fun/programming-challenges"
alias lc="cd ~/dev/fun/programming-challenges/leet-code"
alias cw="cd ~/dev/fun/programming-challenges/code-wars"
alias ts="cd ~/dev/fun/test" 
alias dev="cd ~/dev/"
alias dt="cd ~/Desktop" 
# alias cat="bat --theme=OneHalfDark --paging=never"
# this will remove number and line
# alias cat="bat -n -p --theme=TwoDark --paging=never"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

