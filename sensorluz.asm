.data
.eqv LUZCONTROL 0xFFFF0000  # Ejemplo de dirección base
.eqv LUZESTADO  0xFFFF0004
.eqv LUZDATOS   0xFFFF0008
endline: .asciiz "\n"
msg_estado: .asciiz "Estado Actual: "
msg_error: .asciiz "\n[ALERTA]: Fallo de Hardware en el Sensor de Luz.\n"

.text 

	main:
	
	# Se guardan los valores en los registros:
	li $s0, LUZCONTROL
	li $s1, LUZESTADO
	li $s2, LUZDATOS

	jal InicializarSensorLuz

	Leer:
	
	# Estado = 1
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

	
	jal LeerLuminosidad

	# Estado = 0
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
	
	# Evaluar estado de error
	li $t2, -1
	beq $t1, $t2, Desactivar

	li $t0, 1
	sw $t0, 0($s1)

	j Leer

	Desactivar:
	
	# Desactivar Sensor
	li $t0, 0
	sw $t0, 0($s0)

	# Mensaje de error
	li $v0, 4
	la $a0, msg_error
	syscall
	
	li $v0, 10
	syscall

	InicializarSensorLuz:
	
	# Modifica LUZCONTROL
	li $t0, 1
	sw $t0, 0($s0)
	# Modifica LUZESTADO
	sw $t0, 0($s1)

	jr $ra

	LeerLuminosidad:

	# Pedir por terminal valor entero
	li $v0, 5
	syscall
	move $t0, $v0 
	sw $t0, 0($s2)
		
	li $t1, 1023
	# Comprobar ERROR
	blt $t0, $zero, ERROR
	bgt $t0, $t1, ERROR
	# Modifica LUZESTADO
	li $t2, 0
	sw $t2, 0($s1)
	j Return

	ERROR:

	li $t2, -1
	sw $t2, 0($s1)

	Return:

	jr $ra

	
	
	
	
