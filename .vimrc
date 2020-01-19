
" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2017 Sep 20
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Get the defaults that most users want.
"source $VIMRUNTIME/defaults.vim

" create clipboard from vim to other applications
set clipboard=unnamedplus

" use relative numbers to make walking around easier
set relativenumber
" show absolute number of current line
set number

" split new screens below and to the right of the current screen
set splitbelow
set splitright

"creates insertion of one character then exits insert mode
nnoremap <C-i> i_<Esc>r

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
  endif
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  augroup END

else

  set autoindent " always set autoindenting on

endif " has("autocmd")

" Add plugins - controlled by vim-plug
call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'adelarsq/vim-matchit'
Plug 'jalvesaq/Nvim-R'
call plug#end()



