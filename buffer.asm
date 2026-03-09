.data
    buffer:     .space 100          # Espacio para 100 caracteres
    size:       .word 100           # Tamaño máximo del buffer
    msg_inicio: .asciiz "\n--- Iniciando intervalo de 20s (Solo A-Z) ---\n"
    msg_fin:    .asciiz "\n--- Tiempo agotado. Contenido del buffer: ---\n"
    newline:    .asciiz "\n"

.text

main:

loop_infinito:
    li $t7, 0               # $t7 = Índice de escritura (puntero del buffer)
    lw $t8, size            # $t8 = Límite del buffer
    
    # Mostrar mensaje de inicio
    li $v0, 4
    la $a0, msg_inicio
    syscall

    # Obtener tiempo inicial (milisegundos)
    li $v0, 30
    syscall
    move $s0, $a0           # $s0 = Tiempo de inicio

captura_loop:
    # Verificar si pasaron 20 segundos
    li $v0, 30
    syscall
    sub $t0, $a0, $s0       # $t0 = Tiempo transcurrido
    bgt $t0, 20000, imprimir_y_repetir # Si > 20,000ms, salir del bucle

    lw $t1, 0xffff0000      # Leer Receiver Control Register
    andi $t1, $t1, 1        # Aislar el bit Ready
    beq $t1, $zero, captura_loop # Si no hay tecla, volver a chequear tiempo

    lw $t2, 0xffff0004      # Leer Receiver Data Register (el ASCII de la tecla)

    # Solo Mayúsculas (A = 65, Z = 90) ASCII
    blt $t2, 65, captura_loop
    bgt $t2, 90, captura_loop

    sb $t2, buffer($t7)     # Guardar en buffer[indice]
    addi $t7, $t7, 1        # Incrementar índice
    
    
    blt $t7, $t8, captura_loop
    li $t7, 0               # Reset índice si se llena el buffer
    j captura_loop

imprimir_y_repetir:
    li $v0, 4
    la $a0, msg_fin
    syscall

    # Imprimir los caracteres capturados (hasta el índice actual)
    li $t1, 0               # Índice de lectura
imprimir_loop:
    beq $t1, $t7, reset_proceso # Si leímos todo lo nuevo, terminar
    
    lb $a0, buffer($t1)     # Cargar caracter
    li $v0, 11              # Syscall para imprimir caracter
    syscall
    
    addi $t1, $t1, 1
    j imprimir_loop

reset_proceso:
    li $v0, 4
    la $a0, newline
    syscall
    j loop_infinito         # Repetir indefinidamente
