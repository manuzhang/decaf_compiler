	# standard Decaf preamble 
	.data
TRUE:
	.asciiz "true"
FALSE:
	.asciiz "false"
SPACE:
	.asciiz "Making space for inputed values is fun."
	
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
fbr:
	li $v0, 4       	# system call for print_str
	la $a0, FALSE
	syscall
end:
	move $sp, $fp
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
bloop1:
	lb $t5, ($t0)
	beqz $t5, eloop1
	addi $t0, 1
	addi $t3, 1
	b bloop1
eloop1:
	#Determine length string 2
	lw $t1, 8($fp)
	li $t4, 0
bloop2:
	lb $t5, ($t1)
	beqz $t5, eloop2
	addi $t1, 1
	addi $t4, 1
	b bloop2
eloop2:
	bne $t3, $t4, end1	# check if string lengths are the same
	lw $t0, 4($fp)
	lw $t1, 8($fp)
	li $t3, 0
bloop3:
	lb $t5, ($t0)
	lb $t6, ($t1)
	bne $t5, $t6, end1
	addi $t3, 1
	addi $t0, 1
	addi $t1, 1
	bne $t3, $t4, bloop3
eloop3:
	li $v0, 1
end1:
	move $sp, $fp
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
bloop4:
	lb $t5, ($t1)
	beqz $t5, eloop4
	addi $t1, 1
	b bloop4
eloop4:
	addi $t1, -1
	li $t6, 0
	sb $t6, ($t1)
	la $v0, SPACE
	move $sp, $fp
	lw $ra, -4($fp)
	lw $fp, 0($fp)
	jr $ra
	
__Cow.Moo:
	# BeginFunc 20
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 20	# decrement sp to make space for locals/temps
	# _tmp0 = i + j
	lw $t0, 8($fp)	# load i from $fp+8 into $t0
	lw $t1, 12($fp)	# load j from $fp+12 into $t1
	add $t2, $t0, $t1	
	# _tmp1 = _tmp0 + k
	lw $t3, 16($fp)	# load k from $fp+16 into $t3
	add $t4, $t2, $t3	
	# _tmp2 = _tmp1 + l
	lw $t5, 20($fp)	# load l from $fp+20 into $t5
	add $t6, $t4, $t5	
	# _tmp3 = _tmp2 + m
	lw $t7, 24($fp)	# load m from $fp+24 into $t7
	add $s0, $t6, $t7	
	# _tmp4 = _tmp3 + n
	lw $s1, 28($fp)	# load n from $fp+28 into $s1
	add $s2, $s0, $s1	
	# Return _tmp4
	move $v0, $s2		# assign return value into $v0
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__Cow.Method:
	# BeginFunc 24
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 24	# decrement sp to make space for locals/temps
	# _tmp5 = 0
	li $t0, 0		# load constant value 0 into $t0
	# IfZ _tmp5 Goto _L0
	# (save modified registers before flow of control change)
	sw $t0, -8($fp)	# spill _tmp5 from $t0 to $fp-8
	beqz $t0, _L0	# branch if _tmp5 is zero 
	# _tmp6 = *(this)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp7 = *(_tmp6 + 4)
	lw $t2, 4($t1) 	# load with offset
	# PushParam a
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $t3, 8($fp)	# load a from $fp+8 into $t3
	sw $t3, 4($sp)	# copy param value to stack
	# PushParam a
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t3, 4($sp)	# copy param value to stack
	# PushParam a
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t3, 4($sp)	# copy param value to stack
	# PushParam a
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t3, 4($sp)	# copy param value to stack
	# PushParam a
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t3, 4($sp)	# copy param value to stack
	# PushParam a
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t3, 4($sp)	# copy param value to stack
	# PushParam this
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp8 = ACall _tmp7
	# (save modified registers before flow of control change)
	sw $t1, -12($fp)	# spill _tmp6 from $t1 to $fp-12
	sw $t2, -16($fp)	# spill _tmp7 from $t2 to $fp-16
	jalr $t2            	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 28
	add $sp, $sp, 28	# pop params off stack
	# Goto _L1
	# (save modified registers before flow of control change)
	sw $t0, -20($fp)	# spill _tmp8 from $t0 to $fp-20
	b _L1		# unconditional branch
_L0:
_L1:
	# _tmp9 = 3
	li $t0, 3		# load constant value 3 into $t0
	# PushParam _tmp9
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t0, -24($fp)	# spill _tmp9 from $t0 to $fp-24
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp10 = 4
	li $t0, 4		# load constant value 4 into $t0
	# PushParam _tmp10
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t0, -28($fp)	# spill _tmp10 from $t0 to $fp-28
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
	# VTable for class Cow
	.data
	.align 2
	Cow:		# label for class Cow vtable
	.word __Cow.Method
	.word __Cow.Moo
	.text
main:
	# BeginFunc 28
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 28	# decrement sp to make space for locals/temps
	# _tmp11 = 4
	li $t0, 4		# load constant value 4 into $t0
	# PushParam _tmp11
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp12 = LCall _Alloc
	# (save modified registers before flow of control change)
	sw $t0, -12($fp)	# spill _tmp11 from $t0 to $fp-12
	jal _Alloc         	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp13 = Cow
	la $t1, Cow	# load label
	# *(_tmp12) = _tmp13
	sw $t1, 0($t0) 	# store with offset
	# c = _tmp12
	move $t2, $t0		# copy value
	# _tmp14 = *(c)
	lw $t3, 0($t2) 	# load with offset
	# _tmp15 = *(_tmp14)
	lw $t4, 0($t3) 	# load with offset
	# _tmp16 = 6
	li $t5, 6		# load constant value 6 into $t5
	# PushParam _tmp16
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t5, 4($sp)	# copy param value to stack
	# PushParam c
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t2, 4($sp)	# copy param value to stack
	# ACall _tmp15
	# (save modified registers before flow of control change)
	sw $t0, -16($fp)	# spill _tmp12 from $t0 to $fp-16
	sw $t1, -20($fp)	# spill _tmp13 from $t1 to $fp-20
	sw $t2, -8($fp)	# spill c from $t2 to $fp-8
	sw $t3, -24($fp)	# spill _tmp14 from $t3 to $fp-24
	sw $t4, -28($fp)	# spill _tmp15 from $t4 to $fp-28
	sw $t5, -32($fp)	# spill _tmp16 from $t5 to $fp-32
	jalr $t4            	# jump to function
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
