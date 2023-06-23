e='echo -en'                                     # shortened echo command variable
E='echo -e';
   ESC=$( $e "\033")                             # variable containing escaped value 
#  CLEAR(){ $e "\033c";}                         # clear screen
 CLEAR(){ tput clear;}                           # clear screen
 CIVIS(){ $e "\033[?25l";}                       # hide cursor
 CNORM(){ $e "\033[?12l\033[?25h";}              # show cursor
  TPUT(){ $e "\033[${1};${2}H";}                 # terminal put (x and y position)
COLPUT(){ $e "\033[${1}G";}                      # put text in the same line as the specified column
 COLOR(){ $e "\033[38;5;${1}m";}
  BOLD(){ $e "\033[1m";}
UNBOLD(){ $e "\033[22m";}
  MARK(){ $e "\033[7m";}                         # select current line text
UNMARK(){ $e "\033[27m";}                        # normalize current line text
  DRAW(){ $e "\033%@";echo -en "\033(0";}        # switch to 'garbage' mode to be able to draw
 WRITE(){ $e "\033(B";}                          # return to normal (reset)
#   BLUE(){ $e "\033c\033[0;1m\033[37;44m\033[J";} # clear screen, set background to blue and font to white
     R(){ CLEAR ;stty sane;$e "\ec\e[37;44m\e[J";}
  MENU(){ for each in $(seq 0 $LM);do M${each};done;}
  INIT(){ R;}

reset_color(){ $e "\033[00m";} # tput sgr0 # $e "\033[0;0m"
isFile(){ UNBOLD; reset_color;} # tput sgr0
isDir(){ BOLD; COLOR 4;}
isEmpty(){ BOLD; COLOR 196;}
markItem(){ MARK; [[ ${2} -lt halfWidth ]] && $e "$blankLineL" || $e "$blankLineR"; TPUT ${1} ${2};}
unmarkItem(){ UNMARK; [[ ${2} -lt halfWidth ]] && $e "$blankLineL" || $e "$blankLineR"; TPUT ${1} ${2};}

clearLine(){ TPUT ${1} 1; UNMARK; $e "$blankLineF"; }

checkUpperLimits(){
    if [[ $i -lt 0 ]];then 
        i=$((len-1))
        if [[ filesCount -gt $((height-3)) ]];then
            offsetList=$((filesCount-len))
            displayDir $i "$currentPath"
        fi
    fi
}

checkLowerLImits(){
    if [[ $i -ge $len ]];then
        i=0;
        if [[ filesCount -gt $((height-3)) ]];then
            offsetList=0
            displayDir $i "$currentPath"
        fi
    fi
}

# cambiar la posicion en la lista
POS(){ 
    previ=$i
    prevOffsetList=$offsetList
    index=$((i+1))
    # [[ $((fileCount-len)) -eq 1 ]] && finalLine=$((filesCount)) || finalLine=$((filesCount-1))
    # if [[ index -eq halfLen ]];then prevSelected=$selected;fi
    
    # esta es la logica para mostrar parte de la lista que no se pudo imprimir por falta de espacio vertical
    # toda la explicasion siguiente asumiendo que la lista si es mas grande de lo que se puede mostrar.
    
    # en la primera parte del if nos movemos normal por la lista hasta estar enmedio de la lista (la seleccion esta enmedio),
    # ahora es cuando se activa la parte else if, en donde lo que se mueve es la lista y la seleccion se queda estatica,
    # esto hasta que se mustra la parte inicial o final de la lista (dependiendo si nos movemos hacia abajo o arriba).
    if ( [[ start -eq 0 ]] || [[ end -eq $((filesCount-1)) ]] ) && [[ index -ne halfLen ]] ;then
        if [[ $key == up ]];then ((i--));fi
        if [[ $key == down ]];then ((i++));fi
        checkUpperLimits
        checkLowerLImits
        # if [[ $i -lt 0 ]];then 
        #     i=$((len-1))
        #     if [[ filesCount -ge $((height-3)) ]];then
        #         offsetList=$((filesCount-len))
        #         displayDir $i "$currentPath"
        #     fi
        # fi
        # if [[ $i -ge $len ]];then
        #     i=0;
        #     if [[ filesCount -ge $((height-3)) ]];then
        #         offsetList=0
        #         displayDir $i "$currentPath"
        #     fi
        # fi
    elif [[ filesCount -gt $((height-3)) ]] && [[ index -eq halfLen ]];then
        if [[ $key == up ]];then
            if [[ start -eq 0 ]]; then
                ((i--))
                checkUpperLimits
                # if [[ $i -lt 0 ]];then 
                #     i=$((len-1))
                #     if [[ filesCount -ge $((height-3)) ]];then
                #         offsetList=$((filesCount-len))
                #         displayDir $i "$currentPath"
                #     fi
                # fi
            else
                ((offsetList--))
                auxPrevSelected="$currentPath/${items[${filesIndex[$i]}]}"
                displayDir $i "$currentPath"
                selected="$auxPrevSelected"
                prevSelected="$auxPrevSelected"
            fi
        fi
        if [[ $key == down ]];then
            if [[ end -eq $((filesCount-1)) ]]; then
                ((i++))
                checkLowerLImits
                # if [[ $i -ge $len ]];then
                #     i=0;
                #     if [[ filesCount -ge $((height-3)) ]];then
                #         offsetList=0
                #         displayDir $i "$currentPath"
                #     fi
                # fi
            else
                ((offsetList++))
                auxPrevSelected="$currentPath/${items[${filesIndex[$i]}]}"
                displayDir $i "$currentPath"
                selected="$auxPrevSelected"
                prevSelected="$selected"
            fi
        fi
    elif [[ previ = i ]] && [[ prevOffsetList = offsetList ]];then
        i=0
        offsetList=0
    fi
}

