# Record each line as it gets issued
PROMPT_COMMAND="history -a"
HISTSIZE=500000
HISTFILESIZE=100000
export HISTIGNORE="&:ls:l:la:ll:exit"
bindkey '"\e[A"' history-search-backward # up arrow
bindkey '"\e[B"' history-search-forward  # down arrow
