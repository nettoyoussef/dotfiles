# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


###############################################################
#                                                             #
#                     Zsh Main Configuration                  #
#                                                             #
###############################################################


## fix for tramp
# https://emacs.stackexchange.com/questions/47969/trouble-connecting-gnu-emacs-to-work-machine-through-ssh-tramp?rq=1
if [[ "$TERM" == "dumb" ]]; then
   unsetopt zle
   unsetopt prompt_cr
   unsetopt prompt_subst
   unfunction precmd
   unfunction preexec
   PS1='$ '
   return
fi


# Path to my oh-my-zsh installation.
export ZSH="/home/eliasy/.oh-my-zsh"
export TERM="xterm-256color"

#Enabling command completion
### autoload
autoload -U compinit
zstyle ':completion:*' menu yes 
zmodload zsh/complist
# Include hidden files on autocomplete
comp_options+=(globdots)		
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


###############################################################
#                                                             #
#                     Alias and Software                      #
#                        Configuration                        #
#                                                             #
###############################################################

# User configuration
# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

#Postgresql - mudanca de diretorios
export PGHOST=localhost

# necessario para fazer o kdeconnect funcionar
export QT_QPA_PLATFORMTHEME=qt5ct

# files
alias r="ranger"
alias vimrc="vim ~/project_repositories/dotfiles/vim/.vimrc"
alias zshrc="vim ~/project_repositories/dotfiles/zsh/.zshrc"
#alias tmux.conf='vim ~/.tmux.conf'
alias i3='vim ~/project_repositories/dotfiles/i3/i3.config'
alias arch='vim ~/project_repositories/dotfiles/arch_linux'
alias zathurarc='vim ~/project_repositories/dotfiles/zathurarc'
alias rc='vim ~/project_repositories/dotfiles/ranger/rc.conf'
alias rifle='vim ~/project_repositories/dotfiles/ranger/rifle.conf'
alias py='source ~/eliasy_env/bin/activate; python'
alias cedro_tunnel='ssh -L localhost:9000:localhost:8787 eliasy@cedro.lbic.fee.unicamp.br'
alias transcribe='wine "/home/eliasy/.wine/drive_c/Program Files (x86)/Transcribe!/Transcribe.exe"'
alias kdeconnect='/usr/lib/kdeconnectd'


#Configuracao do Gurobi
export GUROBI_HOME="/opt/gurobi811/linux64"
export PATH="${PATH}:${GUROBI_HOME}/bin"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"

#Configuracao texlive
export PATH=/usr/local/texlive/2019/bin/x86_64-linux:$PATH

#Configuracao ranger
export EDITOR=vim
#export TERMCMD=konsole
export TERMCMD=gnome-terminal
alias ranger='ranger' # --choosedir = /home/eliasy/'

# Blocks telemetry from Microsoft on VScode
export DOTNET_CLI_TELEMETRY_OPTOUT=1


# softwares
alias yt='youtube-dl'

# make autojump work
[[ -s /home/eliasy/.autojump/etc/profile.d/autojump.sh ]] && source /home/eliasy/.autojump/etc/profile.d/autojump.sh 

# To use functions with gnu parallel
# Activate env_parallel function (can be done in .zshenv)
. `which env_parallel.zsh`

# Fzf configuration 
# Use , as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER=','
# source the fzf functions
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
export FZF_BASE=/usr/share/fzf
export DISABLE_FZF_KEY_BINDINGS="false"
export FZF_DEFAULT_COMMAND='rg --hidden'

###############################################################
#                                                             #
#                     Oh-My-Zsh Theme and                     #
#                        Configuration                        #
#                                                             #
###############################################################

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="nebirhos"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	colored-man-pages # add color to man pages
	command-not-found # tries to find the package of commands not found
	docker 
	docker-compose  
	extract # stop learning the nonsense of tar, zip, 7z etc
	fzf
	# git - prefer to use magit
	safe-paste # avoid pasting code that automatically runs
)

#########
# all commands related to plugins to oh-my-zsh must come before this line
source $ZSH/oh-my-zsh.sh

# Add local 'pip' to PATH:
# (In your .bashrc, .zshrc etc)
export PATH="${PATH}:${HOME}/.local/bin/"


# Add pywall color support
# pywal colors for the terminal
# Import colorscheme from 'wal' asynchronously
# &   # Run the process in the background.
# ( ) # Hide shell job control messages.
(cat ~/.cache/wal/sequences &)

# Alternative (blocks terminal for 0-3ms)
cat ~/.cache/wal/sequences

# To add support for TTYs this line can be optionally added.
source ~/.cache/wal/colors-tty.sh
##



###############################################################
#                                                             #
#                        Custom Bindings                      #
#                                                             #
###############################################################

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
# this and other ideas copied from luke smith 
# https://github.com/LukeSmithxyz/voidrice/blob/master/.config/zsh/.zshrc
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line


###############################################################
#                                                             #
#                        Custom Functions                     #
#                                                             #
###############################################################

# Rsync fast
rsync_from(){
# --ignore-existing - removed to avoid partial transfer to be reconnected
rsync  --protect-args --partial -azze ssh --info=progress2 --log-file=/home/eliasy/Desktop/backup.log "eliasy@cedro:/home/eliasy/$1" "$2"
}

rsync_from_zpool(){
rsync --protect-args --partial -azze ssh --info=progress2 --log-file=/home/eliasy/Desktop/backup.log "eliasy@cedro:/home/eliasy/zpool/backup_1/$1" "$2"
}


rsync_to(){
rsync --protect-args --partial -azze ssh --info=progress2 --log-file=/home/eliasy/Desktop/backup.log "$1" "eliasy@cedro:/home/eliasy/$2" 
}

