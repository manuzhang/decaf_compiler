	# standard Decaf preamble 
	.data
TRUE:	.asciiz "true"
FALSE:	.asciiz "false"
SPACE:	.asciiz "Making space for inputed values is fun."
	
	.text
	.align 2
	.globl main
	.globl _PrintInt
	.globl _PrintString
	.globl _PrintBool
	.globl _Alloc
	.globl _StringEqual
	.globl _Halt
	.globl _ReadInteger
	.globl _ReadLine
	
_PrintInt:	
	subu $sp, $sp, 8	# decrement so to make space to save ra, fp
	sw $fp, 8($sp)  	# save fp
	sw $ra, 4($sp)  	# save ra
	addiu $fp, $sp, 8	# set up new fp
	li $v0, 1       	# system call code for print_int
	lw $a0, 4($fp)
	syscall
	move $sp, $fp
	lw $ra, -4($fp)
	lw $fp, 0($fp)
	jr $ra
	
_PrintBool:	
	subu $sp, $sp, 8
	sw $fp, 8($sp)
	sw $ra, 4($sp)
	addiu $fp, $sp, 8
	lw $t1, 4($fp)
	blez $t1, fbr
	li $v0, 4       	# system call for print_str
	la $a0, TRUE
	syscall
	b end
fbr:	li $v0, 4       	# system call for print_str
	la $a0, FALSE
	syscall
end:	move $sp, $fp
	lw $ra, -4($fp)
	lw $fp, 0($fp)
	jr $ra
	
_PrintString:	
	subu $sp, $sp, 8
	sw $fp, 8($sp)
	sw $ra, 4($sp)
	addiu $fp, $sp, 8
	li $v0, 4       	# system call for print_str
	lw $a0, 4($fp)
	syscall
	move $sp, $fp
	lw $ra, -4($fp)
	lw $fp, 0($fp)
	jr $ra
	
_Alloc:	
	subu $sp, $sp, 8
	sw $fp, 8($sp)
	sw $ra, 4($sp)
	addiu $fp, $sp, 8
	li $v0, 9       	# system call for sbrk
	lw $a0, 4($fp)
	syscall
	move $sp, $fp
	lw $ra, -4($fp)
	lw $fp, 0($fp)
	jr $ra
	
_StringEqual:	
	subu $sp, $sp, 8
	sw $fp, 8($sp)
	sw $ra, 4($sp)
	addiu $fp, $sp, 8
	subu $sp, $sp, 4	# decrement sp to make space for return value
	li $v0, 0
	#Determine length string 1
	lw $t0, 4($fp)
	li $t3, 0
bloop1:	lb $t5, ($t0)
	beqz $t5, eloop1
	addi $t0, 1
	addi $t3, 1
	b bloop1
eloop1:	#Determine length string 2
	lw $t1, 8($fp)
	li $t4, 0
bloop2:	lb $t5, ($t1)
	beqz $t5, eloop2
	addi $t1, 1
	addi $t4, 1
	b bloop2
eloop2:	bne $t3, $t4, end1	# check if string lengths are the same
	lw $t0, 4($fp)
	lw $t1, 8($fp)
	li $t3, 0
bloop3:	lb $t5, ($t0)
	lb $t6, ($t1)
	bne $t5, $t6, end1
	addi $t3, 1
	addi $t0, 1
	addi $t1, 1
	bne $t3, $t4, bloop3
eloop3:	li $v0, 1
end1:	move $sp, $fp
	lw $ra, -4($fp)
	lw $fp, 0($fp)
	jr $ra
	
_Halt:	
	li $v0, 10
	syscall
	
_ReadInteger:	
	subu $sp, $sp, 8
	sw $fp, 8($sp)
	sw $ra, 4($sp)
	addiu $fp, $sp, 8
	subu $sp, $sp, 4
	li $v0, 5
	syscall
	move $sp, $fp
	lw $ra, -4($fp)
	lw $fp, 0($fp)
	jr $ra
	
_ReadLine:	
	subu $sp, $sp, 8
	sw $fp, 8($sp)
	sw $ra, 4($sp)
	addiu $fp, $sp, 8
	subu $sp, $sp, 4
	li $a1, 40
	la $a0, SPACE
	li $v0, 8
	syscall
	la $t1, SPACE
bloop4:	lb $t5, ($t1)
	beqz $t5, eloop4
	addi $t1, 1
	b bloop4
eloop4:	addi $t1, -1
	li $t6, 0
	sb $t6, ($t1)
	la $v0, SPACE
	move $sp, $fp
	lw $ra, -4($fp)
	lw $fp, 0($fp)
	jr $ra
	
main:	# BeginFunc 8
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 8	# decrement sp to make space for locals/temps
	# _tmp0 = 1
	li $t0, 1		# load constant value 1 into $t0
	# PushParam _tmp0
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintBool
	# (save modified registers before flow of control change)
	sw $t0, -8($fp)	# spill _tmp0 from $t0 to $fp-8
	jal _PrintBool     	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp1 = 0
	li $t0, 0		# load constant value 0 into $t0
	# PushParam _tmp1
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintBool
	# (save modified registers before flow of control change)
	sw $t0, -12($fp)	# spill _tmp1 from $t0 to $fp-12
	jal _PrintBool     	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
