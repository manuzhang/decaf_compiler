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
	
__Animal.Method1:
	# BeginFunc 8
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 8	# decrement sp to make space for locals/temps
	# _tmp0 = *(this + 4)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 4($t0) 	# load with offset
	# PushParam _tmp0
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -8($fp)	# spill _tmp0 from $t1 to $fp-8
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp1 = *(this + 8)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 8($t0) 	# load with offset
	# PushParam _tmp1
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -12($fp)	# spill _tmp1 from $t1 to $fp-12
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
	# VTable for class Animal
	.data
	.align 2
	Animal:		# label for class Animal vtable
	.word __Animal.Method1
	.text
__Cow.Init:
	# BeginFunc 64
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 64	# decrement sp to make space for locals/temps
	# _tmp2 = 10
	li $t0, 10		# load constant value 10 into $t0
	# _tmp3 = 4
	li $t1, 4		# load constant value 4 into $t1
	# _tmp4 = this + _tmp3
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	add $t3, $t2, $t1	
	# *(_tmp4) = _tmp2
	sw $t0, 0($t3) 	# store with offset
	# _tmp5 = 2
	li $t4, 2		# load constant value 2 into $t4
	# _tmp6 = *(this + 4)
	lw $t5, 4($t2) 	# load with offset
	# _tmp7 = _tmp6 * _tmp5
	mul $t6, $t5, $t4	
	# _tmp8 = 8
	li $t7, 8		# load constant value 8 into $t7
	# _tmp9 = this + _tmp8
	add $s0, $t2, $t7	
	# *(_tmp9) = _tmp7
	sw $t6, 0($s0) 	# store with offset
	# _tmp10 = 28
	li $s1, 28		# load constant value 28 into $s1
	# _tmp11 = 12
	li $s2, 12		# load constant value 12 into $s2
	# _tmp12 = this + _tmp11
	add $s3, $t2, $s2	
	# *(_tmp12) = _tmp10
	sw $s1, 0($s3) 	# store with offset
	# _tmp13 = 0
	li $s4, 0		# load constant value 0 into $s4
	# _tmp14 = 9
	li $s5, 9		# load constant value 9 into $s5
	# _tmp15 = _tmp13 - _tmp14
	sub $s6, $s4, $s5	
	# _tmp16 = 16
	li $s7, 16		# load constant value 16 into $s7
	# _tmp17 = this + _tmp16
	add $t8, $t2, $s7	
	# *(_tmp17) = _tmp15
	sw $s6, 0($t8) 	# store with offset
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__Cow.Method2:
	# BeginFunc 24
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 24	# decrement sp to make space for locals/temps
	# _tmp18 = *(this + 4)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 4($t0) 	# load with offset
	# PushParam _tmp18
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -8($fp)	# spill _tmp18 from $t1 to $fp-8
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp19 = *(this + 8)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 8($t0) 	# load with offset
	# PushParam _tmp19
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -12($fp)	# spill _tmp19 from $t1 to $fp-12
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp20 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# PushParam _tmp20
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -16($fp)	# spill _tmp20 from $t1 to $fp-16
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp21 = *(this + 16)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 16($t0) 	# load with offset
	# PushParam _tmp21
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -20($fp)	# spill _tmp21 from $t1 to $fp-20
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp22 = *(this)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp23 = *(_tmp22 + 4)
	lw $t2, 4($t1) 	# load with offset
	# PushParam this
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# ACall _tmp23
	# (save modified registers before flow of control change)
	sw $t1, -24($fp)	# spill _tmp22 from $t1 to $fp-24
	sw $t2, -28($fp)	# spill _tmp23 from $t2 to $fp-28
	jalr $t2            	# jump to function
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
	.word __Cow.Init
	.word __Animal.Method1
	.word __Cow.Method2
	.text
main:
	# BeginFunc 32
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 32	# decrement sp to make space for locals/temps
	# _tmp24 = 20
	li $t0, 20		# load constant value 20 into $t0
	# PushParam _tmp24
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp25 = LCall _Alloc
	# (save modified registers before flow of control change)
	sw $t0, -12($fp)	# spill _tmp24 from $t0 to $fp-12
	jal _Alloc         	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp26 = Cow
	la $t1, Cow	# load label
	# *(_tmp25) = _tmp26
	sw $t1, 0($t0) 	# store with offset
	# b = _tmp25
	move $t2, $t0		# copy value
	# _tmp27 = *(b)
	lw $t3, 0($t2) 	# load with offset
	# _tmp28 = *(_tmp27)
	lw $t4, 0($t3) 	# load with offset
	# PushParam b
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t2, 4($sp)	# copy param value to stack
	# ACall _tmp28
	# (save modified registers before flow of control change)
	sw $t0, -16($fp)	# spill _tmp25 from $t0 to $fp-16
	sw $t1, -20($fp)	# spill _tmp26 from $t1 to $fp-20
	sw $t2, -8($fp)	# spill b from $t2 to $fp-8
	sw $t3, -24($fp)	# spill _tmp27 from $t3 to $fp-24
	sw $t4, -28($fp)	# spill _tmp28 from $t4 to $fp-28
	jalr $t4            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp29 = *(b)
	lw $t0, -8($fp)	# load b from $fp-8 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp30 = *(_tmp29 + 8)
	lw $t2, 8($t1) 	# load with offset
	# PushParam b
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# ACall _tmp30
	# (save modified registers before flow of control change)
	sw $t1, -32($fp)	# spill _tmp29 from $t1 to $fp-32
	sw $t2, -36($fp)	# spill _tmp30 from $t2 to $fp-36
	jalr $t2            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
