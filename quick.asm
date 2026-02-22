.data 
	array: .word 64, 34, 25, 12, 22, 11, 90
	n: .word 7

.text

main:
	
	la $a0, array
	li $a1, 0
	lw $a2, n
	addi $a2, $a2, -1
	
	jal quicksort

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

	
	
	quicksort:
	
	#guardar valores en la pila
	addi $sp, $sp, -16
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $ra, 12($sp)

	move $t0, $a1 	# t1 = i
	move $t1, $a2	# t2 = j
	
	# (izq + der ) / 2
	add $t3, $t0, $t1
	sra $t3, $t3, 1
	
	# array[ (izq -  der ) / 2]	
	sll $t3, $t3, 2
	add $t3, $a0, $t3
	# t2 = elemn
	lw $t2, 0($t3)

	do:
	
	while_1:
	# t4 = array[i]
	sll $t6, $t0, 2
	add $t6, $a0, $t6
	lw $t4, 0($t6)

	bge $t4, $t2, end_while1
	addi $t0, $t0, 1
	j while_1
	
	end_while1:

	while_2:
	# t5 = array[j]
	sll $t7, $t1, 2
	add $t7, $a0, $t7
	lw $t5, 0($t7)
	
	ble $t5, $t2, end_while2
	addi $t1, $t1, -1
	j while_2

	end_while2:

	bgt $t0, $t1, jump1
	# swap
	
	sw $t5, 0($t6)
	sw $t4, 0($t7)
	addi $t0, $t0, 1
	addi $t1, $t1, -1

	jump1:
	
	ble $t0, $t1, do
	
	exit_do:
	
	lw $a1, 4($sp)
	bge $a1, $t1, jump2
	move $a2, $t1 
	jal quicksort
	lw $a0, 0($sp)


	jump2:
	
	lw $a2, 8($sp) 
	bge $t0, $a2, jump3
	move $a1, $t0
	jal quicksort
	lw $a0, 0($sp)
	
	jump3:
	
	lw $a0, 0($sp)
    	lw $a1, 4($sp)
    	lw $a2, 8($sp)
    	lw $ra, 12($sp)
   	addi $sp, $sp, 16
	jr $ra
	 
	
	

	
	
	
