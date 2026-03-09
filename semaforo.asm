.data
    msg_verde:    .asciiz "\nSemáforo en VERDE, esperando pulsador (tecla 's')...\n"
    msg_activado: .asciiz "Pulsador activado: en 20 segundos el semáforo cambiará a AMARILLO.\n"
    msg_amarillo: .asciiz "Semáforo en AMARILLO, en 10 segundos el semáforo pasará a ROJO.\n"
    msg_rojo:     .asciiz "Semáforo en ROJO, en 30 segundos el semáforo volverá a VERDE.\n"

.text

main:

# ESTADO: VERDE (Esperando pulsador 's')
estado_verde:
    li $v0, 4
    la $a0, msg_verde
    syscall

esperar_tecla:
    # Revisar si hay tecla lista
    lw $t0, 0xffff0000
    andi $t0, $t0, 1
    beq $t0, $zero, esperar_tecla # Si no hay tecla, seguir esperando

    # Leer la tecla
    lw $t1, 0xffff0004
    li $t2, 115                  # Código ASCII de la 's' minúscula
    bne $t1, $t2, esperar_tecla  # Si no es 's', ignorar y seguir esperando

    # Si s presiono 's':
    li $v0, 4
    la $a0, msg_activado
    syscall

    # Temporizador de 20 segundos
    li $a0, 20000                # 20,000 ms
    jal temporizador

# ESTADO: AMARILLO (10 segundos)

estado_amarillo:
    li $v0, 4
    la $a0, msg_amarillo
    syscall

    li $a0, 10000                # 10,000 ms
    jal temporizador

# ESTADO: ROJO (30 segundos)

estado_rojo:
    li $v0, 4
    la $a0, msg_rojo
    syscall

    li $a0, 30000                # 30,000 ms
    jal temporizador

    # Al terminar el rojo, volver al inicio (verde)
    j estado_verde


# SUBRUTINA: Temporizador
# Recibe en $a0 el tiempo a esperar en milisegundos
temporizador:
    move $s0, $a0                # Guardar el tiempo deseado
    li $v0, 30                   # Tiempo inicial
    syscall
    move $s1, $a0                # $s1 = Inicio de la espera

temp_loop:
    li $v0, 30
    syscall
    sub $t0, $a0, $s1            # Calcular tiempo transcurrido
    blt $t0, $s0, temp_loop      # Si transcurrido < deseado, seguir
    
    jr $ra                       # Volver al flujo principal
