#!/bin/bash
source utilities.sh

shuttingDown(){
    reset_color
    CNORM
    stty sane # regresa a la normalidad la terminal (se ve lo que escribes)
    tput rmcup # echo -e "\e[?1049l"
    rm -r "$tmpPath"
    exit 0
}

main() {
    trap "shuttingDown" 1 2 3 15 # https://mywiki.wooledge.org/SignalTrap
    tput smcup  # echo -e "FileManager\e[?1049h"
    stty raw -echo # command is used to configure the terminal in raw mode, disabling line buffering and disabling character echoing.
    CLEAR
    TPUT 1 1; COLOR 2; BOLD; UNMARK; $e "GNU/Linux File Manager"
    temp_file=$(mktemp)
    cat client_.asm > $temp_file
    echo "Archivo temporal creado: $temp_file"
    cat $temp_file
    sleep 20
    tput rmcup # echo -e "\e[?1049l"
    rm $temp_file
}
