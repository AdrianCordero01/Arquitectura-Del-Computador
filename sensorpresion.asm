.data
.eqv PresionControl 0xFFFF0000  # Ejemplo de dirección base
.eqv PresionEstado  0xFFFF0004
.eqv PresionDatos   0xFFFF0008
endline: .asciiz "\n"
msg_estado: .asciiz "Estado Actual: "
msg_error: .asciiz "\n[ALERTA]: Error transitorio en el Sensor de Presion.\n"

.text 

	main:
	# Se guardan los valores en los registros:
	li $s0, PresionControl
	li $s1, PresionEstado
	li $s2, PresionDatos

	jal InicializarSensorPresion

	Leer:

	li $v0, 4
	la $a0, msg_estado
	syscall
	
	lw $t0, 0($s1)
	li $v0, 1
    	move $a0, $t0
    	syscall

	li $v0, 4
	la $a0, endline
	syscall

	jal LeerPresion

	li $v0, 4
	la $a0, msg_estado
	syscall

	lw $t1, 0($s1)
	li $v0, 1
    	move $a0, $t1
    	syscall

	li $v0, 4
	la $a0, endline
	syscall

	li $t2, -1
	beq $t1, $t2, Desactivar

	li $t0, 1
	sw $t0, 0($s1)

	j Leer

	Desactivar:

	li $t0, 0
	sw $t0, 0($s0)

	li $v0, 4
	la $a0, msg_error
	syscall
	
	li $v0, 10
	syscall

	InicializarSensorPresion:
	
	li $t0, 1
	sw $t0, 0($s0)
	
	li $t0, 1
	sw $t0, 0($s1)

	jr $ra

	LeerPresion:
	
	li $t3, 0
	try:
	li $v0, 5
	syscall
	move $t0, $v0 
	sw $t0, 0($s2)
		
	li $t1, -1
	beq $t0, $t1, ERROR

	li $t2, 0
	sw $t2, 0($s1)
	j Return

	ERROR:

	li $t2, -1
	sw $t2, 0($s1)
	bne $t3, $zero, Return
	addi $t3, $t3, 1
	j try

	Return:

	jr $ra

	
	
	
	
