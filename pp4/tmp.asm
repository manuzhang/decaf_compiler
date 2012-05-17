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
	
main:
	# BeginFunc 176
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 176	# decrement sp to make space for locals/temps
	# _tmp0 = 1
	li $t0, 1		# load constant value 1 into $t0
	# i = _tmp0
	move $t1, $t0		# copy value
	# _tmp1 = 2
	li $t2, 2		# load constant value 2 into $t2
	# j = _tmp1
	move $t3, $t2		# copy value
	# _tmp2 = 10
	li $t4, 10		# load constant value 10 into $t4
	# _tmp3 = 0
	li $t5, 0		# load constant value 0 into $t5
	# _tmp4 = _tmp2 < _tmp3
	slt $t6, $t4, $t5	
	# _tmp5 = _tmp2 == _tmp3
	seq $t7, $t4, $t5	
	# _tmp6 = _tmp4 || _tmp5
	or $s0, $t6, $t7	
	# IfZ _tmp6 Goto _L0
	# (save modified registers before flow of control change)
	sw $t0, -20($fp)	# spill _tmp0 from $t0 to $fp-20
	sw $t1, -8($fp)	# spill i from $t1 to $fp-8
	sw $t2, -24($fp)	# spill _tmp1 from $t2 to $fp-24
	sw $t3, -12($fp)	# spill j from $t3 to $fp-12
	sw $t4, -28($fp)	# spill _tmp2 from $t4 to $fp-28
	sw $t5, -32($fp)	# spill _tmp3 from $t5 to $fp-32
	sw $t6, -36($fp)	# spill _tmp4 from $t6 to $fp-36
	sw $t7, -40($fp)	# spill _tmp5 from $t7 to $fp-40
	sw $s0, -44($fp)	# spill _tmp6 from $s0 to $fp-44
	beqz $s0, _L0	# branch if _tmp6 is zero 
	# _tmp7 = "Decaf runtime error: Array size is <= 0"
	.data			# create string constant marked with label
	_string1: .asciiz "Decaf runtime error: Array size is <= 0"
	.text
	la $t0, _string1	# load label
	# PushParam _tmp7
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -48($fp)	# spill _tmp7 from $t0 to $fp-48
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L0:
	# _tmp8 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp9 = _tmp2 * _tmp8
	lw $t1, -28($fp)	# load _tmp2 from $fp-28 into $t1
	mul $t2, $t1, $t0	
	# _tmp10 = _tmp9 + _tmp8
	add $t3, $t2, $t0	
	# PushParam _tmp10
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t3, 4($sp)	# copy param value to stack
	# _tmp11 = LCall _Alloc
	# (save modified registers before flow of control change)
	sw $t0, -52($fp)	# spill _tmp8 from $t0 to $fp-52
	sw $t2, -56($fp)	# spill _tmp9 from $t2 to $fp-56
	sw $t3, -60($fp)	# spill _tmp10 from $t3 to $fp-60
	jal _Alloc         	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# *(_tmp11) = _tmp2
	lw $t1, -28($fp)	# load _tmp2 from $fp-28 into $t1
	sw $t1, 0($t0) 	# store with offset
	# arr = _tmp11
	move $t2, $t0		# copy value
	# _tmp12 = 2
	li $t3, 2		# load constant value 2 into $t3
	# _tmp13 = i + _tmp12
	lw $t4, -8($fp)	# load i from $fp-8 into $t4
	add $t5, $t4, $t3	
	# _tmp14 = *(arr)
	lw $t6, 0($t2) 	# load with offset
	# _tmp15 = j < _tmp14
	lw $t7, -12($fp)	# load j from $fp-12 into $t7
	slt $s0, $t7, $t6	
	# _tmp16 = -1
	li $s1, -1		# load constant value -1 into $s1
	# _tmp17 = _tmp16 < j
	slt $s2, $s1, $t7	
	# _tmp18 = _tmp17 && _tmp15
	and $s3, $s2, $s0	
	# IfZ _tmp18 Goto _L1
	# (save modified registers before flow of control change)
	sw $t0, -64($fp)	# spill _tmp11 from $t0 to $fp-64
	sw $t2, -16($fp)	# spill arr from $t2 to $fp-16
	sw $t3, -72($fp)	# spill _tmp12 from $t3 to $fp-72
	sw $t5, -68($fp)	# spill _tmp13 from $t5 to $fp-68
	sw $t6, -76($fp)	# spill _tmp14 from $t6 to $fp-76
	sw $s0, -80($fp)	# spill _tmp15 from $s0 to $fp-80
	sw $s1, -84($fp)	# spill _tmp16 from $s1 to $fp-84
	sw $s2, -88($fp)	# spill _tmp17 from $s2 to $fp-88
	sw $s3, -92($fp)	# spill _tmp18 from $s3 to $fp-92
	beqz $s3, _L1	# branch if _tmp18 is zero 
	# _tmp19 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp20 = j * _tmp19
	lw $t1, -12($fp)	# load j from $fp-12 into $t1
	mul $t2, $t1, $t0	
	# _tmp21 = _tmp20 + _tmp19
	add $t3, $t2, $t0	
	# _tmp22 = arr + _tmp21
	lw $t4, -16($fp)	# load arr from $fp-16 into $t4
	add $t5, $t4, $t3	
	# Goto _L2
	# (save modified registers before flow of control change)
	sw $t0, -96($fp)	# spill _tmp19 from $t0 to $fp-96
	sw $t2, -100($fp)	# spill _tmp20 from $t2 to $fp-100
	sw $t3, -104($fp)	# spill _tmp21 from $t3 to $fp-104
	sw $t5, -104($fp)	# spill _tmp22 from $t5 to $fp-104
	b _L2		# unconditional branch
