; main.asm
section .data
    newline db 10
    option_file db 'option.txt', 0
    result_file db 'resultado.txt', 0
    format db '%d', 0
    scalar dd 5    ; store scalar as double word (32-bit), set to 5 by default

section .bss
    matrix resd 100  ; allocate space for 10x10 matrix
    option resb 1
    file_descriptor resd 1
    result_descriptor resd 1
    buf resb 20

section .text
global _start
extern pmenu

_start:
    ; ...rest of the code...

    call pmenu  ; Call the pmenu function

    ; Open option.txt file to read the user's choice
    mov eax, 5
    mov ebx, option_file
    mov ecx, 0
    int 0x80

    ; Check for error in opening the file
    cmp eax, 0
    jl exit

    mov [file_descriptor], eax

    ; Read the option from option.txt file
    mov eax, 3
    mov ebx, [file_descriptor]
    mov ecx, option
    mov edx, 1
    int 0x80

    ; Close the file
    mov eax, 6
    mov ebx, [file_descriptor]
    int 0x80

    ; Initialize the matrix with some value
    mov ecx, 100     ; 10*10 elements
    mov edi, matrix
    mov eax, 1       ; initialize value
matrix_init:
    mov [edi], eax
    add edi, 4
    loop matrix_init

    ; Perform operations on the matrix depending on the user's choice
    mov al, [option]
    cmp al, '1'
    je add_scalar
    cmp al, '2'
    je multiply_scalar
    cmp al, '3'
    je subtract_scalar
    jne write_to_file  ; If no valid option was selected, skip the operation

add_scalar:
    mov ecx, 100
    mov edi, matrix
    mov ebx, [scalar]
add_loop:
    mov eax, [edi]
    add eax, ebx
    mov [edi], eax
    add edi, 4
    loop add_loop
    jmp write_to_file

multiply_scalar:
    mov ecx, 100
    mov edi, matrix
    mov ebx, [scalar]
multiply_loop:
    mov eax, [edi]
    imul eax, ebx
    mov [edi], eax
    add edi, 4
    loop multiply_loop
    jmp write_to_file

subtract_scalar:
    mov ecx, 100
    mov edi, matrix
    mov ebx, [scalar]
subtract_loop:
    mov eax, [edi]
    sub eax, ebx
    mov [edi], eax
    add edi, 4
    loop subtract_loop

write_to_file:
    ; Open result.txt to write the resulting matrix
    mov eax, 5
    mov ebx, result_file
    mov ecx, 2
    int 0x80

    ; Check for error in opening the file
    cmp eax, 0
    jl exit

    mov [result_descriptor], eax

    mov ecx, 100
    mov edi, matrix
write_loop:
    ; Convert the number to a string using itoa function
    mov eax, [edi]
    mov [buf+15], eax
    mov ebx, buf+15
    mov ecx, 10
    mov edx, buf+4
itoa_loop:
    xor edx, edx
    div ecx
    add edx, '0'
    dec ebx
    mov [ebx], dl
    test eax, eax
    jnz itoa_loop

    ; Write the string to the file
    mov eax, 4
    mov ebx, [result_descriptor]
    mov ecx, ebx
    mov edx, buf+15
    sub edx, ebx
    int 0x80

    ; Write a newline to the file
    mov eax, 4
    mov ebx, [result_descriptor]
    mov ecx, newline
    mov edx, 1
    int 0x80

    add edi, 4
    loop write_loop

exit:
    ; Exit the program
    mov eax, 1
    xor ebx, ebx
    int 0x80
