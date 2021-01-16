# Setup fzf
# ---------
if [[ ! "$PATH" == */home/eliasy/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/eliasy/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/eliasy/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/eliasy/.fzf/shell/key-bindings.zsh"
