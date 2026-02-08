.data
	msg: .asciiz "El numero es par\n"
	msg2: .asciiz "El numero es impar\n"
.text
	li $a0, 5
	
	jal paridad
	
	move $t0, $v1
	
	beq $t0, $zero, par
	
	impar:
	li $v0, 4
	la $a0, msg2
	syscall
	j fin

	par:
	li $v0, 4
	la $a0, msg
	syscall

	fin:
	
	li $v0,10
	syscall

	paridad:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)	

	beq $a0, $zero, base_case
	li $t1, 1
	addi $a0, $a0, -1
	jal paridad
	sub $v1, $t1, $v1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	base_case:
	li $v1, 0
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