# en caso de que la seleccion cambio, actualizamos la lista
REFRESH(){
    after=$((i+1)); before=$((i-1))
    if [[ $before -lt 0 ]];then before=$((len-1));fi
    if [[ $after -ge $len ]];then after=0;fi
    if [[ $j -lt $i ]];then printItem $before 1; else printItem $after 1;fi
    if [[ $after -eq 0 ]] || [ $before -eq $len ];then printItem $after 1;fi
	j=$i
	printItem $before 1; printItem $after 1
    printItem $i 1
}

refreshSelection(){
    printItem $i 1
}

# ${@: -1} => get last arg
# imprime un articulo de la lista
printItem(){
    # si es menor que la mitad de el tamanio entonces sabemos que es la lista que se va a mostrar en la izq.
    if [[ ${2} -lt halfWidth ]];then
        local offsetY=$((${1}+1+listY)) # obtemenos la cordenada en y de donde se va a imprimir el texto
        TPUT $offsetY ${2}; # ajustamos el cursor a esas cordenadas
        
        [[ $currentPath != / ]] && local itemlocation="$currentPath/${items[${filesIndex[${1}]}]}" || local itemlocation="$currentPath${items[${filesIndex[${1}]}]}"

        # local itemlocation="$currentPath/${items[${filesIndex[${1}]}]}" # obtenemos la ruta completa del archivo
        # if [[ -d $itemlocation ]];then 
        #     # local numChildren=$(ls -U $itemlocation | wc -l)
        #     isDir; 
        # else isFile; fi 

        if [[ -d "$itemlocation" ]];then # si es una carpeta la agrega un color y le ponemos la fuente en negrita
            isDir 
        elif [[ -f "$itemlocation" ]]; then
            isFile
        elif ! [[ -f "$itemlocation" ]] && ! [[ -d "$itemlocation" ]] && [[ "${items[${filesIndex[${1}]}]}" = 'Empty' ]];then
            isEmpty
        fi 

        if [[ ${1} -eq $i ]];then # si conside el indice de la lista con el argumento 1, entonces sabemos que esta seleccionado el archivo 
            [[ -e "$itemlocation" ]] && markItem $offsetY $((${2}+1)) || unmarkItem $offsetY $((${2}+1))
            # solo accedemos si la seleccion es diferente y si estamos en el modo de seleccion normal (cuando lo que se mueve es la seleccion y no la lista)
            if ([[ $prevSelected != $selected ]]) && ( [[ start -eq 0 ]] || [[ end -eq $((filesCount-1)) ]] && [[ index -ne halfLen ]] );then
                prevSelected="$selected"
            fi
            selected="$itemlocation"
            if [[ -d "$selected" ]];then
                leftWidth=$halfWidth
                blankLineR=$(head -c "$leftWidth" /dev/zero | tr '\0' ' ')
            else
                leftWidth=$width
                blankLineR=$(head -c "$leftWidth" /dev/zero | tr '\0' ' ')
            fi
        else 
            unmarkItem $offsetY $((${2}+1))
        fi
        
        # comprobamos si el texto no sobrepasa el tamanio de la lista en horizontal
        original_string="${items[${filesIndex[${1}]}]}" # guardamos el texto en otra variable
        stringLen=${#original_string} # obtenemos el tamanio del la cadena 
        if [[ stringLen -ge leftWidth ]];then # en caso de serlo, recortamos la cadena de texto 
            difference=$((stringLen-leftWidth+1)) # mas uno por el espacio que dejamos a la izq de la lista $((${2}+1))
            string="${original_string:0:$((${#original_string} - difference))}"
        else # caso contrario la dejamos igual
            string="${items[${filesIndex[${1}]}]}"
        fi
        if [[ $cur = multi ]];then
            local isSelected=0
            for each in ${multiSelected[@]};do
                if [[ ${filesIndex[${1}]} -eq each ]];then
                    isSelected=1
                fi
            done
            if [[ isSelected -eq 1 ]];then
                $e "[#] $string"
            else
                $e "[ ] $string"
            fi
        else
            $e $string
        fi
        # TPUT $height 1; UNMARK; $e "$blankLineT"
        # TPUT $height 1; BOLD; COLOR 226; $e "$prevCur/$cur"
    else
        local offsetY=$((${1}+1+listY))
        TPUT $offsetY ${2};
        local itemlocation="$selected/${children[${1}]}"
        if [[ -d $itemlocation ]];then #si es una carpeta la agrega un color
            isDir 
        elif [[ -f $itemlocation ]]; then
            isFile
        elif ! [[ -f $itemlocation ]] && ! [[ -d $itemlocation ]] && ( [[ "${children[${1}]}" = 'Empty' ]] || [[ "${children[${1}]}" = 'Inaccessible' ]]);then
            isEmpty
        fi 
        unmarkItem $offsetY $((${2}+1))
        
        original_string="${children[${1}]}"
        stringLen=${#original_string}
        if [[ stringLen -ge rightWidth ]];then
            difference=$((stringLen-rightWidth+1))
            string="${original_string:0:$((${#original_string} - difference))}"
        else
            string="${children[${1}]}"
        fi
        $e $string
    fi
}

# comandos que necesitan solo una tecla
commandKeys(){
    unset command
    
    case "${key}" in
        $'k' | $'K' | $ESC[A) key=up;;
        $'j' | $'J' | $ESC[B) key=down;;
        $'h' | $'H' | $ESC[D) key=left;;
        $'l' | $'L' | $ESC[C) key=right;;

        $'v') key=multiSelection;;
        $'q' | $'Q') key=exit;;
        $'f' | $'F') key=find;;
        $'n' | $'N') key=next;;
        $'s' | $'S') key=shell;;
        $'b' | $'B') key=back;;
        $'?' ) key=help;;

        $'') key=enter;;
        $'\x1b') key=esc;;
        $'\x17') key=closeTab;;
        $'\x7f') key=backspace;;
        $'\033'?) prefix="a-"; key="${key:1:1}";;
    esac
}

