.data
# Definimos el arreglo y su tamaño
array:  .word 64, 34, 25, 12, 22, 11, 90
n:      .word 7

msg_sorted: .asciiz "Arreglo ordenado:\n"

.text

    main:
        # cargar dirección base del arreglo en $a0
        la   $a0, array
        # cargar tamaño n en $a1
        lw   $a1, n

        # llamar a BubbleSort
        jal  BubbleSort

        # imprimir mensaje
        li   $v0, 4
        la   $a0, msg_sorted
        syscall

        # imprimir arreglo ordenado
        la   $t0, array      # base del arreglo
        lw   $t1, n          # tamaño
        li   $t2, 0          # índice i = 0

    print_loop:
        bge  $t2, $t1, end_program

        sll  $t3, $t2, 2     # offset = i * 4
        add  $t4, $t0, $t3
        lw   $a0, 0($t4)

        li   $v0, 1          # syscall print_int
        syscall

        # imprimir espacio
        li   $v0, 11
        li   $a0, 32         # ASCII ' '
        syscall

        addi $t2, $t2, 1     # i++
        j    print_loop

    end_program:
        li   $v0, 10         # syscall exit
        syscall


    ########################################################
    # BubbleSort mejorado
    ########################################################
    BubbleSort:
        addi $sp, $sp, -12
        sw   $ra, 8($sp)
        sw   $s0, 4($sp)
        sw   $s1, 0($sp)

        move $s0, $a0        # s0 = base arreglo
        move $s1, $a1        # s1 = n

        li   $t0, 0          # i = 0

    for_i:
        addi $t2, $s1, -1
        bge  $t0, $t2, end_for_i

        li   $t7, 0          # swapped = false
        li   $t1, 0          # j = 0

    for_j:
        sub  $t2, $s1, $t0
        addi $t2, $t2, -1
        bge  $t1, $t2, check_swapped

        # v[j]
        sll  $t4, $t1, 2
        add  $t4, $s0, $t4
        lw   $t3, 0($t4)

        # v[j+1]
        addi $t6, $t1, 1
        sll  $t6, $t6, 2
        add  $t6, $s0, $t6
        lw   $t5, 0($t6)

        ble  $t3, $t5, no_swap

        # swap
        sw   $t3, 0($t6)
        sw   $t5, 0($t4)
        li   $t7, 1

    no_swap:
        addi $t1, $t1, 1
        j    for_j

        check_swapped:
        beq  $t7, $zero, end_for_i
        addi $t0, $t0, 1
        j    for_i

    end_for_i:
        lw   $s1, 0($sp)
        lw   $s0, 4($sp)
        lw   $ra, 8($sp)
        addi $sp, $sp, 12
        jr   $ra
