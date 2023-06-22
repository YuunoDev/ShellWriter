GLOBAL main

section .bss
  buffer resb 15

section .text

  main:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, len
    int 0x80

    mov eax,3
    mov ebx,0
    mov ecx, buffer
    mov edx, buffer_size
    int 0x80

    mov eax,4
    mov ebx,1
    mov ecx, buffer
    mov edx, buffer_size
    int 0x80
 
  ext:
    mov eax, 1
    mov ebx, 0
    int 0x80

section .data
    msg db "Dame un numero: "
    len equ $-msg
    buffer_size equ 15