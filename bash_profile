if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Setting PATH for Python 3.6
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"
export PATH
export PATH="/usr/local/opt/postgresql@12/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/bmartin/.sdkman"
[[ -s "/Users/bmartin/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/bmartin/.sdkman/bin/sdkman-init.sh"

. "$HOME/.local/bin/env"
