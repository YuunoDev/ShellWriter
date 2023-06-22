#!/bin/bash
# Path: probs/offset.sh

# Desplazarte en el offset en incrementos de 2
texto="Hola, mundo"
offset=0
le=1

echo $texto | awk -v offset=$offset -v le=$le '{print substr($0, offset, le)}'