rsync_to_zpool(){
rsync --protect-args --partial -azze ssh --info=progress2 --log-file=/home/eliasy/Desktop/backup.log "$1" "eliasy@cedro:/home/eliasy/zpool/backup_1/$2" 
}

# fast grep
fastgrep(){
find ./ -print0 | xargs -0 -r rg -s "$1"
}

# Scan pdfs fast
p () {
    open=xdg-open   # this will open pdf file withthe default PDF viewer on KDE, xfce, LXDE and perhaps on other desktops.

    ag -U -g ".pdf$" \
    | fast-p \ | fzf --read0 --reverse -e -d $'\t'  \
        --preview-window down:80% --preview '
            v=$(echo {q} | tr " " "|"); 
            echo -e {1}"\n"{2} | grep -E "^|$v" -i --color=always;
        ' \
    | cut -z -f 1 -d $'\t' | tr -d '\n' | xargs -r --null $open > /dev/null 2> /dev/null
}


# For emacs vterm
vterm_printf(){
    if [ -n "$TMUX" ]; then
        # Tell tmux to pass the escape sequences through
        # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
    else
        printf "\e]%s\e\\" "$1"
    fi
}

fscan(){
scanimage --device "fujitsu:fi-6140dj:23316" --format=png --progress --batch=scan%03d.png --source "ADF Duplex" --mode Gray --resolution 300 --page-width 224.85 --page-height 320 --overscan=On  --paper-protect=On --bgcolor=Black --buffermode=On  
}

fscan_color(){
scanimage --device "fujitsu:fi-6140dj:23316" --format=png --progress --batch=scan%03d.png --source "ADF Duplex" --mode Color --resolution 300 --page-width 224.85 --page-height 320 --overscan=On  --paper-protect=On --bgcolor=Black --buffermode=On  
}

# --ald=yes
#--swdeskew=yes --swdespeck=1 
#--swcrop=yes
#--hwdeskewcrop=yes

usbstick(){
sudo mount /dev/$1 ~/usbstick -o umask=000
}

magick_resize(){
mogrify -path $2 -filter Triangle -define filter:support=2 -unsharp 0.25x0.08+8.3+0.045 -dither None -posterize 20 -quality 82 -define jpeg:fancy-upsampling=off -define png:compression-filter=5 -define png:compression-level=9 -define png:compression-strategy=1 -define png:exclude-chunk=all -interlace none -colorspace sRGB $1
} 

magick_resize_png(){
mogrify -path $2 -filter Triangle -define filter:support=2 -unsharp 0.25x0.08+8.3+0.045 -dither None -posterize 20 -quality 82 -define jpeg:fancy-upsampling=off -define png:compression-filter=5 -define png:compression-level=9 -define png:compression-strategy=1 -define png:exclude-chunk=all -interlace none -colorspace sRGB -format png  $1
} 

fdu(){
du -h --max-depth=1 | sort -h
}

fmpv(){ 
file=$(echo "$1" | sed s:/home/eliasy/cedro/:/home/eliasy/zpool/backup_1/:)
echo $file
mpv --volume=20  "sftp://eliasy@cedro$file"
}

fncmpcpp(){
# attempts to connect to port
# if already connect, 
# only opens ncmpcpp
# grep -c returns the number of matches
# anything more than one is true
ssh_on=$(ss -anl4 | grep -c 127.0.0.1:8000)
echo "ssh_on=$ssh_on"
if [[ $ssh_on -eq "0" ]]; 
then
ssh -N -L 8000:localhost:80 -L 6601:localhost:6600 eliasy@cedro &>/dev/null &;
fi

# opens mpd 
mpd &

# opens ncmpcpp
ncmpcpp
}

kbd_color(){
sudo kbd-backlight $1 ~/project_repositories/dotfiles/kbd-backlight-config/config
}


ffmpeg_instagram(){

ffmpeg -i $1 -vf scale=640:-1,setsar=1 -c:v libx264 -preset slow -profile:v main -level 3.1 -pix_fmt yuv420p -r 30000/1001 -c:a aac -strict experimental -ar 44100 -ac 1 -b:a 64k -movflags +faststart $2 

}


ffmpeg_instagram_gray(){

ffmpeg -i $1 -vf format=gray,scale=640:-1,setsar=1 -c:v libx264 -preset slow -profile:v main -level 3.1 -pix_fmt yuv420p -r 30000/1001 -c:a aac -strict experimental -ar 44100 -ac 1 -b:a 64k -movflags +faststart $2 

}

ffmpeg_cut(){
ffmpeg -i $1 -ss $2 -to $3 $4 
}

magick_instagram(){
# width 1080 - height is between 566 and 1350 - if not, stretched or shrunk
# height 1080 - width is between 320 and 1080 - if not, stretched or shrunk
# A lot of people say you export in the ratio you want to upload the photo (4x5, 1x1, 3x4 etc. I suggest you stick to 1x1 or 4x5 as this is the most common ratio and with the 4x5 ratio your post takes up the largest amount of space available on Instagram which means more people will see it on the explore page rather than a small 16x9 landscape. Furthermore export your photo as jpeg with a width of 1080 pixel (height should be resized automatically). At last make sure your photo is not larger as roughly 700kb. If it is you can reduce the quality in the export section to about 75%. I haven't figured out yet which file size Instagram allows without reducing the photo quality with its own (shitty) algorithm, but about 700kb seems to be right.
# Last thing if you upload real photos you can sharpen them with a high pass filter in Photoshop before uploading them. There are heaps of tutorials available.


}






# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load the zsh syntax highlighting package; should be last line.
# to install it on arch, just do
# sudo pacman -S zsh-syntax-highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

