.data
.eqv TensionControl 0xFFFF0000  # Ejemplo de dirección base
.eqv TensionEstado  0xFFFF0004
.eqv TensionSistol   0xFFFF0008
.eqv TensionDiastol   0xFFFF000C
endline: .asciiz "\n"
msg_estado: .asciiz "Estado Actual: "
TSistol: .asciiz "Tension sistolica: "
TDiastol: .asciiz "Tension diastolica: "

.text 

	main:
	# Se guardan los valores en los registros:
	li $s0, TensionControl
	li $s1, TensionEstado
	li $s2, TensionSistol
	li $s3, TensionDiastol

	li $t0, 1
	sw $t0, 0($s0)
	
	li $t0, 0
	sw $t0, 0($s1)
	
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

	jal controlador_tension

	move $t3, $v0
	move $t4, $v1

	li $t0, 1
	sw $t0, 0($s1)

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

	li $v0, 4
	la $a0, TSistol
	syscall

	li $v0, 1
    	move $a0, $t3
    	syscall

	li $v0, 4
	la $a0, endline
	syscall

	li $v0, 4
	la $a0, TDiastol
	syscall

	li $v0, 1
    	move $a0, $t4
    	syscall

	li $v0, 4
	la $a0, endline
	syscall

	li $t0, 0
	sw $t0, 0($s1)
	
	li $v0, 10
	syscall

	controlador_tension:
	
	li $v0, 5
	syscall
	move $t0, $v0 
	sw $t0, 0($s2)

	li $v0, 5
	syscall
	move $t1, $v0 
	sw $t1, 0($s3)

	move $v0, $t0
	move $v1, $t1
	
	Return:

	jr $ra

	
	
	
	
