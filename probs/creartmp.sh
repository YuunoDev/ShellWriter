#!/bin/bash

# Crear un archivo temporal

temp_file=$(mktemp client_XXXXX.txt)
echo "Archivo temporal con prefijo personalizado: $temp_file"
cat client_.asm > $temp_file

cat $temp_file
sleep 20
rm $temp_file