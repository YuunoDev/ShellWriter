#!/bin/bash

main() {
    temp_file=$(mktemp)
    cat client_.asm > $temp_file
    echo "Archivo temporal creado: $temp_file"
    cat $temp_file
    
}
