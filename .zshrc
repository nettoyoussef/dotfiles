# Path to your oh-my-zsh installation.
export ZSH="/home/eliasy/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="nebirhos"
ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_MODE="nerdfont-complete"

#POWERLEVEL9K_DISABLE_RPROMPT=true
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="▶ "
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""

#Para adicionar uma linha entre prompts
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

#Para alterar a home para um icone
POWERLEVEL9K_CUSTOM_FLAME_ICON="echo "
POWERLEVEL9K_CUSTOM_FLAME_ICON_BACKGROUND=069
POWERLEVEL9K_CUSTOM_FLAME_ICON_FOREGROUND=015

#CONTEXT displays username/hostname
#DIR displays the current working directory, that we can even trim path if we want!
#tirei context dai pra nao ficar muito poluido
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context custom_flame_icon dir vcs)

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Use ~~ as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER=',,'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git docker docker-compose fzf)

source $ZSH/oh-my-zsh.sh

# User configuration
# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

#Postgresql - mudanca de diretorios
export PGHOST=localhost

# necessario para fazer o kdeconnect funcionar
export QT_QPA_PLATFORMTHEME=qt5ct

# files
alias vimrc="vim ~/.vimrc"
alias zshrc="vim ~/.zshrc"
#alias tmux.conf='vim ~/.tmux.conf'
alias i3c='vim ~/.config/i3/config'
alias zathurarc='vim ~/.config/zathura/zathurarc'
alias rc='vim ~/.config/ranger/rc.conf'
alias rifle='vim ~/.config/ranger/rifle.conf'

#Configuracao do Gurobi
export GUROBI_HOME="/opt/gurobi811/linux64"
export PATH="${PATH}:${GUROBI_HOME}/bin"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"

#Configuracao ranger
export EDITOR=vim
#export TERMCMD=konsole
export TERMCMD=gnome-terminal
alias ranger='ranger --choosedir = /home/eliasy/'

# softwares
alias yt='youtube-dl'

# make autojump work
[[ -s /home/eliasy/.autojump/etc/profile.d/autojump.sh ]] && source /home/eliasy/.autojump/etc/profile.d/autojump.sh 

#######################################
#User defined functions
#these functions allow the user to use widgets made by the community
#In my case, I opt to be able to edit the command line with vim like 
#codding.

# vi mode
bindkey -v
#export KEYTIMEOUT=1
#outro formato, escolhendo qual a tecla altera para normal mode
#bindkey 'jk' vi-cmd-mode #aqui voce usa jk para entrar no normal mode

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

### autoload

#Enabling command completion
autoload -U compinit
compinit

### set opt
setopt auto_list

### History
# history
export HISTSIZE=20000
export HISTFILE="$HOME/.zhistory"
export SAVEHIST=$HISTSIZE
setopt extendedhistory      # save timestamps in history
setopt no_histbeep          # don't beep for erroneous history expansions
setopt histignoredups       # ignore consecutive dups in history
setopt histfindnodups       # backwards search produces diff result each time
setopt histreduceblanks     # compact consecutive white space chars (cool)
setopt histnostore          # don't store history related functions
setopt incappendhistory # incrementally add items to HISTFILE

#tira o som
setopt nolistbeep
setopt NO_BEEP 

#Lista variaveis como diretorios
setopt auto_name_dirs #usa os nomes dados em variaveis
setopt cdablevars  #tenta os nomes quando comandos nao foram encontrados

#Mostra o tipo do arquivo
setopt listtypes

#Padroes dos codigos
#zstyle ':completion:history-words:*' remove-all-dups yes
#bindkey "\e/" _history-complete-older
#bindkey "\e," _history-complete-newer
#zle -N no-magic-abbrev-expand




##
# pywal colors for the terminal
# Import colorscheme from 'wal' asynchronously
# &   # Run the process in the background.
# ( ) # Hide shell job control messages.


# Add local 'pip' to PATH:
# (In your .bashrc, .zshrc etc)
export PATH="${PATH}:${HOME}/.local/bin/"

(cat ~/.cache/wal/sequences &)

# Alternative (blocks terminal for 0-3ms)
cat ~/.cache/wal/sequences

# To add support for TTYs this line can be optionally added.
source ~/.cache/wal/colors-tty.sh
##


p () {
    open=xdg-open   # this will open pdf file withthe default PDF viewer on KDE, xfce, LXDE and perhaps on other desktops.

    ag -U -g ".pdf$" \
    | fast-p \
    | fzf --read0 --reverse -e -d $'\t'  \
        --preview-window down:80% --preview '
            v=$(echo {q} | tr " " "|"); 
            echo -e {1}"\n"{2} | grep -E "^|$v" -i --color=always;
        ' \
    | cut -z -f 1 -d $'\t' | tr -d '\n' | xargs -r --null $open > /dev/null 2> /dev/null
}
