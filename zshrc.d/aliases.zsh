alias bi='HOMEBREW_NO_AUTO_UPDATE=1 brew install'
alias bu='HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade'
alias br='for k in `git branch | sed s/^..//`; do echo -e `git log -1 --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" $k --`\\t"$k";done | sort'
alias c='clear'
alias cat='ccat'
# Change to the root level directory the current git repository
alias cdg='cd $(git rev-parse --show-toplevel || pwd)'
alias cdw='cd `find . -type d -name webapp`'
alias code='codium'
alias diff=colordiff
alias find='find -L'
alias gd='git diff'
alias git-behind='git rev-list --left-right --count origin/main...@'
alias gm='git fetch -p && git checkout main && git pull'
alias gmas='git fetch -p && git checkout master && git pull'
alias gpb='git prune-branches'
alias gl='git log --numstat --oneline'
alias gp='git push'
alias gpb='git prune-branches'
alias gs='git st'
alias gso='git remote show origin'
alias get='git'
alias gh='git rev-parse --verify --short HEAD'
alias gw="./gradlew --daemon"
alias jjs='java -jar -Dspring.profiles.active=local `find . -name "*service*.jar"`'
alias jjw='java -jar -Dspring.profiles.active=local `find . -name "*worker*.jar"`'
alias ls='ls -hFG'
alias l='eza'
alias la='eza -la'
alias ll='eza -l'
alias ls='eza'
alias mark='open -a "Marked 2"'
alias mk='minikube'
alias n='npx --no-install'
alias top='top -s 5 -o cpu -stats pid,user,command,cpu,rsize,vsize,threads,state'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias o='open'
alias trim="tr -s \" \" | sed 's/^[ ]//g'"
alias total-files='ls -1 | wc -l | trim'
alias usage='df -h'
alias space='du -Lsh ./*'
alias wt='title ${PWD##*/}'

# Kubernetes CLI specific stuff
alias pods='kubectl get pods -o wide'
alias k='kubectl'

# Function for naming terminal tabs
function title {
    # echo -ne "\e]1;"$*"\a"
    echo -e "\033];"$*"\007"
}

function mcdir() {
  mkdir -p $1 && cd $1
}

# Function to show whole file name with path
function trail {
  echo "$(pwd)/$1"
}

# Function to show just folder names
function dirs {
  for file in `ls`; do
    if [  -d $file ]; then
      echo $file
    fi
  done
}
