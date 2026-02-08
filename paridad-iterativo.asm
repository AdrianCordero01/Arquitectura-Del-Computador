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
		
	li $v1, 0

	bucle:
	beq $a0, $zero, exit
	li $t0, 1
	sub $v1, $t0, $v1
	addi $a0, $a0, -1
	j bucle
	
	exit:
	jr $ra
	
	
