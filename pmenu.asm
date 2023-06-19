; pmenu.asm
section .data
    menu db 'Menu:', 10
         db '1. Suma', 10
         db '2. Multiplicacion', 10
         db '3. Resta', 10
         db '0. Salir', 10
    menu_len equ $ - menu
    option_file db 'option.txt', 0

section .bss
    pmenu_option resb 1
    file_descriptor resd 1

section .text
global pmenu

pmenu:
    ; Print the menu
    mov eax, 4
    mov ebx, 1
    mov ecx, menu
    mov edx, menu_len
    int 0x80

    ; Capture the user option
    mov eax, 3
    mov ebx, 0
    mov ecx, pmenu_option
    mov edx, 1
    int 0x80

    ; Open the file
    mov eax, 5  ; open
    mov ebx, option_file  ; filename
    mov ecx, 2  ; flags (O_WRONLY)
    mov edx, 0666  ; mode
    int 0x80
    mov [file_descriptor], eax  ; save file descriptor

    ; Write to the file
    mov eax, 4  ; write
    mov ebx, [file_descriptor]  ; file descriptor
    mov ecx, pmenu_option  ; data
    mov edx, 1  ; data size
    int 0x80

    ; Close the file
    mov eax, 6  ; close
    mov ebx, [file_descriptor]  ; file descriptor
    int 0x80

    ; Exit the function
    ret
