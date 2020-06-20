#!/bin/bash

VIMRC="https://raw.githubusercontent.com/douglasqsantos/DevOps/master/Misc/vimrc"
GRUVBOX="https://raw.githubusercontent.com/douglasqsantos/DevOps/master/Misc/gruvbox.vim"


[ ! -d "~/.vim/colors" ] && mkdir -p ~/.vim/colors

[ -f "~/.vimrc" ] && mv ~/.vimrc ~/.vimrc.bkp
curl -L ${VIMRC} -o ~/.vimrc

[ -f "~/.vim/colors/gruvbox.vim" ] && mv ~/.vim/colors/gruvbox.vim ~/.vim/colors/gruvbox.vim.bkp
curl -L ${GRUVBOX} -o ~/.vim/colors/gruvbox.vim