# comprobasion para los comandos que requieren de una combinacion de teclas
checkKeysPressed(){
    if [[ ${#key} -eq 1 ]]; then
        command+=${key}
        TPUT $((height-1)) 1; UNMARK; $e "    "
        TPUT $((height-1)) 1; BOLD; reset_color; $e ":$command"
        if [[ ${#command} -ge 2 ]];then
            
            case "$command" in
                $'yy') key=copy;;
                $'dd') key=cut;;
                $'yy') key=copy;;
                $'pp') key=pasten;;
                $'po') key=pastef;;
                $'aa') key=rename;;
                $'tt') key=emp;;
                $'uu') key=unp;;
                $'cd') key=createD;;
                $'cf') key=createF;;
                $'dD') key=sup;;
                *) 
                    commandKeys
                    # TPUT $((height-1)) 1; UNMARK; $e "    "
                    # TPUT $((height-1)) 1; BOLD; reset_color; $e ":"
                ;;
            esac
            unset command
        fi
    else
        commandKeys
        # TPUT $((height-1)) 1; UNMARK; $e "$blankLineF"
        # TPUT $((height-1)) 1; BOLD; reset_color; $e ":"
    fi
}

# logica para la precion de teclas
INPUT(){
    IFS= read -rsn1 key 2>/dev/null >&2
    read -sN1 -t 0.0001 k1; read -sN1 -t 0.0001 k2; read -sN1 -t 0.0001 k3 2>/dev/null >&2
    key+="${k1}${k2}${k3}"

    if [[ ${#command} -eq 0 ]];then 
        commandKeys
    fi

  	echo "${prefix}${key}"
}

getTypeInput(){
    CNORM
    stty sane
    set -o emacs
    bind '"\C-w": kill-whole-line'
    bind '"\e": "\C-w\C-d"'
    TPUT $((height-1)) 1; reset_color
    read -e -p "${1}: " -i "${2}" typeInput
    stty raw -echo
    CIVIS
    clearLine $((height-1))
}