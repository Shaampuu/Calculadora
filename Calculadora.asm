;Jorge Simon Nieto Celemin
;Anye



.model small
.stack 100h
.data

;Se declara los mensajes que se mostrarán al usuario.
menuText db 13,10, '1. Sumar', 13,10, '2. Restar', 13,10, '3. Multiplicar', 13,10, '4. Dividir', 13,10, '5. Salir', 13,10, 'Opción: $'
inputNum1 db 13,10, 'Ingrese el primer número: $'
inputNum2 db 13,10, 'Ingrese el segundo número: $'
textoSuma db 13,10, 'La sumamos Es: $'
textoResta db 13,10, 'La Resta Es: $'
textoMultiplicacion db 13,10, 'La Multiplicacion Es: $'
textoDivision db 13,10, 'La Division Es: $'

;Se usa variables para guardar los números ingresados por el usuario y la opción seleccionada.
num1 dw ?
num2 dw ?
opcion db ?
mensajeErrorDivCero db 13,10, 'Error: No se puede dividir por cero.$'

.code
start:
    mov ax, @data
    mov ds, ax

menu_loop:
;Se crea un bucle para la que se ejecute un metodo según la selección sel usuario
    mov ah, 09h
    lea dx, menuText
    int 21h
    ;Se muestra el menú de opciones al usuario.
    mov ah, 01h
    int 21h
    ; Se lee un carácter del teclado.
    sub al, '0'
    mov opcion, al
    ;Se guarda la opción elegida en la variable 'opcion'.

    ;Se solicita el primer número al usuario.
    mov ah, 09h
    lea dx, inputNum1
    int 21h
    ;Se se muestra el mensaje para ingresar el primer número.
    call scan_number
    ;Llamamos a la función que lee un número del ingresado.
    mov num1, ax
    ;Se guarda el número ingresado en la variable 'num1'.

    ;Solicita el segundo número al usuario.
    mov ah, 09h
    lea dx, inputNum2
    int 21h
    ;Muestra el mensaje para ingresar el segundo número.
    call scan_number
    ;Llama a la función que lee el segundo número.
    mov num2, ax

    mov al, opcion
    cmp al, 1
    je sumamos
    cmp al, 2
    je resta
    cmp al, 3
    je multiplicacion
    cmp al, 4
    je division
    cmp al, 5
    je finalizar
    ;Si la opción es 5, salta a finalizar.
    jmp menu_loop
    ;Si ninguna opción válida es seleccionada, reinicia el bucle.

sumamos:
    mov ah, 09h
    lea dx, textoSuma
    int 21h
    ; se muestra el mensaje de sumamos.
    mov ax, num1
    add ax, num2
    ; sumamos los dos números.
    call print_number
    ; se imprime el resultado.
    jmp menu_loop
    ; Regresamos al menú principal.
resta:
    mov ah, 09h
    lea dx, textoResta
    int 21h
    ;Se muestra el mensaje de resta.
    mov ax, num1
    sub ax, num2
    ;Resta el segundo número del primero.
    call print_number
    ; se imprime el resultado.
    jmp menu_loop
    ;Regresa al menú principal.

multiplicacion:
    mov ah, 09h
    lea dx, textoMultiplicacion
    int 21h
    ; se muestra el mensaje de multiplicación.
    mov ax, num1
    mov bx, num2
    imul bx
    ; se multiplica los dos números.
    call print_number
    ; se imprime el resultado.
    jmp menu_loop
    ; Regresamos al menú principal.
division:
    mov ah, 09h
    lea dx, textoDivision
    int 21h
    ;Se muestra el mensaje de división.
    mov ax, num1
    mov bx, num2
    cmp bx, 0
    je division_cero
    ;Verifica si el divisor es cero antes de dividir.
    cwd
    idiv bx
    ;Divide numero 1 entre numero 2.
    call print_number
    ; se imprime el resultado.
    jmp menu_loop
    ;Regresa al menú principal.

division_cero:
    mov ah, 09h
    lea dx, mensajeErrorDivCero
    int 21h
    ;Muestra mensaje de error si el divisor es cero.
    jmp menu_loop
    ;Regresa al menú principal.

finalizar:
    mov ax, 4C00h
    int 21h

scan_number:
    xor ax, ax
    xor bx, bx
    xor cx, cx
    mov ah, 01h
    int 21h
    ; Se lee el caracter desde el teclado.
    cmp al, '-'
    jne check_positive
    ; se comprueba si el nmero es negativo.
    mov bl, 1
    ;indicamso que el número es negativo.
    jmp read_digits
check_positive:
    cmp al, '+'
    jne convert_digit
    ;Comprueba si el número es positivo.
    jmp read_digits

convert_digit:
    sub al, '0'
    ;Convierte el carácter de dígito a su valor numérico.

read_digits:
    mov cl, al
    ;Almacena el primer dígito.

read_next_digit:
    mov ah, 01h
    int 21h
    ;Lee el siguiente carácter.
    cmp al, 13
    je finish_input
    ;Si es Enter, termina la entrada.
    sub al, '0'
    ;Convierte el carácter de dígito a su valor numérico.
    mov dx, 10
    mul dx
    ;Multiplica el valor actual por 10 (desplaza un lugar decimal).
    add al, cl
    ;Añade el nuevo dígito.
    mov cl, al
    ;Actualiza el acumulador de dígitos.
    jmp read_next_digit

finish_input:
    mov ax, cx
    ;Mueve el número final a AX.
    cmp bl, 1
    jne end_scan_number
    neg ax
    ;Convierte el número a negativo si era negativo.

end_scan_number:
    ret
    ;Retorna de la función scan_number.
print_number:
    push ax
    cmp ax, 0
    jge positive_number
    ; se comprueba si el número es positivo.
    push ax
    mov ah, 02h
    mov dl, '-'
    int 21h
    ; se imprime el signo menos si el número es negativo.
    pop ax
    neg ax
    ; convertimos el número a positivo para imprimir.
positive_number:
    xor cx, cx
    mov bx, 10
convert_loop:
    xor dx, dx
    div bx
    ;Divide el número por 10 para separar los dígitos.
    push dx
    inc cx
    cmp ax, 0
    jne convert_loop
    ;Continúa hasta que todos los dígitos sean procesados.

print_digits:
    pop dx
    add dl, '0'
    ;Convierte el dígito a su representación ASCII.
    mov ah, 02h
    int 21h
    ;Imprime el dígito.
    loop print_digits
    ;Repite hasta que todos los dígitos sean impresos.

    pop ax
    ret

end start