_L1:
	# _tmp23 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string2: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string2	# load label
	# PushParam _tmp23
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -108($fp)	# spill _tmp23 from $t0 to $fp-108
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L2:
	# *(_tmp22) = _tmp13
	lw $t0, -68($fp)	# load _tmp13 from $fp-68 into $t0
	lw $t1, -104($fp)	# load _tmp22 from $fp-104 into $t1
	sw $t0, 0($t1) 	# store with offset
	# _tmp24 = 1
	li $t2, 1		# load constant value 1 into $t2
	# _tmp25 = i + _tmp24
	lw $t3, -8($fp)	# load i from $fp-8 into $t3
	add $t4, $t3, $t2	
	# i = _tmp25
	move $t3, $t4		# copy value
	# _tmp26 = *(arr)
	lw $t5, -16($fp)	# load arr from $fp-16 into $t5
	lw $t6, 0($t5) 	# load with offset
	# _tmp27 = j < _tmp26
	lw $t7, -12($fp)	# load j from $fp-12 into $t7
	slt $s0, $t7, $t6	
	# _tmp28 = -1
	li $s1, -1		# load constant value -1 into $s1
	# _tmp29 = _tmp28 < j
	slt $s2, $s1, $t7	
	# _tmp30 = _tmp29 && _tmp27
	and $s3, $s2, $s0	
	# IfZ _tmp30 Goto _L5
	# (save modified registers before flow of control change)
	sw $t2, -112($fp)	# spill _tmp24 from $t2 to $fp-112
	sw $t3, -8($fp)	# spill i from $t3 to $fp-8
	sw $t4, -116($fp)	# spill _tmp25 from $t4 to $fp-116
	sw $t6, -120($fp)	# spill _tmp26 from $t6 to $fp-120
	sw $s0, -124($fp)	# spill _tmp27 from $s0 to $fp-124
	sw $s1, -128($fp)	# spill _tmp28 from $s1 to $fp-128
	sw $s2, -132($fp)	# spill _tmp29 from $s2 to $fp-132
	sw $s3, -136($fp)	# spill _tmp30 from $s3 to $fp-136
	beqz $s3, _L5	# branch if _tmp30 is zero 
	# _tmp31 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp32 = j * _tmp31
	lw $t1, -12($fp)	# load j from $fp-12 into $t1
	mul $t2, $t1, $t0	
	# _tmp33 = _tmp32 + _tmp31
	add $t3, $t2, $t0	
	# _tmp34 = arr + _tmp33
	lw $t4, -16($fp)	# load arr from $fp-16 into $t4
	add $t5, $t4, $t3	
	# Goto _L6
	# (save modified registers before flow of control change)
	sw $t0, -140($fp)	# spill _tmp31 from $t0 to $fp-140
	sw $t2, -144($fp)	# spill _tmp32 from $t2 to $fp-144
	sw $t3, -148($fp)	# spill _tmp33 from $t3 to $fp-148
	sw $t5, -148($fp)	# spill _tmp34 from $t5 to $fp-148
	b _L6		# unconditional branch
_L5:
	# _tmp35 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string3: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string3	# load label
	# PushParam _tmp35
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -152($fp)	# spill _tmp35 from $t0 to $fp-152
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L6:
	# _tmp36 = *(_tmp34)
	lw $t0, -148($fp)	# load _tmp34 from $fp-148 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp37 = 1
	li $t2, 1		# load constant value 1 into $t2
	# _tmp38 = _tmp36 - _tmp37
	sub $t3, $t1, $t2	
	# _tmp36 = _tmp38
	move $t1, $t3		# copy value
	# _tmp39 = i == _tmp36
	lw $t4, -8($fp)	# load i from $fp-8 into $t4
	seq $t5, $t4, $t1	
	# IfZ _tmp39 Goto _L3
	# (save modified registers before flow of control change)
	sw $t1, -156($fp)	# spill _tmp36 from $t1 to $fp-156
	sw $t2, -160($fp)	# spill _tmp37 from $t2 to $fp-160
	sw $t3, -164($fp)	# spill _tmp38 from $t3 to $fp-164
	sw $t5, -168($fp)	# spill _tmp39 from $t5 to $fp-168
	beqz $t5, _L3	# branch if _tmp39 is zero 
	# _tmp40 = 1
	li $t0, 1		# load constant value 1 into $t0
	# _tmp41 = j + _tmp40
	lw $t1, -12($fp)	# load j from $fp-12 into $t1
	add $t2, $t1, $t0	
	# j = _tmp41
	move $t1, $t2		# copy value
	# Goto _L4
	# (save modified registers before flow of control change)
	sw $t0, -172($fp)	# spill _tmp40 from $t0 to $fp-172
	sw $t1, -12($fp)	# spill j from $t1 to $fp-12
	sw $t2, -176($fp)	# spill _tmp41 from $t2 to $fp-176
	b _L4		# unconditional branch
_L3:
_L4:
	# PushParam i
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $t0, -8($fp)	# load i from $fp-8 into $t0
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# PushParam j
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $t0, -12($fp)	# load j from $fp-12 into $t0
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp42 = 0
	li $t0, 0		# load constant value 0 into $t0
	# Return _tmp42
	move $v0, $t0		# assign return value into $v0
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
