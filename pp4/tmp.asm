	# standard Decaf preamble 
	.data
TRUE:
	.asciiz "true"
FALSE:
	.asciiz "false"
	
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
	li $t0, 40
	subu $sp, $sp, 4
	sw $t0, 4($sp)
	jal _Alloc
	move $t0, $v0
	li $a1, 40
	move $a0, $t0
	li $v0, 8
	syscall
	move $t1, $t0
bloop4:
	lb $t5, ($t1)
	beqz $t5, eloop4
	addi $t1, 1
	b bloop4
eloop4:
	addi $t1, -1
	li $t6, 0
	sb $t6, ($t1)
	move $v0, $t0
	move $sp, $fp
	lw $ra, -4($fp)
	lw $fp, 0($fp)
	jr $ra
	
__Random.Init:
	# BeginFunc 8
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 8	# decrement sp to make space for locals/temps
	# _tmp0 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp1 = this + _tmp0
	lw $t1, 4($fp)	# load this from $fp+4 into $t1
	add $t2, $t1, $t0	
	# *(_tmp1) = seedVal
	lw $t3, 8($fp)	# load seedVal from $fp+8 into $t3
	sw $t3, 0($t2) 	# store with offset
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__Random.GenRandom:
	# BeginFunc 48
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 48	# decrement sp to make space for locals/temps
	# _tmp2 = 65536
	li $t0, 65536		# load constant value 65536 into $t0
	# _tmp3 = 22221
	li $t1, 22221		# load constant value 22221 into $t1
	# _tmp4 = 10000
	li $t2, 10000		# load constant value 10000 into $t2
	# _tmp5 = *(this + 4)
	lw $t3, 4($fp)	# load this from $fp+4 into $t3
	lw $t4, 4($t3) 	# load with offset
	# _tmp6 = _tmp5 % _tmp4
	rem $t5, $t4, $t2	
	# _tmp7 = 15625
	li $t6, 15625		# load constant value 15625 into $t6
	# _tmp8 = _tmp7 * _tmp6
	mul $t7, $t6, $t5	
	# _tmp9 = _tmp8 + _tmp3
	add $s0, $t7, $t1	
	# _tmp10 = _tmp9 % _tmp2
	rem $s1, $s0, $t0	
	# _tmp11 = 4
	li $s2, 4		# load constant value 4 into $s2
	# _tmp12 = this + _tmp11
	add $s3, $t3, $s2	
	# *(_tmp12) = _tmp10
	sw $s1, 0($s3) 	# store with offset
	# _tmp13 = *(this + 4)
	lw $s4, 4($t3) 	# load with offset
	# Return _tmp13
	move $v0, $s4		# assign return value into $v0
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
__Random.RndInt:
	# BeginFunc 16
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 16	# decrement sp to make space for locals/temps
	# _tmp14 = *(this)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp15 = *(_tmp14)
	lw $t2, 0($t1) 	# load with offset
	# PushParam this
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp16 = ACall _tmp15
	# (save modified registers before flow of control change)
	sw $t1, -12($fp)	# spill _tmp14 from $t1 to $fp-12
	sw $t2, -16($fp)	# spill _tmp15 from $t2 to $fp-16
	jalr $t2            	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp17 = _tmp16 % max
	lw $t1, 8($fp)	# load max from $fp+8 into $t1
	rem $t2, $t0, $t1	
	# Return _tmp17
	move $v0, $t2		# assign return value into $v0
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
	# VTable for class Random
	.data
	.align 2
	Random:		# label for class Random vtable
	.word __Random.GenRandom
	.word __Random.Init
	.word __Random.RndInt
	.text
__Deck.Init:
	# BeginFunc 48
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 48	# decrement sp to make space for locals/temps
	# _tmp18 = 52
	li $t0, 52		# load constant value 52 into $t0
	# _tmp19 = 0
	li $t1, 0		# load constant value 0 into $t1
	# _tmp20 = _tmp18 < _tmp19
	slt $t2, $t0, $t1	
	# _tmp21 = _tmp18 == _tmp19
	seq $t3, $t0, $t1	
	# _tmp22 = _tmp20 || _tmp21
	or $t4, $t2, $t3	
	# IfZ _tmp22 Goto _L0
	# (save modified registers before flow of control change)
	sw $t0, -8($fp)	# spill _tmp18 from $t0 to $fp-8
	sw $t1, -12($fp)	# spill _tmp19 from $t1 to $fp-12
	sw $t2, -16($fp)	# spill _tmp20 from $t2 to $fp-16
	sw $t3, -20($fp)	# spill _tmp21 from $t3 to $fp-20
	sw $t4, -24($fp)	# spill _tmp22 from $t4 to $fp-24
	beqz $t4, _L0	# branch if _tmp22 is zero 
	# _tmp23 = "Decaf runtime error: Array size is <= 0"
	.data			# create string constant marked with label
	_string1: .asciiz "Decaf runtime error: Array size is <= 0"
	.text
	la $t0, _string1	# load label
	# PushParam _tmp23
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -28($fp)	# spill _tmp23 from $t0 to $fp-28
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L0:
	# _tmp24 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp25 = _tmp18 * _tmp24
	lw $t1, -8($fp)	# load _tmp18 from $fp-8 into $t1
	mul $t2, $t1, $t0	
	# _tmp26 = _tmp25 + _tmp24
	add $t3, $t2, $t0	
	# PushParam _tmp26
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t3, 4($sp)	# copy param value to stack
	# _tmp27 = LCall _Alloc
	# (save modified registers before flow of control change)
	sw $t0, -32($fp)	# spill _tmp24 from $t0 to $fp-32
	sw $t2, -36($fp)	# spill _tmp25 from $t2 to $fp-36
	sw $t3, -40($fp)	# spill _tmp26 from $t3 to $fp-40
	jal _Alloc         	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# *(_tmp27) = _tmp18
	lw $t1, -8($fp)	# load _tmp18 from $fp-8 into $t1
	sw $t1, 0($t0) 	# store with offset
	# _tmp28 = 4
	li $t2, 4		# load constant value 4 into $t2
	# _tmp29 = this + _tmp28
	lw $t3, 4($fp)	# load this from $fp+4 into $t3
	add $t4, $t3, $t2	
	# *(_tmp29) = _tmp27
	sw $t0, 0($t4) 	# store with offset
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__Deck.Shuffle:
	# BeginFunc 352
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 352	# decrement sp to make space for locals/temps
	# _tmp30 = 0
	li $t0, 0		# load constant value 0 into $t0
	# _tmp31 = 8
	li $t1, 8		# load constant value 8 into $t1
	# _tmp32 = this + _tmp31
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	add $t3, $t2, $t1	
	# *(_tmp32) = _tmp30
	sw $t0, 0($t3) 	# store with offset
	# (save modified registers before flow of control change)
	sw $t0, -8($fp)	# spill _tmp30 from $t0 to $fp-8
	sw $t1, -12($fp)	# spill _tmp31 from $t1 to $fp-12
	sw $t3, -16($fp)	# spill _tmp32 from $t3 to $fp-16
_L1:
	# _tmp33 = *(this + 8)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 8($t0) 	# load with offset
	# _tmp34 = 52
	li $t2, 52		# load constant value 52 into $t2
	# _tmp35 = _tmp33 < _tmp34
	slt $t3, $t1, $t2	
	# IfZ _tmp35 Goto _L2
	# (save modified registers before flow of control change)
	sw $t1, -20($fp)	# spill _tmp33 from $t1 to $fp-20
	sw $t2, -24($fp)	# spill _tmp34 from $t2 to $fp-24
	sw $t3, -28($fp)	# spill _tmp35 from $t3 to $fp-28
	beqz $t3, _L2	# branch if _tmp35 is zero 
	# _tmp36 = 13
	li $t0, 13		# load constant value 13 into $t0
	# _tmp37 = 1
	li $t1, 1		# load constant value 1 into $t1
	# _tmp38 = *(this + 8)
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	lw $t3, 8($t2) 	# load with offset
	# _tmp39 = _tmp38 + _tmp37
	add $t4, $t3, $t1	
	# _tmp40 = _tmp39 % _tmp36
	rem $t5, $t4, $t0	
	# _tmp41 = *(this + 4)
	lw $t6, 4($t2) 	# load with offset
	# _tmp42 = *(_tmp41)
	lw $t7, 0($t6) 	# load with offset
	# _tmp43 = *(this + 8)
	lw $s0, 8($t2) 	# load with offset
	# _tmp44 = _tmp43 < _tmp42
	slt $s1, $s0, $t7	
	# _tmp45 = -1
	li $s2, -1		# load constant value -1 into $s2
	# _tmp46 = _tmp45 < _tmp43
	slt $s3, $s2, $s0	
	# _tmp47 = _tmp46 && _tmp44
	and $s4, $s3, $s1	
	# IfZ _tmp47 Goto _L3
	# (save modified registers before flow of control change)
	sw $t0, -36($fp)	# spill _tmp36 from $t0 to $fp-36
	sw $t1, -44($fp)	# spill _tmp37 from $t1 to $fp-44
	sw $t3, -48($fp)	# spill _tmp38 from $t3 to $fp-48
	sw $t4, -40($fp)	# spill _tmp39 from $t4 to $fp-40
	sw $t5, -32($fp)	# spill _tmp40 from $t5 to $fp-32
	sw $t6, -52($fp)	# spill _tmp41 from $t6 to $fp-52
	sw $t7, -56($fp)	# spill _tmp42 from $t7 to $fp-56
	sw $s0, -64($fp)	# spill _tmp43 from $s0 to $fp-64
	sw $s1, -60($fp)	# spill _tmp44 from $s1 to $fp-60
	sw $s2, -68($fp)	# spill _tmp45 from $s2 to $fp-68
	sw $s3, -72($fp)	# spill _tmp46 from $s3 to $fp-72
	sw $s4, -76($fp)	# spill _tmp47 from $s4 to $fp-76
	beqz $s4, _L3	# branch if _tmp47 is zero 
	# _tmp48 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp49 = _tmp43 * _tmp48
	lw $t1, -64($fp)	# load _tmp43 from $fp-64 into $t1
	mul $t2, $t1, $t0	
	# _tmp50 = _tmp49 + _tmp48
	add $t3, $t2, $t0	
	# _tmp51 = _tmp41 + _tmp50
	lw $t4, -52($fp)	# load _tmp41 from $fp-52 into $t4
	add $t5, $t4, $t3	
	# Goto _L4
	# (save modified registers before flow of control change)
	sw $t0, -80($fp)	# spill _tmp48 from $t0 to $fp-80
	sw $t2, -84($fp)	# spill _tmp49 from $t2 to $fp-84
	sw $t3, -88($fp)	# spill _tmp50 from $t3 to $fp-88
	sw $t5, -88($fp)	# spill _tmp51 from $t5 to $fp-88
	b _L4		# unconditional branch
_L3:
	# _tmp52 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string2: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string2	# load label
	# PushParam _tmp52
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -92($fp)	# spill _tmp52 from $t0 to $fp-92
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L4:
	# *(_tmp51) = _tmp40
	lw $t0, -32($fp)	# load _tmp40 from $fp-32 into $t0
	lw $t1, -88($fp)	# load _tmp51 from $fp-88 into $t1
	sw $t0, 0($t1) 	# store with offset
	# _tmp53 = 1
	li $t2, 1		# load constant value 1 into $t2
	# _tmp54 = *(this + 8)
	lw $t3, 4($fp)	# load this from $fp+4 into $t3
	lw $t4, 8($t3) 	# load with offset
	# _tmp55 = _tmp54 + _tmp53
	add $t5, $t4, $t2	
	# _tmp56 = 8
	li $t6, 8		# load constant value 8 into $t6
	# _tmp57 = this + _tmp56
	add $t7, $t3, $t6	
	# *(_tmp57) = _tmp55
	sw $t5, 0($t7) 	# store with offset
	# Goto _L1
	# (save modified registers before flow of control change)
	sw $t2, -100($fp)	# spill _tmp53 from $t2 to $fp-100
	sw $t4, -104($fp)	# spill _tmp54 from $t4 to $fp-104
	sw $t5, -96($fp)	# spill _tmp55 from $t5 to $fp-96
	sw $t6, -108($fp)	# spill _tmp56 from $t6 to $fp-108
	sw $t7, -112($fp)	# spill _tmp57 from $t7 to $fp-112
	b _L1		# unconditional branch
_L2:
	# _tmp58 = 8
	li $t0, 8		# load constant value 8 into $t0
	# PushParam _tmp58
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp59 = LCall _Alloc
	# (save modified registers before flow of control change)
	sw $t0, -116($fp)	# spill _tmp58 from $t0 to $fp-116
	jal _Alloc         	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp60 = Random
	la $t1, Random	# load label
	# *(_tmp59) = _tmp60
	sw $t1, 0($t0) 	# store with offset
	# gRnd = _tmp59
	move $t2, $t0		# copy value
	# (save modified registers before flow of control change)
	sw $t0, -120($fp)	# spill _tmp59 from $t0 to $fp-120
	sw $t1, -124($fp)	# spill _tmp60 from $t1 to $fp-124
	sw $t2, 4($gp)	# spill gRnd from $t2 to $gp+4
_L5:
	# _tmp61 = *(this + 8)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 8($t0) 	# load with offset
	# _tmp62 = 0
	li $t2, 0		# load constant value 0 into $t2
	# _tmp63 = _tmp62 < _tmp61
	slt $t3, $t2, $t1	
	# IfZ _tmp63 Goto _L6
	# (save modified registers before flow of control change)
	sw $t1, -128($fp)	# spill _tmp61 from $t1 to $fp-128
	sw $t2, -132($fp)	# spill _tmp62 from $t2 to $fp-132
	sw $t3, -136($fp)	# spill _tmp63 from $t3 to $fp-136
	beqz $t3, _L6	# branch if _tmp63 is zero 
	# _tmp64 = *(gRnd)
	lw $t0, 4($gp)	# load gRnd from $gp+4 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp65 = *(_tmp64 + 8)
	lw $t2, 8($t1) 	# load with offset
	# _tmp66 = *(this + 8)
	lw $t3, 4($fp)	# load this from $fp+4 into $t3
	lw $t4, 8($t3) 	# load with offset
	# PushParam _tmp66
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t4, 4($sp)	# copy param value to stack
	# PushParam gRnd
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp67 = ACall _tmp65
	# (save modified registers before flow of control change)
	sw $t1, -148($fp)	# spill _tmp64 from $t1 to $fp-148
	sw $t2, -152($fp)	# spill _tmp65 from $t2 to $fp-152
	sw $t4, -156($fp)	# spill _tmp66 from $t4 to $fp-156
	jalr $t2            	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# r = _tmp67
	move $t1, $t0		# copy value
	# _tmp68 = 1
	li $t2, 1		# load constant value 1 into $t2
	# _tmp69 = *(this + 8)
	lw $t3, 4($fp)	# load this from $fp+4 into $t3
	lw $t4, 8($t3) 	# load with offset
	# _tmp70 = _tmp69 - _tmp68
	sub $t5, $t4, $t2	
	# _tmp71 = 8
	li $t6, 8		# load constant value 8 into $t6
	# _tmp72 = this + _tmp71
	add $t7, $t3, $t6	
	# *(_tmp72) = _tmp70
	sw $t5, 0($t7) 	# store with offset
	# _tmp73 = *(this + 4)
	lw $s0, 4($t3) 	# load with offset
	# _tmp74 = *(_tmp73)
	lw $s1, 0($s0) 	# load with offset
	# _tmp75 = *(this + 8)
	lw $s2, 8($t3) 	# load with offset
	# _tmp76 = _tmp75 < _tmp74
	slt $s3, $s2, $s1	
	# _tmp77 = -1
	li $s4, -1		# load constant value -1 into $s4
	# _tmp78 = _tmp77 < _tmp75
	slt $s5, $s4, $s2	
	# _tmp79 = _tmp78 && _tmp76
	and $s6, $s5, $s3	
	# IfZ _tmp79 Goto _L7
	# (save modified registers before flow of control change)
	sw $t0, -160($fp)	# spill _tmp67 from $t0 to $fp-160
	sw $t1, -140($fp)	# spill r from $t1 to $fp-140
	sw $t2, -168($fp)	# spill _tmp68 from $t2 to $fp-168
	sw $t4, -172($fp)	# spill _tmp69 from $t4 to $fp-172
	sw $t5, -164($fp)	# spill _tmp70 from $t5 to $fp-164
	sw $t6, -176($fp)	# spill _tmp71 from $t6 to $fp-176
	sw $t7, -180($fp)	# spill _tmp72 from $t7 to $fp-180
	sw $s0, -184($fp)	# spill _tmp73 from $s0 to $fp-184
	sw $s1, -188($fp)	# spill _tmp74 from $s1 to $fp-188
	sw $s2, -196($fp)	# spill _tmp75 from $s2 to $fp-196
	sw $s3, -192($fp)	# spill _tmp76 from $s3 to $fp-192
	sw $s4, -200($fp)	# spill _tmp77 from $s4 to $fp-200
	sw $s5, -204($fp)	# spill _tmp78 from $s5 to $fp-204
	sw $s6, -208($fp)	# spill _tmp79 from $s6 to $fp-208
	beqz $s6, _L7	# branch if _tmp79 is zero 
	# _tmp80 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp81 = _tmp75 * _tmp80
	lw $t1, -196($fp)	# load _tmp75 from $fp-196 into $t1
	mul $t2, $t1, $t0	
	# _tmp82 = _tmp81 + _tmp80
	add $t3, $t2, $t0	
	# _tmp83 = _tmp73 + _tmp82
	lw $t4, -184($fp)	# load _tmp73 from $fp-184 into $t4
	add $t5, $t4, $t3	
	# Goto _L8
	# (save modified registers before flow of control change)
	sw $t0, -212($fp)	# spill _tmp80 from $t0 to $fp-212
	sw $t2, -216($fp)	# spill _tmp81 from $t2 to $fp-216
	sw $t3, -220($fp)	# spill _tmp82 from $t3 to $fp-220
	sw $t5, -220($fp)	# spill _tmp83 from $t5 to $fp-220
	b _L8		# unconditional branch
_L7:
	# _tmp84 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string3: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string3	# load label
	# PushParam _tmp84
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -224($fp)	# spill _tmp84 from $t0 to $fp-224
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L8:
	# _tmp85 = *(_tmp83)
	lw $t0, -220($fp)	# load _tmp83 from $fp-220 into $t0
	lw $t1, 0($t0) 	# load with offset
	# temp = _tmp85
	move $t2, $t1		# copy value
	# _tmp86 = *(this + 4)
	lw $t3, 4($fp)	# load this from $fp+4 into $t3
	lw $t4, 4($t3) 	# load with offset
	# _tmp87 = *(_tmp86)
	lw $t5, 0($t4) 	# load with offset
	# _tmp88 = r < _tmp87
	lw $t6, -140($fp)	# load r from $fp-140 into $t6
	slt $t7, $t6, $t5	
	# _tmp89 = -1
	li $s0, -1		# load constant value -1 into $s0
	# _tmp90 = _tmp89 < r
	slt $s1, $s0, $t6	
	# _tmp91 = _tmp90 && _tmp88
	and $s2, $s1, $t7	
	# IfZ _tmp91 Goto _L9
	# (save modified registers before flow of control change)
	sw $t1, -228($fp)	# spill _tmp85 from $t1 to $fp-228
	sw $t2, -144($fp)	# spill temp from $t2 to $fp-144
	sw $t4, -232($fp)	# spill _tmp86 from $t4 to $fp-232
	sw $t5, -236($fp)	# spill _tmp87 from $t5 to $fp-236
	sw $t7, -240($fp)	# spill _tmp88 from $t7 to $fp-240
	sw $s0, -244($fp)	# spill _tmp89 from $s0 to $fp-244
	sw $s1, -248($fp)	# spill _tmp90 from $s1 to $fp-248
	sw $s2, -252($fp)	# spill _tmp91 from $s2 to $fp-252
	beqz $s2, _L9	# branch if _tmp91 is zero 
	# _tmp92 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp93 = r * _tmp92
	lw $t1, -140($fp)	# load r from $fp-140 into $t1
	mul $t2, $t1, $t0	
	# _tmp94 = _tmp93 + _tmp92
	add $t3, $t2, $t0	
	# _tmp95 = _tmp86 + _tmp94
	lw $t4, -232($fp)	# load _tmp86 from $fp-232 into $t4
	add $t5, $t4, $t3	
	# Goto _L10
	# (save modified registers before flow of control change)
	sw $t0, -256($fp)	# spill _tmp92 from $t0 to $fp-256
	sw $t2, -260($fp)	# spill _tmp93 from $t2 to $fp-260
	sw $t3, -264($fp)	# spill _tmp94 from $t3 to $fp-264
	sw $t5, -264($fp)	# spill _tmp95 from $t5 to $fp-264
	b _L10		# unconditional branch
_L9:
	# _tmp96 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string4: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string4	# load label
	# PushParam _tmp96
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -268($fp)	# spill _tmp96 from $t0 to $fp-268
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L10:
	# _tmp97 = *(_tmp95)
	lw $t0, -264($fp)	# load _tmp95 from $fp-264 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp98 = *(this + 4)
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	lw $t3, 4($t2) 	# load with offset
	# _tmp99 = *(_tmp98)
	lw $t4, 0($t3) 	# load with offset
	# _tmp100 = *(this + 8)
	lw $t5, 8($t2) 	# load with offset
	# _tmp101 = _tmp100 < _tmp99
	slt $t6, $t5, $t4	
	# _tmp102 = -1
	li $t7, -1		# load constant value -1 into $t7
	# _tmp103 = _tmp102 < _tmp100
	slt $s0, $t7, $t5	
	# _tmp104 = _tmp103 && _tmp101
	and $s1, $s0, $t6	
	# IfZ _tmp104 Goto _L11
	# (save modified registers before flow of control change)
	sw $t1, -272($fp)	# spill _tmp97 from $t1 to $fp-272
	sw $t3, -276($fp)	# spill _tmp98 from $t3 to $fp-276
	sw $t4, -280($fp)	# spill _tmp99 from $t4 to $fp-280
	sw $t5, -288($fp)	# spill _tmp100 from $t5 to $fp-288
	sw $t6, -284($fp)	# spill _tmp101 from $t6 to $fp-284
	sw $t7, -292($fp)	# spill _tmp102 from $t7 to $fp-292
	sw $s0, -296($fp)	# spill _tmp103 from $s0 to $fp-296
	sw $s1, -300($fp)	# spill _tmp104 from $s1 to $fp-300
	beqz $s1, _L11	# branch if _tmp104 is zero 
	# _tmp105 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp106 = _tmp100 * _tmp105
	lw $t1, -288($fp)	# load _tmp100 from $fp-288 into $t1
	mul $t2, $t1, $t0	
	# _tmp107 = _tmp106 + _tmp105
	add $t3, $t2, $t0	
	# _tmp108 = _tmp98 + _tmp107
	lw $t4, -276($fp)	# load _tmp98 from $fp-276 into $t4
	add $t5, $t4, $t3	
	# Goto _L12
	# (save modified registers before flow of control change)
	sw $t0, -304($fp)	# spill _tmp105 from $t0 to $fp-304
	sw $t2, -308($fp)	# spill _tmp106 from $t2 to $fp-308
	sw $t3, -312($fp)	# spill _tmp107 from $t3 to $fp-312
	sw $t5, -312($fp)	# spill _tmp108 from $t5 to $fp-312
	b _L12		# unconditional branch
_L11:
	# _tmp109 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string5: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string5	# load label
	# PushParam _tmp109
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -316($fp)	# spill _tmp109 from $t0 to $fp-316
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L12:
	# *(_tmp108) = _tmp97
	lw $t0, -272($fp)	# load _tmp97 from $fp-272 into $t0
	lw $t1, -312($fp)	# load _tmp108 from $fp-312 into $t1
	sw $t0, 0($t1) 	# store with offset
	# _tmp110 = *(this + 4)
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	lw $t3, 4($t2) 	# load with offset
	# _tmp111 = *(_tmp110)
	lw $t4, 0($t3) 	# load with offset
	# _tmp112 = r < _tmp111
	lw $t5, -140($fp)	# load r from $fp-140 into $t5
	slt $t6, $t5, $t4	
	# _tmp113 = -1
	li $t7, -1		# load constant value -1 into $t7
	# _tmp114 = _tmp113 < r
	slt $s0, $t7, $t5	
	# _tmp115 = _tmp114 && _tmp112
	and $s1, $s0, $t6	
	# IfZ _tmp115 Goto _L13
	# (save modified registers before flow of control change)
	sw $t3, -320($fp)	# spill _tmp110 from $t3 to $fp-320
	sw $t4, -324($fp)	# spill _tmp111 from $t4 to $fp-324
	sw $t6, -328($fp)	# spill _tmp112 from $t6 to $fp-328
	sw $t7, -332($fp)	# spill _tmp113 from $t7 to $fp-332
	sw $s0, -336($fp)	# spill _tmp114 from $s0 to $fp-336
	sw $s1, -340($fp)	# spill _tmp115 from $s1 to $fp-340
	beqz $s1, _L13	# branch if _tmp115 is zero 
	# _tmp116 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp117 = r * _tmp116
	lw $t1, -140($fp)	# load r from $fp-140 into $t1
	mul $t2, $t1, $t0	
	# _tmp118 = _tmp117 + _tmp116
	add $t3, $t2, $t0	
	# _tmp119 = _tmp110 + _tmp118
	lw $t4, -320($fp)	# load _tmp110 from $fp-320 into $t4
	add $t5, $t4, $t3	
	# Goto _L14
	# (save modified registers before flow of control change)
	sw $t0, -344($fp)	# spill _tmp116 from $t0 to $fp-344
	sw $t2, -348($fp)	# spill _tmp117 from $t2 to $fp-348
	sw $t3, -352($fp)	# spill _tmp118 from $t3 to $fp-352
	sw $t5, -352($fp)	# spill _tmp119 from $t5 to $fp-352
	b _L14		# unconditional branch
_L13:
	# _tmp120 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string6: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string6	# load label
	# PushParam _tmp120
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -356($fp)	# spill _tmp120 from $t0 to $fp-356
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L14:
	# *(_tmp119) = temp
	lw $t0, -144($fp)	# load temp from $fp-144 into $t0
	lw $t1, -352($fp)	# load _tmp119 from $fp-352 into $t1
	sw $t0, 0($t1) 	# store with offset
	# Goto _L5
	b _L5		# unconditional branch
_L6:
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__Deck.GetCard:
	# BeginFunc 96
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 96	# decrement sp to make space for locals/temps
	# _tmp121 = *(this + 8)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 8($t0) 	# load with offset
	# _tmp122 = 52
	li $t2, 52		# load constant value 52 into $t2
	# _tmp123 = _tmp122 < _tmp121
	slt $t3, $t2, $t1	
	# _tmp124 = _tmp121 == _tmp122
	seq $t4, $t1, $t2	
	# _tmp125 = _tmp123 || _tmp124
	or $t5, $t3, $t4	
	# IfZ _tmp125 Goto _L15
	# (save modified registers before flow of control change)
	sw $t1, -12($fp)	# spill _tmp121 from $t1 to $fp-12
	sw $t2, -16($fp)	# spill _tmp122 from $t2 to $fp-16
	sw $t3, -20($fp)	# spill _tmp123 from $t3 to $fp-20
	sw $t4, -24($fp)	# spill _tmp124 from $t4 to $fp-24
	sw $t5, -28($fp)	# spill _tmp125 from $t5 to $fp-28
	beqz $t5, _L15	# branch if _tmp125 is zero 
	# _tmp126 = 0
	li $t0, 0		# load constant value 0 into $t0
	# Return _tmp126
	move $v0, $t0		# assign return value into $v0
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
	# Goto _L16
	b _L16		# unconditional branch
_L15:
_L16:
	# _tmp127 = *(this + 4)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 4($t0) 	# load with offset
	# _tmp128 = *(_tmp127)
	lw $t2, 0($t1) 	# load with offset
	# _tmp129 = *(this + 8)
	lw $t3, 8($t0) 	# load with offset
	# _tmp130 = _tmp129 < _tmp128
	slt $t4, $t3, $t2	
	# _tmp131 = -1
	li $t5, -1		# load constant value -1 into $t5
	# _tmp132 = _tmp131 < _tmp129
	slt $t6, $t5, $t3	
	# _tmp133 = _tmp132 && _tmp130
	and $t7, $t6, $t4	
	# IfZ _tmp133 Goto _L17
	# (save modified registers before flow of control change)
	sw $t1, -36($fp)	# spill _tmp127 from $t1 to $fp-36
	sw $t2, -40($fp)	# spill _tmp128 from $t2 to $fp-40
	sw $t3, -48($fp)	# spill _tmp129 from $t3 to $fp-48
	sw $t4, -44($fp)	# spill _tmp130 from $t4 to $fp-44
	sw $t5, -52($fp)	# spill _tmp131 from $t5 to $fp-52
	sw $t6, -56($fp)	# spill _tmp132 from $t6 to $fp-56
	sw $t7, -60($fp)	# spill _tmp133 from $t7 to $fp-60
	beqz $t7, _L17	# branch if _tmp133 is zero 
	# _tmp134 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp135 = _tmp129 * _tmp134
	lw $t1, -48($fp)	# load _tmp129 from $fp-48 into $t1
	mul $t2, $t1, $t0	
	# _tmp136 = _tmp135 + _tmp134
	add $t3, $t2, $t0	
	# _tmp137 = _tmp127 + _tmp136
	lw $t4, -36($fp)	# load _tmp127 from $fp-36 into $t4
	add $t5, $t4, $t3	
	# Goto _L18
	# (save modified registers before flow of control change)
	sw $t0, -64($fp)	# spill _tmp134 from $t0 to $fp-64
	sw $t2, -68($fp)	# spill _tmp135 from $t2 to $fp-68
	sw $t3, -72($fp)	# spill _tmp136 from $t3 to $fp-72
	sw $t5, -72($fp)	# spill _tmp137 from $t5 to $fp-72
	b _L18		# unconditional branch
_L17:
	# _tmp138 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string7: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string7	# load label
	# PushParam _tmp138
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -76($fp)	# spill _tmp138 from $t0 to $fp-76
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L18:
	# _tmp139 = *(_tmp137)
	lw $t0, -72($fp)	# load _tmp137 from $fp-72 into $t0
	lw $t1, 0($t0) 	# load with offset
	# result = _tmp139
	move $t2, $t1		# copy value
	# _tmp140 = 1
	li $t3, 1		# load constant value 1 into $t3
	# _tmp141 = *(this + 8)
	lw $t4, 4($fp)	# load this from $fp+4 into $t4
	lw $t5, 8($t4) 	# load with offset
	# _tmp142 = _tmp141 + _tmp140
	add $t6, $t5, $t3	
	# _tmp143 = 8
	li $t7, 8		# load constant value 8 into $t7
	# _tmp144 = this + _tmp143
	add $s0, $t4, $t7	
	# *(_tmp144) = _tmp142
	sw $t6, 0($s0) 	# store with offset
	# Return result
	move $v0, $t2		# assign return value into $v0
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
	# VTable for class Deck
	.data
	.align 2
	Deck:		# label for class Deck vtable
	.word __Deck.GetCard
	.word __Deck.Init
	.word __Deck.Shuffle
	.text
__BJDeck.Init:
	# BeginFunc 176
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 176	# decrement sp to make space for locals/temps
	# _tmp145 = 8
	li $t0, 8		# load constant value 8 into $t0
	# _tmp146 = 0
	li $t1, 0		# load constant value 0 into $t1
	# _tmp147 = _tmp145 < _tmp146
	slt $t2, $t0, $t1	
	# _tmp148 = _tmp145 == _tmp146
	seq $t3, $t0, $t1	
	# _tmp149 = _tmp147 || _tmp148
	or $t4, $t2, $t3	
	# IfZ _tmp149 Goto _L19
	# (save modified registers before flow of control change)
	sw $t0, -12($fp)	# spill _tmp145 from $t0 to $fp-12
	sw $t1, -16($fp)	# spill _tmp146 from $t1 to $fp-16
	sw $t2, -20($fp)	# spill _tmp147 from $t2 to $fp-20
	sw $t3, -24($fp)	# spill _tmp148 from $t3 to $fp-24
	sw $t4, -28($fp)	# spill _tmp149 from $t4 to $fp-28
	beqz $t4, _L19	# branch if _tmp149 is zero 
	# _tmp150 = "Decaf runtime error: Array size is <= 0"
	.data			# create string constant marked with label
	_string8: .asciiz "Decaf runtime error: Array size is <= 0"
	.text
	la $t0, _string8	# load label
	# PushParam _tmp150
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -32($fp)	# spill _tmp150 from $t0 to $fp-32
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L19:
	# _tmp151 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp152 = _tmp145 * _tmp151
	lw $t1, -12($fp)	# load _tmp145 from $fp-12 into $t1
	mul $t2, $t1, $t0	
	# _tmp153 = _tmp152 + _tmp151
	add $t3, $t2, $t0	
	# PushParam _tmp153
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t3, 4($sp)	# copy param value to stack
	# _tmp154 = LCall _Alloc
	# (save modified registers before flow of control change)
	sw $t0, -36($fp)	# spill _tmp151 from $t0 to $fp-36
	sw $t2, -40($fp)	# spill _tmp152 from $t2 to $fp-40
	sw $t3, -44($fp)	# spill _tmp153 from $t3 to $fp-44
	jal _Alloc         	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# *(_tmp154) = _tmp145
	lw $t1, -12($fp)	# load _tmp145 from $fp-12 into $t1
	sw $t1, 0($t0) 	# store with offset
	# _tmp155 = 4
	li $t2, 4		# load constant value 4 into $t2
	# _tmp156 = this + _tmp155
	lw $t3, 4($fp)	# load this from $fp+4 into $t3
	add $t4, $t3, $t2	
	# *(_tmp156) = _tmp154
	sw $t0, 0($t4) 	# store with offset
	# _tmp157 = 0
	li $t5, 0		# load constant value 0 into $t5
	# i = _tmp157
	move $t6, $t5		# copy value
	# (save modified registers before flow of control change)
	sw $t0, -48($fp)	# spill _tmp154 from $t0 to $fp-48
	sw $t2, -52($fp)	# spill _tmp155 from $t2 to $fp-52
	sw $t4, -56($fp)	# spill _tmp156 from $t4 to $fp-56
	sw $t5, -60($fp)	# spill _tmp157 from $t5 to $fp-60
	sw $t6, -8($fp)	# spill i from $t6 to $fp-8
_L20:
	# _tmp158 = 8
	li $t0, 8		# load constant value 8 into $t0
	# _tmp159 = i < _tmp158
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	slt $t2, $t1, $t0	
	# IfZ _tmp159 Goto _L21
	# (save modified registers before flow of control change)
	sw $t0, -64($fp)	# spill _tmp158 from $t0 to $fp-64
	sw $t2, -68($fp)	# spill _tmp159 from $t2 to $fp-68
	beqz $t2, _L21	# branch if _tmp159 is zero 
	# _tmp160 = 12
	li $t0, 12		# load constant value 12 into $t0
	# PushParam _tmp160
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp161 = LCall _Alloc
	# (save modified registers before flow of control change)
	sw $t0, -72($fp)	# spill _tmp160 from $t0 to $fp-72
	jal _Alloc         	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp162 = Deck
	la $t1, Deck	# load label
	# *(_tmp161) = _tmp162
	sw $t1, 0($t0) 	# store with offset
	# _tmp163 = *(this + 4)
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	lw $t3, 4($t2) 	# load with offset
	# _tmp164 = *(_tmp163)
	lw $t4, 0($t3) 	# load with offset
	# _tmp165 = i < _tmp164
	lw $t5, -8($fp)	# load i from $fp-8 into $t5
	slt $t6, $t5, $t4	
	# _tmp166 = -1
	li $t7, -1		# load constant value -1 into $t7
	# _tmp167 = _tmp166 < i
	slt $s0, $t7, $t5	
	# _tmp168 = _tmp167 && _tmp165
	and $s1, $s0, $t6	
	# IfZ _tmp168 Goto _L22
	# (save modified registers before flow of control change)
	sw $t0, -76($fp)	# spill _tmp161 from $t0 to $fp-76
	sw $t1, -80($fp)	# spill _tmp162 from $t1 to $fp-80
	sw $t3, -84($fp)	# spill _tmp163 from $t3 to $fp-84
	sw $t4, -88($fp)	# spill _tmp164 from $t4 to $fp-88
	sw $t6, -92($fp)	# spill _tmp165 from $t6 to $fp-92
	sw $t7, -96($fp)	# spill _tmp166 from $t7 to $fp-96
	sw $s0, -100($fp)	# spill _tmp167 from $s0 to $fp-100
	sw $s1, -104($fp)	# spill _tmp168 from $s1 to $fp-104
	beqz $s1, _L22	# branch if _tmp168 is zero 
	# _tmp169 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp170 = i * _tmp169
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	mul $t2, $t1, $t0	
	# _tmp171 = _tmp170 + _tmp169
	add $t3, $t2, $t0	
	# _tmp172 = _tmp163 + _tmp171
	lw $t4, -84($fp)	# load _tmp163 from $fp-84 into $t4
	add $t5, $t4, $t3	
	# Goto _L23
	# (save modified registers before flow of control change)
	sw $t0, -108($fp)	# spill _tmp169 from $t0 to $fp-108
	sw $t2, -112($fp)	# spill _tmp170 from $t2 to $fp-112
	sw $t3, -116($fp)	# spill _tmp171 from $t3 to $fp-116
	sw $t5, -116($fp)	# spill _tmp172 from $t5 to $fp-116
	b _L23		# unconditional branch
_L22:
	# _tmp173 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string9: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string9	# load label
	# PushParam _tmp173
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -120($fp)	# spill _tmp173 from $t0 to $fp-120
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L23:
	# *(_tmp172) = _tmp161
	lw $t0, -76($fp)	# load _tmp161 from $fp-76 into $t0
	lw $t1, -116($fp)	# load _tmp172 from $fp-116 into $t1
	sw $t0, 0($t1) 	# store with offset
	# _tmp174 = *(this + 4)
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	lw $t3, 4($t2) 	# load with offset
	# _tmp175 = *(_tmp174)
	lw $t4, 0($t3) 	# load with offset
	# _tmp176 = i < _tmp175
	lw $t5, -8($fp)	# load i from $fp-8 into $t5
	slt $t6, $t5, $t4	
	# _tmp177 = -1
	li $t7, -1		# load constant value -1 into $t7
	# _tmp178 = _tmp177 < i
	slt $s0, $t7, $t5	
	# _tmp179 = _tmp178 && _tmp176
	and $s1, $s0, $t6	
	# IfZ _tmp179 Goto _L24
	# (save modified registers before flow of control change)
	sw $t3, -124($fp)	# spill _tmp174 from $t3 to $fp-124
	sw $t4, -128($fp)	# spill _tmp175 from $t4 to $fp-128
	sw $t6, -132($fp)	# spill _tmp176 from $t6 to $fp-132
	sw $t7, -136($fp)	# spill _tmp177 from $t7 to $fp-136
	sw $s0, -140($fp)	# spill _tmp178 from $s0 to $fp-140
	sw $s1, -144($fp)	# spill _tmp179 from $s1 to $fp-144
	beqz $s1, _L24	# branch if _tmp179 is zero 
	# _tmp180 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp181 = i * _tmp180
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	mul $t2, $t1, $t0	
	# _tmp182 = _tmp181 + _tmp180
	add $t3, $t2, $t0	
	# _tmp183 = _tmp174 + _tmp182
	lw $t4, -124($fp)	# load _tmp174 from $fp-124 into $t4
	add $t5, $t4, $t3	
	# Goto _L25
	# (save modified registers before flow of control change)
	sw $t0, -148($fp)	# spill _tmp180 from $t0 to $fp-148
	sw $t2, -152($fp)	# spill _tmp181 from $t2 to $fp-152
	sw $t3, -156($fp)	# spill _tmp182 from $t3 to $fp-156
	sw $t5, -156($fp)	# spill _tmp183 from $t5 to $fp-156
	b _L25		# unconditional branch
_L24:
	# _tmp184 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string10: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string10	# load label
	# PushParam _tmp184
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -160($fp)	# spill _tmp184 from $t0 to $fp-160
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L25:
	# _tmp185 = *(_tmp183)
	lw $t0, -156($fp)	# load _tmp183 from $fp-156 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp186 = *(_tmp185)
	lw $t2, 0($t1) 	# load with offset
	# _tmp187 = *(_tmp186 + 4)
	lw $t3, 4($t2) 	# load with offset
	# PushParam _tmp185
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# ACall _tmp187
	# (save modified registers before flow of control change)
	sw $t1, -164($fp)	# spill _tmp185 from $t1 to $fp-164
	sw $t2, -168($fp)	# spill _tmp186 from $t2 to $fp-168
	sw $t3, -172($fp)	# spill _tmp187 from $t3 to $fp-172
	jalr $t3            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp188 = 1
	li $t0, 1		# load constant value 1 into $t0
	# _tmp189 = i + _tmp188
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	add $t2, $t1, $t0	
	# i = _tmp189
	move $t1, $t2		# copy value
	# Goto _L20
	# (save modified registers before flow of control change)
	sw $t0, -180($fp)	# spill _tmp188 from $t0 to $fp-180
	sw $t1, -8($fp)	# spill i from $t1 to $fp-8
	sw $t2, -176($fp)	# spill _tmp189 from $t2 to $fp-176
	b _L20		# unconditional branch
_L21:
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__BJDeck.DealCard:
	# BeginFunc 180
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 180	# decrement sp to make space for locals/temps
	# _tmp190 = 0
	li $t0, 0		# load constant value 0 into $t0
	# c = _tmp190
	move $t1, $t0		# copy value
	# _tmp191 = *(this + 8)
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	lw $t3, 8($t2) 	# load with offset
	# _tmp192 = 52
	li $t4, 52		# load constant value 52 into $t4
	# _tmp193 = 8
	li $t5, 8		# load constant value 8 into $t5
	# _tmp194 = _tmp193 * _tmp192
	mul $t6, $t5, $t4	
	# _tmp195 = _tmp194 < _tmp191
	slt $t7, $t6, $t3	
	# _tmp196 = _tmp191 == _tmp194
	seq $s0, $t3, $t6	
	# _tmp197 = _tmp195 || _tmp196
	or $s1, $t7, $s0	
	# IfZ _tmp197 Goto _L26
	# (save modified registers before flow of control change)
	sw $t0, -12($fp)	# spill _tmp190 from $t0 to $fp-12
	sw $t1, -8($fp)	# spill c from $t1 to $fp-8
	sw $t3, -16($fp)	# spill _tmp191 from $t3 to $fp-16
	sw $t4, -24($fp)	# spill _tmp192 from $t4 to $fp-24
	sw $t5, -28($fp)	# spill _tmp193 from $t5 to $fp-28
	sw $t6, -20($fp)	# spill _tmp194 from $t6 to $fp-20
	sw $t7, -32($fp)	# spill _tmp195 from $t7 to $fp-32
	sw $s0, -36($fp)	# spill _tmp196 from $s0 to $fp-36
	sw $s1, -40($fp)	# spill _tmp197 from $s1 to $fp-40
	beqz $s1, _L26	# branch if _tmp197 is zero 
	# _tmp198 = 11
	li $t0, 11		# load constant value 11 into $t0
	# Return _tmp198
	move $v0, $t0		# assign return value into $v0
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
	# Goto _L27
	b _L27		# unconditional branch
_L26:
_L27:
	# _tmp199 = 8
	li $t0, 8		# load constant value 8 into $t0
	# PushParam _tmp199
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp200 = LCall _Alloc
	# (save modified registers before flow of control change)
	sw $t0, -48($fp)	# spill _tmp199 from $t0 to $fp-48
	jal _Alloc         	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp201 = Random
	la $t1, Random	# load label
	# *(_tmp200) = _tmp201
	sw $t1, 0($t0) 	# store with offset
	# gRnd = _tmp200
	move $t2, $t0		# copy value
	# (save modified registers before flow of control change)
	sw $t0, -52($fp)	# spill _tmp200 from $t0 to $fp-52
	sw $t1, -56($fp)	# spill _tmp201 from $t1 to $fp-56
	sw $t2, 4($gp)	# spill gRnd from $t2 to $gp+4
_L28:
	# _tmp202 = 0
	li $t0, 0		# load constant value 0 into $t0
	# _tmp203 = c == _tmp202
	lw $t1, -8($fp)	# load c from $fp-8 into $t1
	seq $t2, $t1, $t0	
	# IfZ _tmp203 Goto _L29
	# (save modified registers before flow of control change)
	sw $t0, -60($fp)	# spill _tmp202 from $t0 to $fp-60
	sw $t2, -64($fp)	# spill _tmp203 from $t2 to $fp-64
	beqz $t2, _L29	# branch if _tmp203 is zero 
	# _tmp204 = *(gRnd)
	lw $t0, 4($gp)	# load gRnd from $gp+4 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp205 = *(_tmp204 + 8)
	lw $t2, 8($t1) 	# load with offset
	# _tmp206 = 8
	li $t3, 8		# load constant value 8 into $t3
	# PushParam _tmp206
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t3, 4($sp)	# copy param value to stack
	# PushParam gRnd
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp207 = ACall _tmp205
	# (save modified registers before flow of control change)
	sw $t1, -72($fp)	# spill _tmp204 from $t1 to $fp-72
	sw $t2, -76($fp)	# spill _tmp205 from $t2 to $fp-76
	sw $t3, -80($fp)	# spill _tmp206 from $t3 to $fp-80
	jalr $t2            	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# d = _tmp207
	move $t1, $t0		# copy value
	# _tmp208 = *(this + 4)
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	lw $t3, 4($t2) 	# load with offset
	# _tmp209 = *(_tmp208)
	lw $t4, 0($t3) 	# load with offset
	# _tmp210 = d < _tmp209
	slt $t5, $t1, $t4	
	# _tmp211 = -1
	li $t6, -1		# load constant value -1 into $t6
	# _tmp212 = _tmp211 < d
	slt $t7, $t6, $t1	
	# _tmp213 = _tmp212 && _tmp210
	and $s0, $t7, $t5	
	# IfZ _tmp213 Goto _L30
	# (save modified registers before flow of control change)
	sw $t0, -84($fp)	# spill _tmp207 from $t0 to $fp-84
	sw $t1, -68($fp)	# spill d from $t1 to $fp-68
	sw $t3, -88($fp)	# spill _tmp208 from $t3 to $fp-88
	sw $t4, -92($fp)	# spill _tmp209 from $t4 to $fp-92
	sw $t5, -96($fp)	# spill _tmp210 from $t5 to $fp-96
	sw $t6, -100($fp)	# spill _tmp211 from $t6 to $fp-100
	sw $t7, -104($fp)	# spill _tmp212 from $t7 to $fp-104
	sw $s0, -108($fp)	# spill _tmp213 from $s0 to $fp-108
	beqz $s0, _L30	# branch if _tmp213 is zero 
	# _tmp214 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp215 = d * _tmp214
	lw $t1, -68($fp)	# load d from $fp-68 into $t1
	mul $t2, $t1, $t0	
	# _tmp216 = _tmp215 + _tmp214
	add $t3, $t2, $t0	
	# _tmp217 = _tmp208 + _tmp216
	lw $t4, -88($fp)	# load _tmp208 from $fp-88 into $t4
	add $t5, $t4, $t3	
	# Goto _L31
	# (save modified registers before flow of control change)
	sw $t0, -112($fp)	# spill _tmp214 from $t0 to $fp-112
	sw $t2, -116($fp)	# spill _tmp215 from $t2 to $fp-116
	sw $t3, -120($fp)	# spill _tmp216 from $t3 to $fp-120
	sw $t5, -120($fp)	# spill _tmp217 from $t5 to $fp-120
	b _L31		# unconditional branch
_L30:
	# _tmp218 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string11: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string11	# load label
	# PushParam _tmp218
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -124($fp)	# spill _tmp218 from $t0 to $fp-124
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L31:
	# _tmp219 = *(_tmp217)
	lw $t0, -120($fp)	# load _tmp217 from $fp-120 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp220 = *(_tmp219)
	lw $t2, 0($t1) 	# load with offset
	# _tmp221 = *(_tmp220)
	lw $t3, 0($t2) 	# load with offset
	# PushParam _tmp219
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# _tmp222 = ACall _tmp221
	# (save modified registers before flow of control change)
	sw $t1, -128($fp)	# spill _tmp219 from $t1 to $fp-128
	sw $t2, -132($fp)	# spill _tmp220 from $t2 to $fp-132
	sw $t3, -136($fp)	# spill _tmp221 from $t3 to $fp-136
	jalr $t3            	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# c = _tmp222
	move $t1, $t0		# copy value
	# Goto _L28
	# (save modified registers before flow of control change)
	sw $t0, -140($fp)	# spill _tmp222 from $t0 to $fp-140
	sw $t1, -8($fp)	# spill c from $t1 to $fp-8
	b _L28		# unconditional branch
_L29:
	# _tmp223 = 10
	li $t0, 10		# load constant value 10 into $t0
	# _tmp224 = _tmp223 < c
	lw $t1, -8($fp)	# load c from $fp-8 into $t1
	slt $t2, $t0, $t1	
	# IfZ _tmp224 Goto _L32
	# (save modified registers before flow of control change)
	sw $t0, -144($fp)	# spill _tmp223 from $t0 to $fp-144
	sw $t2, -148($fp)	# spill _tmp224 from $t2 to $fp-148
	beqz $t2, _L32	# branch if _tmp224 is zero 
	# _tmp225 = 10
	li $t0, 10		# load constant value 10 into $t0
	# c = _tmp225
	move $t1, $t0		# copy value
	# Goto _L33
	# (save modified registers before flow of control change)
	sw $t0, -152($fp)	# spill _tmp225 from $t0 to $fp-152
	sw $t1, -8($fp)	# spill c from $t1 to $fp-8
	b _L33		# unconditional branch
_L32:
	# _tmp226 = 1
	li $t0, 1		# load constant value 1 into $t0
	# _tmp227 = c == _tmp226
	lw $t1, -8($fp)	# load c from $fp-8 into $t1
	seq $t2, $t1, $t0	
	# IfZ _tmp227 Goto _L34
	# (save modified registers before flow of control change)
	sw $t0, -156($fp)	# spill _tmp226 from $t0 to $fp-156
	sw $t2, -160($fp)	# spill _tmp227 from $t2 to $fp-160
	beqz $t2, _L34	# branch if _tmp227 is zero 
	# _tmp228 = 11
	li $t0, 11		# load constant value 11 into $t0
	# c = _tmp228
	move $t1, $t0		# copy value
	# Goto _L35
	# (save modified registers before flow of control change)
	sw $t0, -164($fp)	# spill _tmp228 from $t0 to $fp-164
	sw $t1, -8($fp)	# spill c from $t1 to $fp-8
	b _L35		# unconditional branch
_L34:
_L35:
_L33:
	# _tmp229 = 1
	li $t0, 1		# load constant value 1 into $t0
	# _tmp230 = *(this + 8)
	lw $t1, 4($fp)	# load this from $fp+4 into $t1
	lw $t2, 8($t1) 	# load with offset
	# _tmp231 = _tmp230 + _tmp229
	add $t3, $t2, $t0	
	# _tmp232 = 8
	li $t4, 8		# load constant value 8 into $t4
	# _tmp233 = this + _tmp232
	add $t5, $t1, $t4	
	# *(_tmp233) = _tmp231
	sw $t3, 0($t5) 	# store with offset
	# Return c
	lw $t6, -8($fp)	# load c from $fp-8 into $t6
	move $v0, $t6		# assign return value into $v0
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
__BJDeck.Shuffle:
	# BeginFunc 96
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 96	# decrement sp to make space for locals/temps
	# _tmp234 = "Shuffling..."
	.data			# create string constant marked with label
	_string12: .asciiz "Shuffling..."
	.text
	la $t0, _string12	# load label
	# PushParam _tmp234
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -12($fp)	# spill _tmp234 from $t0 to $fp-12
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp235 = 0
	li $t0, 0		# load constant value 0 into $t0
	# i = _tmp235
	move $t1, $t0		# copy value
	# (save modified registers before flow of control change)
	sw $t0, -16($fp)	# spill _tmp235 from $t0 to $fp-16
	sw $t1, -8($fp)	# spill i from $t1 to $fp-8
_L36:
	# _tmp236 = 8
	li $t0, 8		# load constant value 8 into $t0
	# _tmp237 = i < _tmp236
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	slt $t2, $t1, $t0	
	# IfZ _tmp237 Goto _L37
	# (save modified registers before flow of control change)
	sw $t0, -20($fp)	# spill _tmp236 from $t0 to $fp-20
	sw $t2, -24($fp)	# spill _tmp237 from $t2 to $fp-24
	beqz $t2, _L37	# branch if _tmp237 is zero 
	# _tmp238 = *(this + 4)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 4($t0) 	# load with offset
	# _tmp239 = *(_tmp238)
	lw $t2, 0($t1) 	# load with offset
	# _tmp240 = i < _tmp239
	lw $t3, -8($fp)	# load i from $fp-8 into $t3
	slt $t4, $t3, $t2	
	# _tmp241 = -1
	li $t5, -1		# load constant value -1 into $t5
	# _tmp242 = _tmp241 < i
	slt $t6, $t5, $t3	
	# _tmp243 = _tmp242 && _tmp240
	and $t7, $t6, $t4	
	# IfZ _tmp243 Goto _L38
	# (save modified registers before flow of control change)
	sw $t1, -28($fp)	# spill _tmp238 from $t1 to $fp-28
	sw $t2, -32($fp)	# spill _tmp239 from $t2 to $fp-32
	sw $t4, -36($fp)	# spill _tmp240 from $t4 to $fp-36
	sw $t5, -40($fp)	# spill _tmp241 from $t5 to $fp-40
	sw $t6, -44($fp)	# spill _tmp242 from $t6 to $fp-44
	sw $t7, -48($fp)	# spill _tmp243 from $t7 to $fp-48
	beqz $t7, _L38	# branch if _tmp243 is zero 
	# _tmp244 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp245 = i * _tmp244
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	mul $t2, $t1, $t0	
	# _tmp246 = _tmp245 + _tmp244
	add $t3, $t2, $t0	
	# _tmp247 = _tmp238 + _tmp246
	lw $t4, -28($fp)	# load _tmp238 from $fp-28 into $t4
	add $t5, $t4, $t3	
	# Goto _L39
	# (save modified registers before flow of control change)
	sw $t0, -52($fp)	# spill _tmp244 from $t0 to $fp-52
	sw $t2, -56($fp)	# spill _tmp245 from $t2 to $fp-56
	sw $t3, -60($fp)	# spill _tmp246 from $t3 to $fp-60
	sw $t5, -60($fp)	# spill _tmp247 from $t5 to $fp-60
	b _L39		# unconditional branch
_L38:
	# _tmp248 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string13: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string13	# load label
	# PushParam _tmp248
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -64($fp)	# spill _tmp248 from $t0 to $fp-64
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L39:
	# _tmp249 = *(_tmp247)
	lw $t0, -60($fp)	# load _tmp247 from $fp-60 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp250 = *(_tmp249)
	lw $t2, 0($t1) 	# load with offset
	# _tmp251 = *(_tmp250 + 8)
	lw $t3, 8($t2) 	# load with offset
	# PushParam _tmp249
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# ACall _tmp251
	# (save modified registers before flow of control change)
	sw $t1, -68($fp)	# spill _tmp249 from $t1 to $fp-68
	sw $t2, -72($fp)	# spill _tmp250 from $t2 to $fp-72
	sw $t3, -76($fp)	# spill _tmp251 from $t3 to $fp-76
	jalr $t3            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp252 = 1
	li $t0, 1		# load constant value 1 into $t0
	# _tmp253 = i + _tmp252
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	add $t2, $t1, $t0	
	# i = _tmp253
	move $t1, $t2		# copy value
	# Goto _L36
	# (save modified registers before flow of control change)
	sw $t0, -84($fp)	# spill _tmp252 from $t0 to $fp-84
	sw $t1, -8($fp)	# spill i from $t1 to $fp-8
	sw $t2, -80($fp)	# spill _tmp253 from $t2 to $fp-80
	b _L36		# unconditional branch
_L37:
	# _tmp254 = 0
	li $t0, 0		# load constant value 0 into $t0
	# _tmp255 = 8
	li $t1, 8		# load constant value 8 into $t1
	# _tmp256 = this + _tmp255
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	add $t3, $t2, $t1	
	# *(_tmp256) = _tmp254
	sw $t0, 0($t3) 	# store with offset
	# _tmp257 = "done.\n"
	.data			# create string constant marked with label
	_string14: .asciiz "done.\n"
	.text
	la $t4, _string14	# load label
	# PushParam _tmp257
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t4, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -88($fp)	# spill _tmp254 from $t0 to $fp-88
	sw $t1, -92($fp)	# spill _tmp255 from $t1 to $fp-92
	sw $t3, -96($fp)	# spill _tmp256 from $t3 to $fp-96
	sw $t4, -100($fp)	# spill _tmp257 from $t4 to $fp-100
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__BJDeck.NumCardsRemaining:
	# BeginFunc 20
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 20	# decrement sp to make space for locals/temps
	# _tmp258 = *(this + 8)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 8($t0) 	# load with offset
	# _tmp259 = 52
	li $t2, 52		# load constant value 52 into $t2
	# _tmp260 = 8
	li $t3, 8		# load constant value 8 into $t3
	# _tmp261 = _tmp260 * _tmp259
	mul $t4, $t3, $t2	
	# _tmp262 = _tmp261 - _tmp258
	sub $t5, $t4, $t1	
	# Return _tmp262
	move $v0, $t5		# assign return value into $v0
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
	# VTable for class BJDeck
	.data
	.align 2
	BJDeck:		# label for class BJDeck vtable
	.word __BJDeck.DealCard
	.word __BJDeck.Init
	.word __BJDeck.NumCardsRemaining
	.word __BJDeck.Shuffle
	.text
__Player.Init:
	# BeginFunc 32
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 32	# decrement sp to make space for locals/temps
	# _tmp263 = 1000
	li $t0, 1000		# load constant value 1000 into $t0
	# _tmp264 = 12
	li $t1, 12		# load constant value 12 into $t1
	# _tmp265 = this + _tmp264
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	add $t3, $t2, $t1	
	# *(_tmp265) = _tmp263
	sw $t0, 0($t3) 	# store with offset
	# _tmp266 = "What is the name of player #"
	.data			# create string constant marked with label
	_string15: .asciiz "What is the name of player #"
	.text
	la $t4, _string15	# load label
	# PushParam _tmp266
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t4, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -8($fp)	# spill _tmp263 from $t0 to $fp-8
	sw $t1, -12($fp)	# spill _tmp264 from $t1 to $fp-12
	sw $t3, -16($fp)	# spill _tmp265 from $t3 to $fp-16
	sw $t4, -20($fp)	# spill _tmp266 from $t4 to $fp-20
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# PushParam num
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $t0, 8($fp)	# load num from $fp+8 into $t0
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp267 = "? "
	.data			# create string constant marked with label
	_string16: .asciiz "? "
	.text
	la $t0, _string16	# load label
	# PushParam _tmp267
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -24($fp)	# spill _tmp267 from $t0 to $fp-24
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp268 = LCall _ReadLine
	jal _ReadLine      	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# _tmp269 = 16
	li $t1, 16		# load constant value 16 into $t1
	# _tmp270 = this + _tmp269
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	add $t3, $t2, $t1	
	# *(_tmp270) = _tmp268
	sw $t0, 0($t3) 	# store with offset
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__Player.PrintName:
	# BeginFunc 4
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 4	# decrement sp to make space for locals/temps
	# _tmp271 = *(this + 16)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 16($t0) 	# load with offset
	# PushParam _tmp271
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t1, -8($fp)	# spill _tmp271 from $t1 to $fp-8
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__Player.Hit:
	# BeginFunc 160
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 160	# decrement sp to make space for locals/temps
	# _tmp272 = *(deck)
	lw $t0, 8($fp)	# load deck from $fp+8 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp273 = *(_tmp272)
	lw $t2, 0($t1) 	# load with offset
	# PushParam deck
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp274 = ACall _tmp273
	# (save modified registers before flow of control change)
	sw $t1, -12($fp)	# spill _tmp272 from $t1 to $fp-12
	sw $t2, -16($fp)	# spill _tmp273 from $t2 to $fp-16
	jalr $t2            	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# card = _tmp274
	move $t1, $t0		# copy value
	# _tmp275 = *(this + 16)
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	lw $t3, 16($t2) 	# load with offset
	# PushParam _tmp275
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t3, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -20($fp)	# spill _tmp274 from $t0 to $fp-20
	sw $t1, -8($fp)	# spill card from $t1 to $fp-8
	sw $t3, -24($fp)	# spill _tmp275 from $t3 to $fp-24
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp276 = " was dealt a "
	.data			# create string constant marked with label
	_string17: .asciiz " was dealt a "
	.text
	la $t0, _string17	# load label
	# PushParam _tmp276
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -28($fp)	# spill _tmp276 from $t0 to $fp-28
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# PushParam card
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $t0, -8($fp)	# load card from $fp-8 into $t0
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp277 = ".\n"
	.data			# create string constant marked with label
	_string18: .asciiz ".\n"
	.text
	la $t0, _string18	# load label
	# PushParam _tmp277
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -32($fp)	# spill _tmp277 from $t0 to $fp-32
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp278 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# _tmp279 = _tmp278 + card
	lw $t2, -8($fp)	# load card from $fp-8 into $t2
	add $t3, $t1, $t2	
	# _tmp280 = 24
	li $t4, 24		# load constant value 24 into $t4
	# _tmp281 = this + _tmp280
	add $t5, $t0, $t4	
	# *(_tmp281) = _tmp279
	sw $t3, 0($t5) 	# store with offset
	# _tmp282 = 1
	li $t6, 1		# load constant value 1 into $t6
	# _tmp283 = *(this + 20)
	lw $t7, 20($t0) 	# load with offset
	# _tmp284 = _tmp283 + _tmp282
	add $s0, $t7, $t6	
	# _tmp285 = 20
	li $s1, 20		# load constant value 20 into $s1
	# _tmp286 = this + _tmp285
	add $s2, $t0, $s1	
	# *(_tmp286) = _tmp284
	sw $s0, 0($s2) 	# store with offset
	# _tmp287 = 11
	li $s3, 11		# load constant value 11 into $s3
	# _tmp288 = card == _tmp287
	seq $s4, $t2, $s3	
	# IfZ _tmp288 Goto _L40
	# (save modified registers before flow of control change)
	sw $t1, -40($fp)	# spill _tmp278 from $t1 to $fp-40
	sw $t3, -36($fp)	# spill _tmp279 from $t3 to $fp-36
	sw $t4, -44($fp)	# spill _tmp280 from $t4 to $fp-44
	sw $t5, -48($fp)	# spill _tmp281 from $t5 to $fp-48
	sw $t6, -56($fp)	# spill _tmp282 from $t6 to $fp-56
	sw $t7, -60($fp)	# spill _tmp283 from $t7 to $fp-60
	sw $s0, -52($fp)	# spill _tmp284 from $s0 to $fp-52
	sw $s1, -64($fp)	# spill _tmp285 from $s1 to $fp-64
	sw $s2, -68($fp)	# spill _tmp286 from $s2 to $fp-68
	sw $s3, -72($fp)	# spill _tmp287 from $s3 to $fp-72
	sw $s4, -76($fp)	# spill _tmp288 from $s4 to $fp-76
	beqz $s4, _L40	# branch if _tmp288 is zero 
	# _tmp289 = 1
	li $t0, 1		# load constant value 1 into $t0
	# _tmp290 = *(this + 4)
	lw $t1, 4($fp)	# load this from $fp+4 into $t1
	lw $t2, 4($t1) 	# load with offset
	# _tmp291 = _tmp290 + _tmp289
	add $t3, $t2, $t0	
	# _tmp292 = 4
	li $t4, 4		# load constant value 4 into $t4
	# _tmp293 = this + _tmp292
	add $t5, $t1, $t4	
	# *(_tmp293) = _tmp291
	sw $t3, 0($t5) 	# store with offset
	# Goto _L41
	# (save modified registers before flow of control change)
	sw $t0, -84($fp)	# spill _tmp289 from $t0 to $fp-84
	sw $t2, -88($fp)	# spill _tmp290 from $t2 to $fp-88
	sw $t3, -80($fp)	# spill _tmp291 from $t3 to $fp-80
	sw $t4, -92($fp)	# spill _tmp292 from $t4 to $fp-92
	sw $t5, -96($fp)	# spill _tmp293 from $t5 to $fp-96
	b _L41		# unconditional branch
_L40:
_L41:
_L42:
	# _tmp294 = *(this + 4)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 4($t0) 	# load with offset
	# _tmp295 = 0
	li $t2, 0		# load constant value 0 into $t2
	# _tmp296 = _tmp295 < _tmp294
	slt $t3, $t2, $t1	
	# _tmp297 = *(this + 24)
	lw $t4, 24($t0) 	# load with offset
	# _tmp298 = 21
	li $t5, 21		# load constant value 21 into $t5
	# _tmp299 = _tmp298 < _tmp297
	slt $t6, $t5, $t4	
	# _tmp300 = _tmp299 && _tmp296
	and $t7, $t6, $t3	
	# IfZ _tmp300 Goto _L43
	# (save modified registers before flow of control change)
	sw $t1, -104($fp)	# spill _tmp294 from $t1 to $fp-104
	sw $t2, -108($fp)	# spill _tmp295 from $t2 to $fp-108
	sw $t3, -112($fp)	# spill _tmp296 from $t3 to $fp-112
	sw $t4, -116($fp)	# spill _tmp297 from $t4 to $fp-116
	sw $t5, -120($fp)	# spill _tmp298 from $t5 to $fp-120
	sw $t6, -124($fp)	# spill _tmp299 from $t6 to $fp-124
	sw $t7, -100($fp)	# spill _tmp300 from $t7 to $fp-100
	beqz $t7, _L43	# branch if _tmp300 is zero 
	# _tmp301 = 10
	li $t0, 10		# load constant value 10 into $t0
	# _tmp302 = *(this + 24)
	lw $t1, 4($fp)	# load this from $fp+4 into $t1
	lw $t2, 24($t1) 	# load with offset
	# _tmp303 = _tmp302 - _tmp301
	sub $t3, $t2, $t0	
	# _tmp304 = 24
	li $t4, 24		# load constant value 24 into $t4
	# _tmp305 = this + _tmp304
	add $t5, $t1, $t4	
	# *(_tmp305) = _tmp303
	sw $t3, 0($t5) 	# store with offset
	# _tmp306 = 1
	li $t6, 1		# load constant value 1 into $t6
	# _tmp307 = *(this + 4)
	lw $t7, 4($t1) 	# load with offset
	# _tmp308 = _tmp307 - _tmp306
	sub $s0, $t7, $t6	
	# _tmp309 = 4
	li $s1, 4		# load constant value 4 into $s1
	# _tmp310 = this + _tmp309
	add $s2, $t1, $s1	
	# *(_tmp310) = _tmp308
	sw $s0, 0($s2) 	# store with offset
	# Goto _L42
	# (save modified registers before flow of control change)
	sw $t0, -132($fp)	# spill _tmp301 from $t0 to $fp-132
	sw $t2, -136($fp)	# spill _tmp302 from $t2 to $fp-136
	sw $t3, -128($fp)	# spill _tmp303 from $t3 to $fp-128
	sw $t4, -140($fp)	# spill _tmp304 from $t4 to $fp-140
	sw $t5, -144($fp)	# spill _tmp305 from $t5 to $fp-144
	sw $t6, -152($fp)	# spill _tmp306 from $t6 to $fp-152
	sw $t7, -156($fp)	# spill _tmp307 from $t7 to $fp-156
	sw $s0, -148($fp)	# spill _tmp308 from $s0 to $fp-148
	sw $s1, -160($fp)	# spill _tmp309 from $s1 to $fp-160
	sw $s2, -164($fp)	# spill _tmp310 from $s2 to $fp-164
	b _L42		# unconditional branch
_L43:
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__Player.DoubleDown:
	# BeginFunc 112
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 112	# decrement sp to make space for locals/temps
	# _tmp311 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# _tmp312 = 11
	li $t2, 11		# load constant value 11 into $t2
	# _tmp313 = _tmp311 < _tmp312
	slt $t3, $t1, $t2	
	# _tmp314 = _tmp312 < _tmp311
	slt $t4, $t2, $t1	
	# _tmp315 = _tmp313 || _tmp314
	or $t5, $t3, $t4	
	# _tmp316 = *(this + 24)
	lw $t6, 24($t0) 	# load with offset
	# _tmp317 = 10
	li $t7, 10		# load constant value 10 into $t7
	# _tmp318 = _tmp316 < _tmp317
	slt $s0, $t6, $t7	
	# _tmp319 = _tmp317 < _tmp316
	slt $s1, $t7, $t6	
	# _tmp320 = _tmp318 || _tmp319
	or $s2, $s0, $s1	
	# _tmp321 = _tmp320 && _tmp315
	and $s3, $s2, $t5	
	# IfZ _tmp321 Goto _L44
	# (save modified registers before flow of control change)
	sw $t1, -16($fp)	# spill _tmp311 from $t1 to $fp-16
	sw $t2, -20($fp)	# spill _tmp312 from $t2 to $fp-20
	sw $t3, -24($fp)	# spill _tmp313 from $t3 to $fp-24
	sw $t4, -28($fp)	# spill _tmp314 from $t4 to $fp-28
	sw $t5, -32($fp)	# spill _tmp315 from $t5 to $fp-32
	sw $t6, -36($fp)	# spill _tmp316 from $t6 to $fp-36
	sw $t7, -40($fp)	# spill _tmp317 from $t7 to $fp-40
	sw $s0, -44($fp)	# spill _tmp318 from $s0 to $fp-44
	sw $s1, -48($fp)	# spill _tmp319 from $s1 to $fp-48
	sw $s2, -52($fp)	# spill _tmp320 from $s2 to $fp-52
	sw $s3, -12($fp)	# spill _tmp321 from $s3 to $fp-12
	beqz $s3, _L44	# branch if _tmp321 is zero 
	# _tmp322 = 0
	li $t0, 0		# load constant value 0 into $t0
	# Return _tmp322
	move $v0, $t0		# assign return value into $v0
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
	# Goto _L45
	b _L45		# unconditional branch
_L44:
_L45:
	# _tmp323 = "Would you like to double down?"
	.data			# create string constant marked with label
	_string19: .asciiz "Would you like to double down?"
	.text
	la $t0, _string19	# load label
	# PushParam _tmp323
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp324 = LCall __GetYesOrNo
	# (save modified registers before flow of control change)
	sw $t0, -60($fp)	# spill _tmp323 from $t0 to $fp-60
	jal __GetYesOrNo   	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# IfZ _tmp324 Goto _L46
	# (save modified registers before flow of control change)
	sw $t0, -64($fp)	# spill _tmp324 from $t0 to $fp-64
	beqz $t0, _L46	# branch if _tmp324 is zero 
	# _tmp325 = 2
	li $t0, 2		# load constant value 2 into $t0
	# _tmp326 = *(this + 8)
	lw $t1, 4($fp)	# load this from $fp+4 into $t1
	lw $t2, 8($t1) 	# load with offset
	# _tmp327 = _tmp326 * _tmp325
	mul $t3, $t2, $t0	
	# _tmp328 = 8
	li $t4, 8		# load constant value 8 into $t4
	# _tmp329 = this + _tmp328
	add $t5, $t1, $t4	
	# *(_tmp329) = _tmp327
	sw $t3, 0($t5) 	# store with offset
	# _tmp330 = *(this)
	lw $t6, 0($t1) 	# load with offset
	# _tmp331 = *(_tmp330 + 12)
	lw $t7, 12($t6) 	# load with offset
	# PushParam deck
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $s0, 8($fp)	# load deck from $fp+8 into $s0
	sw $s0, 4($sp)	# copy param value to stack
	# PushParam this
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# ACall _tmp331
	# (save modified registers before flow of control change)
	sw $t0, -72($fp)	# spill _tmp325 from $t0 to $fp-72
	sw $t2, -76($fp)	# spill _tmp326 from $t2 to $fp-76
	sw $t3, -68($fp)	# spill _tmp327 from $t3 to $fp-68
	sw $t4, -80($fp)	# spill _tmp328 from $t4 to $fp-80
	sw $t5, -84($fp)	# spill _tmp329 from $t5 to $fp-84
	sw $t6, -88($fp)	# spill _tmp330 from $t6 to $fp-88
	sw $t7, -92($fp)	# spill _tmp331 from $t7 to $fp-92
	jalr $t7            	# jump to function
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# _tmp332 = *(this + 16)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 16($t0) 	# load with offset
	# PushParam _tmp332
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t1, -96($fp)	# spill _tmp332 from $t1 to $fp-96
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp333 = ", your total is "
	.data			# create string constant marked with label
	_string20: .asciiz ", your total is "
	.text
	la $t0, _string20	# load label
	# PushParam _tmp333
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -100($fp)	# spill _tmp333 from $t0 to $fp-100
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp334 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# PushParam _tmp334
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -104($fp)	# spill _tmp334 from $t1 to $fp-104
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp335 = ".\n"
	.data			# create string constant marked with label
	_string21: .asciiz ".\n"
	.text
	la $t0, _string21	# load label
	# PushParam _tmp335
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -108($fp)	# spill _tmp335 from $t0 to $fp-108
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp336 = 1
	li $t0, 1		# load constant value 1 into $t0
	# Return _tmp336
	move $v0, $t0		# assign return value into $v0
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
	# Goto _L47
	b _L47		# unconditional branch
_L46:
_L47:
	# _tmp337 = 0
	li $t0, 0		# load constant value 0 into $t0
	# Return _tmp337
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
__Player.TakeTurn:
	# BeginFunc 192
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 192	# decrement sp to make space for locals/temps
	# _tmp338 = "\n"
	.data			# create string constant marked with label
	_string22: .asciiz "\n"
	.text
	la $t0, _string22	# load label
	# PushParam _tmp338
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -12($fp)	# spill _tmp338 from $t0 to $fp-12
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp339 = *(this + 16)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 16($t0) 	# load with offset
	# PushParam _tmp339
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t1, -16($fp)	# spill _tmp339 from $t1 to $fp-16
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp340 = "'s turn.\n"
	.data			# create string constant marked with label
	_string23: .asciiz "'s turn.\n"
	.text
	la $t0, _string23	# load label
	# PushParam _tmp340
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -20($fp)	# spill _tmp340 from $t0 to $fp-20
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp341 = 0
	li $t0, 0		# load constant value 0 into $t0
	# _tmp342 = 24
	li $t1, 24		# load constant value 24 into $t1
	# _tmp343 = this + _tmp342
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	add $t3, $t2, $t1	
	# *(_tmp343) = _tmp341
	sw $t0, 0($t3) 	# store with offset
	# _tmp344 = 0
	li $t4, 0		# load constant value 0 into $t4
	# _tmp345 = 4
	li $t5, 4		# load constant value 4 into $t5
	# _tmp346 = this + _tmp345
	add $t6, $t2, $t5	
	# *(_tmp346) = _tmp344
	sw $t4, 0($t6) 	# store with offset
	# _tmp347 = 0
	li $t7, 0		# load constant value 0 into $t7
	# _tmp348 = 20
	li $s0, 20		# load constant value 20 into $s0
	# _tmp349 = this + _tmp348
	add $s1, $t2, $s0	
	# *(_tmp349) = _tmp347
	sw $t7, 0($s1) 	# store with offset
	# _tmp350 = *(this)
	lw $s2, 0($t2) 	# load with offset
	# _tmp351 = *(_tmp350 + 12)
	lw $s3, 12($s2) 	# load with offset
	# PushParam deck
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $s4, 8($fp)	# load deck from $fp+8 into $s4
	sw $s4, 4($sp)	# copy param value to stack
	# PushParam this
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t2, 4($sp)	# copy param value to stack
	# ACall _tmp351
	# (save modified registers before flow of control change)
	sw $t0, -24($fp)	# spill _tmp341 from $t0 to $fp-24
	sw $t1, -28($fp)	# spill _tmp342 from $t1 to $fp-28
	sw $t3, -32($fp)	# spill _tmp343 from $t3 to $fp-32
	sw $t4, -36($fp)	# spill _tmp344 from $t4 to $fp-36
	sw $t5, -40($fp)	# spill _tmp345 from $t5 to $fp-40
	sw $t6, -44($fp)	# spill _tmp346 from $t6 to $fp-44
	sw $t7, -48($fp)	# spill _tmp347 from $t7 to $fp-48
	sw $s0, -52($fp)	# spill _tmp348 from $s0 to $fp-52
	sw $s1, -56($fp)	# spill _tmp349 from $s1 to $fp-56
	sw $s2, -60($fp)	# spill _tmp350 from $s2 to $fp-60
	sw $s3, -64($fp)	# spill _tmp351 from $s3 to $fp-64
	jalr $s3            	# jump to function
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# _tmp352 = *(this)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp353 = *(_tmp352 + 12)
	lw $t2, 12($t1) 	# load with offset
	# PushParam deck
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $t3, 8($fp)	# load deck from $fp+8 into $t3
	sw $t3, 4($sp)	# copy param value to stack
	# PushParam this
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# ACall _tmp353
	# (save modified registers before flow of control change)
	sw $t1, -68($fp)	# spill _tmp352 from $t1 to $fp-68
	sw $t2, -72($fp)	# spill _tmp353 from $t2 to $fp-72
	jalr $t2            	# jump to function
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# _tmp354 = 1
	li $t0, 1		# load constant value 1 into $t0
	# _tmp355 = *(this)
	lw $t1, 4($fp)	# load this from $fp+4 into $t1
	lw $t2, 0($t1) 	# load with offset
	# _tmp356 = *(_tmp355)
	lw $t3, 0($t2) 	# load with offset
	# PushParam deck
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $t4, 8($fp)	# load deck from $fp+8 into $t4
	sw $t4, 4($sp)	# copy param value to stack
	# PushParam this
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# _tmp357 = ACall _tmp356
	# (save modified registers before flow of control change)
	sw $t0, -76($fp)	# spill _tmp354 from $t0 to $fp-76
	sw $t2, -84($fp)	# spill _tmp355 from $t2 to $fp-84
	sw $t3, -88($fp)	# spill _tmp356 from $t3 to $fp-88
	jalr $t3            	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# _tmp358 = _tmp354 - _tmp357
	lw $t1, -76($fp)	# load _tmp354 from $fp-76 into $t1
	sub $t2, $t1, $t0	
	# IfZ _tmp358 Goto _L48
	# (save modified registers before flow of control change)
	sw $t0, -92($fp)	# spill _tmp357 from $t0 to $fp-92
	sw $t2, -80($fp)	# spill _tmp358 from $t2 to $fp-80
	beqz $t2, _L48	# branch if _tmp358 is zero 
	# _tmp359 = 1
	li $t0, 1		# load constant value 1 into $t0
	# stillGoing = _tmp359
	move $t1, $t0		# copy value
	# (save modified registers before flow of control change)
	sw $t0, -96($fp)	# spill _tmp359 from $t0 to $fp-96
	sw $t1, -8($fp)	# spill stillGoing from $t1 to $fp-8
_L50:
	# _tmp360 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# _tmp361 = 21
	li $t2, 21		# load constant value 21 into $t2
	# _tmp362 = _tmp360 < _tmp361
	slt $t3, $t1, $t2	
	# _tmp363 = _tmp360 == _tmp361
	seq $t4, $t1, $t2	
	# _tmp364 = _tmp362 || _tmp363
	or $t5, $t3, $t4	
	# _tmp365 = _tmp364 && stillGoing
	lw $t6, -8($fp)	# load stillGoing from $fp-8 into $t6
	and $t7, $t5, $t6	
	# IfZ _tmp365 Goto _L51
	# (save modified registers before flow of control change)
	sw $t1, -104($fp)	# spill _tmp360 from $t1 to $fp-104
	sw $t2, -108($fp)	# spill _tmp361 from $t2 to $fp-108
	sw $t3, -112($fp)	# spill _tmp362 from $t3 to $fp-112
	sw $t4, -116($fp)	# spill _tmp363 from $t4 to $fp-116
	sw $t5, -120($fp)	# spill _tmp364 from $t5 to $fp-120
	sw $t7, -100($fp)	# spill _tmp365 from $t7 to $fp-100
	beqz $t7, _L51	# branch if _tmp365 is zero 
	# _tmp366 = *(this + 16)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 16($t0) 	# load with offset
	# PushParam _tmp366
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t1, -124($fp)	# spill _tmp366 from $t1 to $fp-124
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp367 = ", your total is "
	.data			# create string constant marked with label
	_string24: .asciiz ", your total is "
	.text
	la $t0, _string24	# load label
	# PushParam _tmp367
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -128($fp)	# spill _tmp367 from $t0 to $fp-128
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp368 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# PushParam _tmp368
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -132($fp)	# spill _tmp368 from $t1 to $fp-132
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp369 = ".\n"
	.data			# create string constant marked with label
	_string25: .asciiz ".\n"
	.text
	la $t0, _string25	# load label
	# PushParam _tmp369
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -136($fp)	# spill _tmp369 from $t0 to $fp-136
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp370 = "Would you like a hit?"
	.data			# create string constant marked with label
	_string26: .asciiz "Would you like a hit?"
	.text
	la $t0, _string26	# load label
	# PushParam _tmp370
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp371 = LCall __GetYesOrNo
	# (save modified registers before flow of control change)
	sw $t0, -140($fp)	# spill _tmp370 from $t0 to $fp-140
	jal __GetYesOrNo   	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# stillGoing = _tmp371
	move $t1, $t0		# copy value
	# IfZ stillGoing Goto _L52
	# (save modified registers before flow of control change)
	sw $t0, -144($fp)	# spill _tmp371 from $t0 to $fp-144
	sw $t1, -8($fp)	# spill stillGoing from $t1 to $fp-8
	beqz $t1, _L52	# branch if stillGoing is zero 
	# _tmp372 = *(this)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp373 = *(_tmp372 + 12)
	lw $t2, 12($t1) 	# load with offset
	# PushParam deck
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $t3, 8($fp)	# load deck from $fp+8 into $t3
	sw $t3, 4($sp)	# copy param value to stack
	# PushParam this
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# ACall _tmp373
	# (save modified registers before flow of control change)
	sw $t1, -148($fp)	# spill _tmp372 from $t1 to $fp-148
	sw $t2, -152($fp)	# spill _tmp373 from $t2 to $fp-152
	jalr $t2            	# jump to function
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# Goto _L53
	b _L53		# unconditional branch
_L52:
_L53:
	# Goto _L50
	b _L50		# unconditional branch
_L51:
	# Goto _L49
	b _L49		# unconditional branch
_L48:
_L49:
	# _tmp374 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# _tmp375 = 21
	li $t2, 21		# load constant value 21 into $t2
	# _tmp376 = _tmp375 < _tmp374
	slt $t3, $t2, $t1	
	# IfZ _tmp376 Goto _L54
	# (save modified registers before flow of control change)
	sw $t1, -156($fp)	# spill _tmp374 from $t1 to $fp-156
	sw $t2, -160($fp)	# spill _tmp375 from $t2 to $fp-160
	sw $t3, -164($fp)	# spill _tmp376 from $t3 to $fp-164
	beqz $t3, _L54	# branch if _tmp376 is zero 
	# _tmp377 = *(this + 16)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 16($t0) 	# load with offset
	# PushParam _tmp377
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t1, -168($fp)	# spill _tmp377 from $t1 to $fp-168
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp378 = " busts with the big "
	.data			# create string constant marked with label
	_string27: .asciiz " busts with the big "
	.text
	la $t0, _string27	# load label
	# PushParam _tmp378
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -172($fp)	# spill _tmp378 from $t0 to $fp-172
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp379 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# PushParam _tmp379
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -176($fp)	# spill _tmp379 from $t1 to $fp-176
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp380 = "!\n"
	.data			# create string constant marked with label
	_string28: .asciiz "!\n"
	.text
	la $t0, _string28	# load label
	# PushParam _tmp380
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -180($fp)	# spill _tmp380 from $t0 to $fp-180
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# Goto _L55
	b _L55		# unconditional branch
_L54:
	# _tmp381 = *(this + 16)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 16($t0) 	# load with offset
	# PushParam _tmp381
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t1, -184($fp)	# spill _tmp381 from $t1 to $fp-184
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp382 = " stays at "
	.data			# create string constant marked with label
	_string29: .asciiz " stays at "
	.text
	la $t0, _string29	# load label
	# PushParam _tmp382
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -188($fp)	# spill _tmp382 from $t0 to $fp-188
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp383 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# PushParam _tmp383
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -192($fp)	# spill _tmp383 from $t1 to $fp-192
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp384 = ".\n"
	.data			# create string constant marked with label
	_string30: .asciiz ".\n"
	.text
	la $t0, _string30	# load label
	# PushParam _tmp384
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -196($fp)	# spill _tmp384 from $t0 to $fp-196
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
_L55:
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__Player.HasMoney:
	# BeginFunc 12
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 12	# decrement sp to make space for locals/temps
	# _tmp385 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# _tmp386 = 0
	li $t2, 0		# load constant value 0 into $t2
	# _tmp387 = _tmp386 < _tmp385
	slt $t3, $t2, $t1	
	# Return _tmp387
	move $v0, $t3		# assign return value into $v0
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
__Player.PrintMoney:
	# BeginFunc 16
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 16	# decrement sp to make space for locals/temps
	# _tmp388 = *(this + 16)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 16($t0) 	# load with offset
	# PushParam _tmp388
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t1, -8($fp)	# spill _tmp388 from $t1 to $fp-8
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp389 = ", you have $"
	.data			# create string constant marked with label
	_string31: .asciiz ", you have $"
	.text
	la $t0, _string31	# load label
	# PushParam _tmp389
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -12($fp)	# spill _tmp389 from $t0 to $fp-12
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp390 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# PushParam _tmp390
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -16($fp)	# spill _tmp390 from $t1 to $fp-16
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp391 = ".\n"
	.data			# create string constant marked with label
	_string32: .asciiz ".\n"
	.text
	la $t0, _string32	# load label
	# PushParam _tmp391
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -20($fp)	# spill _tmp391 from $t0 to $fp-20
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__Player.PlaceBet:
	# BeginFunc 72
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 72	# decrement sp to make space for locals/temps
	# _tmp392 = 0
	li $t0, 0		# load constant value 0 into $t0
	# _tmp393 = 8
	li $t1, 8		# load constant value 8 into $t1
	# _tmp394 = this + _tmp393
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	add $t3, $t2, $t1	
	# *(_tmp394) = _tmp392
	sw $t0, 0($t3) 	# store with offset
	# _tmp395 = *(this)
	lw $t4, 0($t2) 	# load with offset
	# _tmp396 = *(_tmp395 + 24)
	lw $t5, 24($t4) 	# load with offset
	# PushParam this
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t2, 4($sp)	# copy param value to stack
	# ACall _tmp396
	# (save modified registers before flow of control change)
	sw $t0, -8($fp)	# spill _tmp392 from $t0 to $fp-8
	sw $t1, -12($fp)	# spill _tmp393 from $t1 to $fp-12
	sw $t3, -16($fp)	# spill _tmp394 from $t3 to $fp-16
	sw $t4, -20($fp)	# spill _tmp395 from $t4 to $fp-20
	sw $t5, -24($fp)	# spill _tmp396 from $t5 to $fp-24
	jalr $t5            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
_L56:
	# _tmp397 = *(this + 8)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 8($t0) 	# load with offset
	# _tmp398 = *(this + 12)
	lw $t2, 12($t0) 	# load with offset
	# _tmp399 = _tmp398 < _tmp397
	slt $t3, $t2, $t1	
	# _tmp400 = *(this + 8)
	lw $t4, 8($t0) 	# load with offset
	# _tmp401 = 0
	li $t5, 0		# load constant value 0 into $t5
	# _tmp402 = _tmp400 < _tmp401
	slt $t6, $t4, $t5	
	# _tmp403 = _tmp400 == _tmp401
	seq $t7, $t4, $t5	
	# _tmp404 = _tmp402 || _tmp403
	or $s0, $t6, $t7	
	# _tmp405 = _tmp404 || _tmp399
	or $s1, $s0, $t3	
	# IfZ _tmp405 Goto _L57
	# (save modified registers before flow of control change)
	sw $t1, -32($fp)	# spill _tmp397 from $t1 to $fp-32
	sw $t2, -36($fp)	# spill _tmp398 from $t2 to $fp-36
	sw $t3, -40($fp)	# spill _tmp399 from $t3 to $fp-40
	sw $t4, -44($fp)	# spill _tmp400 from $t4 to $fp-44
	sw $t5, -48($fp)	# spill _tmp401 from $t5 to $fp-48
	sw $t6, -52($fp)	# spill _tmp402 from $t6 to $fp-52
	sw $t7, -56($fp)	# spill _tmp403 from $t7 to $fp-56
	sw $s0, -60($fp)	# spill _tmp404 from $s0 to $fp-60
	sw $s1, -28($fp)	# spill _tmp405 from $s1 to $fp-28
	beqz $s1, _L57	# branch if _tmp405 is zero 
	# _tmp406 = "How much would you like to bet? "
	.data			# create string constant marked with label
	_string33: .asciiz "How much would you like to bet? "
	.text
	la $t0, _string33	# load label
	# PushParam _tmp406
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -64($fp)	# spill _tmp406 from $t0 to $fp-64
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp407 = LCall _ReadInteger
	jal _ReadInteger   	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# _tmp408 = 8
	li $t1, 8		# load constant value 8 into $t1
	# _tmp409 = this + _tmp408
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	add $t3, $t2, $t1	
	# *(_tmp409) = _tmp407
	sw $t0, 0($t3) 	# store with offset
	# Goto _L56
	# (save modified registers before flow of control change)
	sw $t0, -68($fp)	# spill _tmp407 from $t0 to $fp-68
	sw $t1, -72($fp)	# spill _tmp408 from $t1 to $fp-72
	sw $t3, -76($fp)	# spill _tmp409 from $t3 to $fp-76
	b _L56		# unconditional branch
_L57:
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__Player.GetTotal:
	# BeginFunc 4
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 4	# decrement sp to make space for locals/temps
	# _tmp410 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# Return _tmp410
	move $v0, $t1		# assign return value into $v0
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
__Player.Resolve:
	# BeginFunc 208
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 208	# decrement sp to make space for locals/temps
	# _tmp411 = 0
	li $t0, 0		# load constant value 0 into $t0
	# win = _tmp411
	move $t1, $t0		# copy value
	# _tmp412 = 0
	li $t2, 0		# load constant value 0 into $t2
	# lose = _tmp412
	move $t3, $t2		# copy value
	# _tmp413 = *(this + 20)
	lw $t4, 4($fp)	# load this from $fp+4 into $t4
	lw $t5, 20($t4) 	# load with offset
	# _tmp414 = 2
	li $t6, 2		# load constant value 2 into $t6
	# _tmp415 = _tmp413 == _tmp414
	seq $t7, $t5, $t6	
	# _tmp416 = *(this + 24)
	lw $s0, 24($t4) 	# load with offset
	# _tmp417 = 21
	li $s1, 21		# load constant value 21 into $s1
	# _tmp418 = _tmp416 == _tmp417
	seq $s2, $s0, $s1	
	# _tmp419 = _tmp418 && _tmp415
	and $s3, $s2, $t7	
	# IfZ _tmp419 Goto _L58
	# (save modified registers before flow of control change)
	sw $t0, -16($fp)	# spill _tmp411 from $t0 to $fp-16
	sw $t1, -8($fp)	# spill win from $t1 to $fp-8
	sw $t2, -20($fp)	# spill _tmp412 from $t2 to $fp-20
	sw $t3, -12($fp)	# spill lose from $t3 to $fp-12
	sw $t5, -28($fp)	# spill _tmp413 from $t5 to $fp-28
	sw $t6, -32($fp)	# spill _tmp414 from $t6 to $fp-32
	sw $t7, -36($fp)	# spill _tmp415 from $t7 to $fp-36
	sw $s0, -40($fp)	# spill _tmp416 from $s0 to $fp-40
	sw $s1, -44($fp)	# spill _tmp417 from $s1 to $fp-44
	sw $s2, -48($fp)	# spill _tmp418 from $s2 to $fp-48
	sw $s3, -24($fp)	# spill _tmp419 from $s3 to $fp-24
	beqz $s3, _L58	# branch if _tmp419 is zero 
	# _tmp420 = 2
	li $t0, 2		# load constant value 2 into $t0
	# win = _tmp420
	move $t1, $t0		# copy value
	# Goto _L59
	# (save modified registers before flow of control change)
	sw $t0, -52($fp)	# spill _tmp420 from $t0 to $fp-52
	sw $t1, -8($fp)	# spill win from $t1 to $fp-8
	b _L59		# unconditional branch
_L58:
	# _tmp421 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# _tmp422 = 21
	li $t2, 21		# load constant value 21 into $t2
	# _tmp423 = _tmp422 < _tmp421
	slt $t3, $t2, $t1	
	# IfZ _tmp423 Goto _L60
	# (save modified registers before flow of control change)
	sw $t1, -56($fp)	# spill _tmp421 from $t1 to $fp-56
	sw $t2, -60($fp)	# spill _tmp422 from $t2 to $fp-60
	sw $t3, -64($fp)	# spill _tmp423 from $t3 to $fp-64
	beqz $t3, _L60	# branch if _tmp423 is zero 
	# _tmp424 = 1
	li $t0, 1		# load constant value 1 into $t0
	# lose = _tmp424
	move $t1, $t0		# copy value
	# Goto _L61
	# (save modified registers before flow of control change)
	sw $t0, -68($fp)	# spill _tmp424 from $t0 to $fp-68
	sw $t1, -12($fp)	# spill lose from $t1 to $fp-12
	b _L61		# unconditional branch
_L60:
	# _tmp425 = 21
	li $t0, 21		# load constant value 21 into $t0
	# _tmp426 = _tmp425 < dealer
	lw $t1, 8($fp)	# load dealer from $fp+8 into $t1
	slt $t2, $t0, $t1	
	# IfZ _tmp426 Goto _L62
	# (save modified registers before flow of control change)
	sw $t0, -72($fp)	# spill _tmp425 from $t0 to $fp-72
	sw $t2, -76($fp)	# spill _tmp426 from $t2 to $fp-76
	beqz $t2, _L62	# branch if _tmp426 is zero 
	# _tmp427 = 1
	li $t0, 1		# load constant value 1 into $t0
	# win = _tmp427
	move $t1, $t0		# copy value
	# Goto _L63
	# (save modified registers before flow of control change)
	sw $t0, -80($fp)	# spill _tmp427 from $t0 to $fp-80
	sw $t1, -8($fp)	# spill win from $t1 to $fp-8
	b _L63		# unconditional branch
_L62:
	# _tmp428 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# _tmp429 = dealer < _tmp428
	lw $t2, 8($fp)	# load dealer from $fp+8 into $t2
	slt $t3, $t2, $t1	
	# IfZ _tmp429 Goto _L64
	# (save modified registers before flow of control change)
	sw $t1, -84($fp)	# spill _tmp428 from $t1 to $fp-84
	sw $t3, -88($fp)	# spill _tmp429 from $t3 to $fp-88
	beqz $t3, _L64	# branch if _tmp429 is zero 
	# _tmp430 = 1
	li $t0, 1		# load constant value 1 into $t0
	# win = _tmp430
	move $t1, $t0		# copy value
	# Goto _L65
	# (save modified registers before flow of control change)
	sw $t0, -92($fp)	# spill _tmp430 from $t0 to $fp-92
	sw $t1, -8($fp)	# spill win from $t1 to $fp-8
	b _L65		# unconditional branch
_L64:
	# _tmp431 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# _tmp432 = _tmp431 < dealer
	lw $t2, 8($fp)	# load dealer from $fp+8 into $t2
	slt $t3, $t1, $t2	
	# IfZ _tmp432 Goto _L66
	# (save modified registers before flow of control change)
	sw $t1, -96($fp)	# spill _tmp431 from $t1 to $fp-96
	sw $t3, -100($fp)	# spill _tmp432 from $t3 to $fp-100
	beqz $t3, _L66	# branch if _tmp432 is zero 
	# _tmp433 = 1
	li $t0, 1		# load constant value 1 into $t0
	# lose = _tmp433
	move $t1, $t0		# copy value
	# Goto _L67
	# (save modified registers before flow of control change)
	sw $t0, -104($fp)	# spill _tmp433 from $t0 to $fp-104
	sw $t1, -12($fp)	# spill lose from $t1 to $fp-12
	b _L67		# unconditional branch
_L66:
_L67:
_L65:
_L63:
_L61:
_L59:
	# _tmp434 = 1
	li $t0, 1		# load constant value 1 into $t0
	# _tmp435 = _tmp434 < win
	lw $t1, -8($fp)	# load win from $fp-8 into $t1
	slt $t2, $t0, $t1	
	# _tmp436 = win == _tmp434
	seq $t3, $t1, $t0	
	# _tmp437 = _tmp435 || _tmp436
	or $t4, $t2, $t3	
	# IfZ _tmp437 Goto _L68
	# (save modified registers before flow of control change)
	sw $t0, -108($fp)	# spill _tmp434 from $t0 to $fp-108
	sw $t2, -112($fp)	# spill _tmp435 from $t2 to $fp-112
	sw $t3, -116($fp)	# spill _tmp436 from $t3 to $fp-116
	sw $t4, -120($fp)	# spill _tmp437 from $t4 to $fp-120
	beqz $t4, _L68	# branch if _tmp437 is zero 
	# _tmp438 = *(this + 16)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 16($t0) 	# load with offset
	# PushParam _tmp438
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t1, -124($fp)	# spill _tmp438 from $t1 to $fp-124
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp439 = ", you won $"
	.data			# create string constant marked with label
	_string34: .asciiz ", you won $"
	.text
	la $t0, _string34	# load label
	# PushParam _tmp439
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -128($fp)	# spill _tmp439 from $t0 to $fp-128
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp440 = *(this + 8)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 8($t0) 	# load with offset
	# PushParam _tmp440
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -132($fp)	# spill _tmp440 from $t1 to $fp-132
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp441 = ".\n"
	.data			# create string constant marked with label
	_string35: .asciiz ".\n"
	.text
	la $t0, _string35	# load label
	# PushParam _tmp441
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -136($fp)	# spill _tmp441 from $t0 to $fp-136
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# Goto _L69
	b _L69		# unconditional branch
_L68:
	# _tmp442 = 1
	li $t0, 1		# load constant value 1 into $t0
	# _tmp443 = _tmp442 < lose
	lw $t1, -12($fp)	# load lose from $fp-12 into $t1
	slt $t2, $t0, $t1	
	# _tmp444 = lose == _tmp442
	seq $t3, $t1, $t0	
	# _tmp445 = _tmp443 || _tmp444
	or $t4, $t2, $t3	
	# IfZ _tmp445 Goto _L70
	# (save modified registers before flow of control change)
	sw $t0, -140($fp)	# spill _tmp442 from $t0 to $fp-140
	sw $t2, -144($fp)	# spill _tmp443 from $t2 to $fp-144
	sw $t3, -148($fp)	# spill _tmp444 from $t3 to $fp-148
	sw $t4, -152($fp)	# spill _tmp445 from $t4 to $fp-152
	beqz $t4, _L70	# branch if _tmp445 is zero 
	# _tmp446 = *(this + 16)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 16($t0) 	# load with offset
	# PushParam _tmp446
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t1, -156($fp)	# spill _tmp446 from $t1 to $fp-156
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp447 = ", you lost $"
	.data			# create string constant marked with label
	_string36: .asciiz ", you lost $"
	.text
	la $t0, _string36	# load label
	# PushParam _tmp447
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -160($fp)	# spill _tmp447 from $t0 to $fp-160
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp448 = *(this + 8)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 8($t0) 	# load with offset
	# PushParam _tmp448
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -164($fp)	# spill _tmp448 from $t1 to $fp-164
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp449 = ".\n"
	.data			# create string constant marked with label
	_string37: .asciiz ".\n"
	.text
	la $t0, _string37	# load label
	# PushParam _tmp449
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -168($fp)	# spill _tmp449 from $t0 to $fp-168
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# Goto _L71
	b _L71		# unconditional branch
_L70:
	# _tmp450 = *(this + 16)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 16($t0) 	# load with offset
	# PushParam _tmp450
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t1, -172($fp)	# spill _tmp450 from $t1 to $fp-172
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp451 = ", you push!\n"
	.data			# create string constant marked with label
	_string38: .asciiz ", you push!\n"
	.text
	la $t0, _string38	# load label
	# PushParam _tmp451
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -176($fp)	# spill _tmp451 from $t0 to $fp-176
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
_L71:
_L69:
	# _tmp452 = *(this + 8)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 8($t0) 	# load with offset
	# _tmp453 = win * _tmp452
	lw $t2, -8($fp)	# load win from $fp-8 into $t2
	mul $t3, $t2, $t1	
	# win = _tmp453
	move $t2, $t3		# copy value
	# _tmp454 = *(this + 8)
	lw $t4, 8($t0) 	# load with offset
	# _tmp455 = lose * _tmp454
	lw $t5, -12($fp)	# load lose from $fp-12 into $t5
	mul $t6, $t5, $t4	
	# lose = _tmp455
	move $t5, $t6		# copy value
	# _tmp456 = *(this + 12)
	lw $t7, 12($t0) 	# load with offset
	# _tmp457 = _tmp456 + win
	add $s0, $t7, $t2	
	# _tmp458 = _tmp457 - lose
	sub $s1, $s0, $t5	
	# _tmp459 = 12
	li $s2, 12		# load constant value 12 into $s2
	# _tmp460 = this + _tmp459
	add $s3, $t0, $s2	
	# *(_tmp460) = _tmp458
	sw $s1, 0($s3) 	# store with offset
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
	# VTable for class Player
	.data
	.align 2
	Player:		# label for class Player vtable
	.word __Player.DoubleDown
	.word __Player.GetTotal
	.word __Player.HasMoney
	.word __Player.Hit
	.word __Player.Init
	.word __Player.PlaceBet
	.word __Player.PrintMoney
	.word __Player.PrintName
	.word __Player.Resolve
	.word __Player.TakeTurn
	.text
__Dealer.Init:
	# BeginFunc 48
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 48	# decrement sp to make space for locals/temps
	# _tmp461 = 0
	li $t0, 0		# load constant value 0 into $t0
	# _tmp462 = 24
	li $t1, 24		# load constant value 24 into $t1
	# _tmp463 = this + _tmp462
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	add $t3, $t2, $t1	
	# *(_tmp463) = _tmp461
	sw $t0, 0($t3) 	# store with offset
	# _tmp464 = 0
	li $t4, 0		# load constant value 0 into $t4
	# _tmp465 = 4
	li $t5, 4		# load constant value 4 into $t5
	# _tmp466 = this + _tmp465
	add $t6, $t2, $t5	
	# *(_tmp466) = _tmp464
	sw $t4, 0($t6) 	# store with offset
	# _tmp467 = 0
	li $t7, 0		# load constant value 0 into $t7
	# _tmp468 = 20
	li $s0, 20		# load constant value 20 into $s0
	# _tmp469 = this + _tmp468
	add $s1, $t2, $s0	
	# *(_tmp469) = _tmp467
	sw $t7, 0($s1) 	# store with offset
	# _tmp470 = "Dealer"
	.data			# create string constant marked with label
	_string39: .asciiz "Dealer"
	.text
	la $s2, _string39	# load label
	# _tmp471 = 16
	li $s3, 16		# load constant value 16 into $s3
	# _tmp472 = this + _tmp471
	add $s4, $t2, $s3	
	# *(_tmp472) = _tmp470
	sw $s2, 0($s4) 	# store with offset
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__Dealer.TakeTurn:
	# BeginFunc 84
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 84	# decrement sp to make space for locals/temps
	# _tmp473 = "\n"
	.data			# create string constant marked with label
	_string40: .asciiz "\n"
	.text
	la $t0, _string40	# load label
	# PushParam _tmp473
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -8($fp)	# spill _tmp473 from $t0 to $fp-8
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp474 = *(this + 16)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 16($t0) 	# load with offset
	# PushParam _tmp474
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t1, -12($fp)	# spill _tmp474 from $t1 to $fp-12
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp475 = "'s turn.\n"
	.data			# create string constant marked with label
	_string41: .asciiz "'s turn.\n"
	.text
	la $t0, _string41	# load label
	# PushParam _tmp475
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -16($fp)	# spill _tmp475 from $t0 to $fp-16
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
_L72:
	# _tmp476 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# _tmp477 = 16
	li $t2, 16		# load constant value 16 into $t2
	# _tmp478 = _tmp476 < _tmp477
	slt $t3, $t1, $t2	
	# _tmp479 = _tmp476 == _tmp477
	seq $t4, $t1, $t2	
	# _tmp480 = _tmp478 || _tmp479
	or $t5, $t3, $t4	
	# IfZ _tmp480 Goto _L73
	# (save modified registers before flow of control change)
	sw $t1, -20($fp)	# spill _tmp476 from $t1 to $fp-20
	sw $t2, -24($fp)	# spill _tmp477 from $t2 to $fp-24
	sw $t3, -28($fp)	# spill _tmp478 from $t3 to $fp-28
	sw $t4, -32($fp)	# spill _tmp479 from $t4 to $fp-32
	sw $t5, -36($fp)	# spill _tmp480 from $t5 to $fp-36
	beqz $t5, _L73	# branch if _tmp480 is zero 
	# _tmp481 = *(this)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp482 = *(_tmp481 + 12)
	lw $t2, 12($t1) 	# load with offset
	# PushParam deck
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $t3, 8($fp)	# load deck from $fp+8 into $t3
	sw $t3, 4($sp)	# copy param value to stack
	# PushParam this
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# ACall _tmp482
	# (save modified registers before flow of control change)
	sw $t1, -40($fp)	# spill _tmp481 from $t1 to $fp-40
	sw $t2, -44($fp)	# spill _tmp482 from $t2 to $fp-44
	jalr $t2            	# jump to function
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# Goto _L72
	b _L72		# unconditional branch
_L73:
	# _tmp483 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# _tmp484 = 21
	li $t2, 21		# load constant value 21 into $t2
	# _tmp485 = _tmp484 < _tmp483
	slt $t3, $t2, $t1	
	# IfZ _tmp485 Goto _L74
	# (save modified registers before flow of control change)
	sw $t1, -48($fp)	# spill _tmp483 from $t1 to $fp-48
	sw $t2, -52($fp)	# spill _tmp484 from $t2 to $fp-52
	sw $t3, -56($fp)	# spill _tmp485 from $t3 to $fp-56
	beqz $t3, _L74	# branch if _tmp485 is zero 
	# _tmp486 = *(this + 16)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 16($t0) 	# load with offset
	# PushParam _tmp486
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t1, -60($fp)	# spill _tmp486 from $t1 to $fp-60
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp487 = " busts with the big "
	.data			# create string constant marked with label
	_string42: .asciiz " busts with the big "
	.text
	la $t0, _string42	# load label
	# PushParam _tmp487
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -64($fp)	# spill _tmp487 from $t0 to $fp-64
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp488 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# PushParam _tmp488
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -68($fp)	# spill _tmp488 from $t1 to $fp-68
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp489 = "!\n"
	.data			# create string constant marked with label
	_string43: .asciiz "!\n"
	.text
	la $t0, _string43	# load label
	# PushParam _tmp489
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -72($fp)	# spill _tmp489 from $t0 to $fp-72
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# Goto _L75
	b _L75		# unconditional branch
_L74:
	# _tmp490 = *(this + 16)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 16($t0) 	# load with offset
	# PushParam _tmp490
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t1, -76($fp)	# spill _tmp490 from $t1 to $fp-76
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp491 = " stays at "
	.data			# create string constant marked with label
	_string44: .asciiz " stays at "
	.text
	la $t0, _string44	# load label
	# PushParam _tmp491
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -80($fp)	# spill _tmp491 from $t0 to $fp-80
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp492 = *(this + 24)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 24($t0) 	# load with offset
	# PushParam _tmp492
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# LCall _PrintInt
	# (save modified registers before flow of control change)
	sw $t1, -84($fp)	# spill _tmp492 from $t1 to $fp-84
	jal _PrintInt      	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp493 = ".\n"
	.data			# create string constant marked with label
	_string45: .asciiz ".\n"
	.text
	la $t0, _string45	# load label
	# PushParam _tmp493
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -88($fp)	# spill _tmp493 from $t0 to $fp-88
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
_L75:
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
	# VTable for class Dealer
	.data
	.align 2
	Dealer:		# label for class Dealer vtable
	.word __Player.DoubleDown
	.word __Player.GetTotal
	.word __Player.HasMoney
	.word __Player.Hit
	.word __Dealer.Init
	.word __Player.PlaceBet
	.word __Player.PrintMoney
	.word __Player.PrintName
	.word __Player.Resolve
	.word __Dealer.TakeTurn
	.text
__House.SetupGame:
	# BeginFunc 100
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 100	# decrement sp to make space for locals/temps
	# _tmp494 = "\nWelcome to CS143 BlackJack!\n"
	.data			# create string constant marked with label
	_string46: .asciiz "\nWelcome to CS143 BlackJack!\n"
	.text
	la $t0, _string46	# load label
	# PushParam _tmp494
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -8($fp)	# spill _tmp494 from $t0 to $fp-8
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp495 = "---------------------------\n"
	.data			# create string constant marked with label
	_string47: .asciiz "---------------------------\n"
	.text
	la $t0, _string47	# load label
	# PushParam _tmp495
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -12($fp)	# spill _tmp495 from $t0 to $fp-12
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp496 = 8
	li $t0, 8		# load constant value 8 into $t0
	# PushParam _tmp496
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp497 = LCall _Alloc
	# (save modified registers before flow of control change)
	sw $t0, -16($fp)	# spill _tmp496 from $t0 to $fp-16
	jal _Alloc         	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp498 = Random
	la $t1, Random	# load label
	# *(_tmp497) = _tmp498
	sw $t1, 0($t0) 	# store with offset
	# gRnd = _tmp497
	move $t2, $t0		# copy value
	# _tmp499 = "Please enter a random number seed: "
	.data			# create string constant marked with label
	_string48: .asciiz "Please enter a random number seed: "
	.text
	la $t3, _string48	# load label
	# PushParam _tmp499
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t3, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -20($fp)	# spill _tmp497 from $t0 to $fp-20
	sw $t1, -24($fp)	# spill _tmp498 from $t1 to $fp-24
	sw $t2, 4($gp)	# spill gRnd from $t2 to $gp+4
	sw $t3, -28($fp)	# spill _tmp499 from $t3 to $fp-28
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp500 = *(gRnd)
	lw $t0, 4($gp)	# load gRnd from $gp+4 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp501 = *(_tmp500 + 4)
	lw $t2, 4($t1) 	# load with offset
	# _tmp502 = LCall _ReadInteger
	# (save modified registers before flow of control change)
	sw $t1, -32($fp)	# spill _tmp500 from $t1 to $fp-32
	sw $t2, -36($fp)	# spill _tmp501 from $t2 to $fp-36
	jal _ReadInteger   	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PushParam _tmp502
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# PushParam gRnd
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $t1, 4($gp)	# load gRnd from $gp+4 into $t1
	sw $t1, 4($sp)	# copy param value to stack
	# ACall _tmp501
	lw $t2, -36($fp)	# load _tmp501 from $fp-36 into $t2
	# (save modified registers before flow of control change)
	sw $t0, -40($fp)	# spill _tmp502 from $t0 to $fp-40
	jalr $t2            	# jump to function
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# _tmp503 = 12
	li $t0, 12		# load constant value 12 into $t0
	# PushParam _tmp503
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp504 = LCall _Alloc
	# (save modified registers before flow of control change)
	sw $t0, -44($fp)	# spill _tmp503 from $t0 to $fp-44
	jal _Alloc         	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp505 = BJDeck
	la $t1, BJDeck	# load label
	# *(_tmp504) = _tmp505
	sw $t1, 0($t0) 	# store with offset
	# _tmp506 = 8
	li $t2, 8		# load constant value 8 into $t2
	# _tmp507 = this + _tmp506
	lw $t3, 4($fp)	# load this from $fp+4 into $t3
	add $t4, $t3, $t2	
	# *(_tmp507) = _tmp504
	sw $t0, 0($t4) 	# store with offset
	# _tmp508 = 28
	li $t5, 28		# load constant value 28 into $t5
	# PushParam _tmp508
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t5, 4($sp)	# copy param value to stack
	# _tmp509 = LCall _Alloc
	# (save modified registers before flow of control change)
	sw $t0, -48($fp)	# spill _tmp504 from $t0 to $fp-48
	sw $t1, -52($fp)	# spill _tmp505 from $t1 to $fp-52
	sw $t2, -56($fp)	# spill _tmp506 from $t2 to $fp-56
	sw $t4, -60($fp)	# spill _tmp507 from $t4 to $fp-60
	sw $t5, -64($fp)	# spill _tmp508 from $t5 to $fp-64
	jal _Alloc         	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp510 = Dealer
	la $t1, Dealer	# load label
	# *(_tmp509) = _tmp510
	sw $t1, 0($t0) 	# store with offset
	# _tmp511 = 4
	li $t2, 4		# load constant value 4 into $t2
	# _tmp512 = this + _tmp511
	lw $t3, 4($fp)	# load this from $fp+4 into $t3
	add $t4, $t3, $t2	
	# *(_tmp512) = _tmp509
	sw $t0, 0($t4) 	# store with offset
	# _tmp513 = *(this + 8)
	lw $t5, 8($t3) 	# load with offset
	# _tmp514 = *(_tmp513)
	lw $t6, 0($t5) 	# load with offset
	# _tmp515 = *(_tmp514 + 4)
	lw $t7, 4($t6) 	# load with offset
	# PushParam _tmp513
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t5, 4($sp)	# copy param value to stack
	# ACall _tmp515
	# (save modified registers before flow of control change)
	sw $t0, -68($fp)	# spill _tmp509 from $t0 to $fp-68
	sw $t1, -72($fp)	# spill _tmp510 from $t1 to $fp-72
	sw $t2, -76($fp)	# spill _tmp511 from $t2 to $fp-76
	sw $t4, -80($fp)	# spill _tmp512 from $t4 to $fp-80
	sw $t5, -84($fp)	# spill _tmp513 from $t5 to $fp-84
	sw $t6, -88($fp)	# spill _tmp514 from $t6 to $fp-88
	sw $t7, -92($fp)	# spill _tmp515 from $t7 to $fp-92
	jalr $t7            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp516 = *(this + 8)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 8($t0) 	# load with offset
	# _tmp517 = *(_tmp516)
	lw $t2, 0($t1) 	# load with offset
	# _tmp518 = *(_tmp517 + 12)
	lw $t3, 12($t2) 	# load with offset
	# PushParam _tmp516
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# ACall _tmp518
	# (save modified registers before flow of control change)
	sw $t1, -96($fp)	# spill _tmp516 from $t1 to $fp-96
	sw $t2, -100($fp)	# spill _tmp517 from $t2 to $fp-100
	sw $t3, -104($fp)	# spill _tmp518 from $t3 to $fp-104
	jalr $t3            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__House.SetupPlayers:
	# BeginFunc 196
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 196	# decrement sp to make space for locals/temps
	# _tmp519 = "How many players do we have today? "
	.data			# create string constant marked with label
	_string49: .asciiz "How many players do we have today? "
	.text
	la $t0, _string49	# load label
	# PushParam _tmp519
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -16($fp)	# spill _tmp519 from $t0 to $fp-16
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp520 = LCall _ReadInteger
	jal _ReadInteger   	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# numPlayers = _tmp520
	move $t1, $t0		# copy value
	# _tmp521 = 0
	li $t2, 0		# load constant value 0 into $t2
	# _tmp522 = numPlayers < _tmp521
	slt $t3, $t1, $t2	
	# _tmp523 = numPlayers == _tmp521
	seq $t4, $t1, $t2	
	# _tmp524 = _tmp522 || _tmp523
	or $t5, $t3, $t4	
	# IfZ _tmp524 Goto _L76
	# (save modified registers before flow of control change)
	sw $t0, -20($fp)	# spill _tmp520 from $t0 to $fp-20
	sw $t1, -12($fp)	# spill numPlayers from $t1 to $fp-12
	sw $t2, -24($fp)	# spill _tmp521 from $t2 to $fp-24
	sw $t3, -28($fp)	# spill _tmp522 from $t3 to $fp-28
	sw $t4, -32($fp)	# spill _tmp523 from $t4 to $fp-32
	sw $t5, -36($fp)	# spill _tmp524 from $t5 to $fp-36
	beqz $t5, _L76	# branch if _tmp524 is zero 
	# _tmp525 = "Decaf runtime error: Array size is <= 0"
	.data			# create string constant marked with label
	_string50: .asciiz "Decaf runtime error: Array size is <= 0"
	.text
	la $t0, _string50	# load label
	# PushParam _tmp525
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -40($fp)	# spill _tmp525 from $t0 to $fp-40
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L76:
	# _tmp526 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp527 = numPlayers * _tmp526
	lw $t1, -12($fp)	# load numPlayers from $fp-12 into $t1
	mul $t2, $t1, $t0	
	# _tmp528 = _tmp527 + _tmp526
	add $t3, $t2, $t0	
	# PushParam _tmp528
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t3, 4($sp)	# copy param value to stack
	# _tmp529 = LCall _Alloc
	# (save modified registers before flow of control change)
	sw $t0, -44($fp)	# spill _tmp526 from $t0 to $fp-44
	sw $t2, -48($fp)	# spill _tmp527 from $t2 to $fp-48
	sw $t3, -52($fp)	# spill _tmp528 from $t3 to $fp-52
	jal _Alloc         	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# *(_tmp529) = numPlayers
	lw $t1, -12($fp)	# load numPlayers from $fp-12 into $t1
	sw $t1, 0($t0) 	# store with offset
	# _tmp530 = 12
	li $t2, 12		# load constant value 12 into $t2
	# _tmp531 = this + _tmp530
	lw $t3, 4($fp)	# load this from $fp+4 into $t3
	add $t4, $t3, $t2	
	# *(_tmp531) = _tmp529
	sw $t0, 0($t4) 	# store with offset
	# _tmp532 = 0
	li $t5, 0		# load constant value 0 into $t5
	# i = _tmp532
	move $t6, $t5		# copy value
	# (save modified registers before flow of control change)
	sw $t0, -56($fp)	# spill _tmp529 from $t0 to $fp-56
	sw $t2, -60($fp)	# spill _tmp530 from $t2 to $fp-60
	sw $t4, -64($fp)	# spill _tmp531 from $t4 to $fp-64
	sw $t5, -68($fp)	# spill _tmp532 from $t5 to $fp-68
	sw $t6, -8($fp)	# spill i from $t6 to $fp-8
_L77:
	# _tmp533 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# _tmp534 = *(_tmp533)
	lw $t2, 0($t1) 	# load with offset
	# _tmp535 = i < _tmp534
	lw $t3, -8($fp)	# load i from $fp-8 into $t3
	slt $t4, $t3, $t2	
	# IfZ _tmp535 Goto _L78
	# (save modified registers before flow of control change)
	sw $t1, -76($fp)	# spill _tmp533 from $t1 to $fp-76
	sw $t2, -72($fp)	# spill _tmp534 from $t2 to $fp-72
	sw $t4, -80($fp)	# spill _tmp535 from $t4 to $fp-80
	beqz $t4, _L78	# branch if _tmp535 is zero 
	# _tmp536 = 28
	li $t0, 28		# load constant value 28 into $t0
	# PushParam _tmp536
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp537 = LCall _Alloc
	# (save modified registers before flow of control change)
	sw $t0, -84($fp)	# spill _tmp536 from $t0 to $fp-84
	jal _Alloc         	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp538 = Player
	la $t1, Player	# load label
	# *(_tmp537) = _tmp538
	sw $t1, 0($t0) 	# store with offset
	# _tmp539 = *(this + 12)
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	lw $t3, 12($t2) 	# load with offset
	# _tmp540 = *(_tmp539)
	lw $t4, 0($t3) 	# load with offset
	# _tmp541 = i < _tmp540
	lw $t5, -8($fp)	# load i from $fp-8 into $t5
	slt $t6, $t5, $t4	
	# _tmp542 = -1
	li $t7, -1		# load constant value -1 into $t7
	# _tmp543 = _tmp542 < i
	slt $s0, $t7, $t5	
	# _tmp544 = _tmp543 && _tmp541
	and $s1, $s0, $t6	
	# IfZ _tmp544 Goto _L79
	# (save modified registers before flow of control change)
	sw $t0, -88($fp)	# spill _tmp537 from $t0 to $fp-88
	sw $t1, -92($fp)	# spill _tmp538 from $t1 to $fp-92
	sw $t3, -96($fp)	# spill _tmp539 from $t3 to $fp-96
	sw $t4, -100($fp)	# spill _tmp540 from $t4 to $fp-100
	sw $t6, -104($fp)	# spill _tmp541 from $t6 to $fp-104
	sw $t7, -108($fp)	# spill _tmp542 from $t7 to $fp-108
	sw $s0, -112($fp)	# spill _tmp543 from $s0 to $fp-112
	sw $s1, -116($fp)	# spill _tmp544 from $s1 to $fp-116
	beqz $s1, _L79	# branch if _tmp544 is zero 
	# _tmp545 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp546 = i * _tmp545
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	mul $t2, $t1, $t0	
	# _tmp547 = _tmp546 + _tmp545
	add $t3, $t2, $t0	
	# _tmp548 = _tmp539 + _tmp547
	lw $t4, -96($fp)	# load _tmp539 from $fp-96 into $t4
	add $t5, $t4, $t3	
	# Goto _L80
	# (save modified registers before flow of control change)
	sw $t0, -120($fp)	# spill _tmp545 from $t0 to $fp-120
	sw $t2, -124($fp)	# spill _tmp546 from $t2 to $fp-124
	sw $t3, -128($fp)	# spill _tmp547 from $t3 to $fp-128
	sw $t5, -128($fp)	# spill _tmp548 from $t5 to $fp-128
	b _L80		# unconditional branch
_L79:
	# _tmp549 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string51: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string51	# load label
	# PushParam _tmp549
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -132($fp)	# spill _tmp549 from $t0 to $fp-132
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L80:
	# *(_tmp548) = _tmp537
	lw $t0, -88($fp)	# load _tmp537 from $fp-88 into $t0
	lw $t1, -128($fp)	# load _tmp548 from $fp-128 into $t1
	sw $t0, 0($t1) 	# store with offset
	# _tmp550 = *(this + 12)
	lw $t2, 4($fp)	# load this from $fp+4 into $t2
	lw $t3, 12($t2) 	# load with offset
	# _tmp551 = *(_tmp550)
	lw $t4, 0($t3) 	# load with offset
	# _tmp552 = i < _tmp551
	lw $t5, -8($fp)	# load i from $fp-8 into $t5
	slt $t6, $t5, $t4	
	# _tmp553 = -1
	li $t7, -1		# load constant value -1 into $t7
	# _tmp554 = _tmp553 < i
	slt $s0, $t7, $t5	
	# _tmp555 = _tmp554 && _tmp552
	and $s1, $s0, $t6	
	# IfZ _tmp555 Goto _L81
	# (save modified registers before flow of control change)
	sw $t3, -136($fp)	# spill _tmp550 from $t3 to $fp-136
	sw $t4, -140($fp)	# spill _tmp551 from $t4 to $fp-140
	sw $t6, -144($fp)	# spill _tmp552 from $t6 to $fp-144
	sw $t7, -148($fp)	# spill _tmp553 from $t7 to $fp-148
	sw $s0, -152($fp)	# spill _tmp554 from $s0 to $fp-152
	sw $s1, -156($fp)	# spill _tmp555 from $s1 to $fp-156
	beqz $s1, _L81	# branch if _tmp555 is zero 
	# _tmp556 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp557 = i * _tmp556
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	mul $t2, $t1, $t0	
	# _tmp558 = _tmp557 + _tmp556
	add $t3, $t2, $t0	
	# _tmp559 = _tmp550 + _tmp558
	lw $t4, -136($fp)	# load _tmp550 from $fp-136 into $t4
	add $t5, $t4, $t3	
	# Goto _L82
	# (save modified registers before flow of control change)
	sw $t0, -160($fp)	# spill _tmp556 from $t0 to $fp-160
	sw $t2, -164($fp)	# spill _tmp557 from $t2 to $fp-164
	sw $t3, -168($fp)	# spill _tmp558 from $t3 to $fp-168
	sw $t5, -168($fp)	# spill _tmp559 from $t5 to $fp-168
	b _L82		# unconditional branch
_L81:
	# _tmp560 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string52: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string52	# load label
	# PushParam _tmp560
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -172($fp)	# spill _tmp560 from $t0 to $fp-172
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L82:
	# _tmp561 = *(_tmp559)
	lw $t0, -168($fp)	# load _tmp559 from $fp-168 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp562 = *(_tmp561)
	lw $t2, 0($t1) 	# load with offset
	# _tmp563 = *(_tmp562 + 16)
	lw $t3, 16($t2) 	# load with offset
	# _tmp564 = 1
	li $t4, 1		# load constant value 1 into $t4
	# _tmp565 = i + _tmp564
	lw $t5, -8($fp)	# load i from $fp-8 into $t5
	add $t6, $t5, $t4	
	# PushParam _tmp565
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t6, 4($sp)	# copy param value to stack
	# PushParam _tmp561
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# ACall _tmp563
	# (save modified registers before flow of control change)
	sw $t1, -176($fp)	# spill _tmp561 from $t1 to $fp-176
	sw $t2, -180($fp)	# spill _tmp562 from $t2 to $fp-180
	sw $t3, -184($fp)	# spill _tmp563 from $t3 to $fp-184
	sw $t4, -192($fp)	# spill _tmp564 from $t4 to $fp-192
	sw $t6, -188($fp)	# spill _tmp565 from $t6 to $fp-188
	jalr $t3            	# jump to function
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# _tmp566 = 1
	li $t0, 1		# load constant value 1 into $t0
	# _tmp567 = i + _tmp566
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	add $t2, $t1, $t0	
	# i = _tmp567
	move $t1, $t2		# copy value
	# Goto _L77
	# (save modified registers before flow of control change)
	sw $t0, -200($fp)	# spill _tmp566 from $t0 to $fp-200
	sw $t1, -8($fp)	# spill i from $t1 to $fp-8
	sw $t2, -196($fp)	# spill _tmp567 from $t2 to $fp-196
	b _L77		# unconditional branch
_L78:
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__House.TakeAllBets:
	# BeginFunc 140
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 140	# decrement sp to make space for locals/temps
	# _tmp568 = "\nFirst, let's take bets.\n"
	.data			# create string constant marked with label
	_string53: .asciiz "\nFirst, let's take bets.\n"
	.text
	la $t0, _string53	# load label
	# PushParam _tmp568
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -12($fp)	# spill _tmp568 from $t0 to $fp-12
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp569 = 0
	li $t0, 0		# load constant value 0 into $t0
	# i = _tmp569
	move $t1, $t0		# copy value
	# (save modified registers before flow of control change)
	sw $t0, -16($fp)	# spill _tmp569 from $t0 to $fp-16
	sw $t1, -8($fp)	# spill i from $t1 to $fp-8
_L83:
	# _tmp570 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# _tmp571 = *(_tmp570)
	lw $t2, 0($t1) 	# load with offset
	# _tmp572 = i < _tmp571
	lw $t3, -8($fp)	# load i from $fp-8 into $t3
	slt $t4, $t3, $t2	
	# IfZ _tmp572 Goto _L84
	# (save modified registers before flow of control change)
	sw $t1, -24($fp)	# spill _tmp570 from $t1 to $fp-24
	sw $t2, -20($fp)	# spill _tmp571 from $t2 to $fp-20
	sw $t4, -28($fp)	# spill _tmp572 from $t4 to $fp-28
	beqz $t4, _L84	# branch if _tmp572 is zero 
	# _tmp573 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# _tmp574 = *(_tmp573)
	lw $t2, 0($t1) 	# load with offset
	# _tmp575 = i < _tmp574
	lw $t3, -8($fp)	# load i from $fp-8 into $t3
	slt $t4, $t3, $t2	
	# _tmp576 = -1
	li $t5, -1		# load constant value -1 into $t5
	# _tmp577 = _tmp576 < i
	slt $t6, $t5, $t3	
	# _tmp578 = _tmp577 && _tmp575
	and $t7, $t6, $t4	
	# IfZ _tmp578 Goto _L87
	# (save modified registers before flow of control change)
	sw $t1, -32($fp)	# spill _tmp573 from $t1 to $fp-32
	sw $t2, -36($fp)	# spill _tmp574 from $t2 to $fp-36
	sw $t4, -40($fp)	# spill _tmp575 from $t4 to $fp-40
	sw $t5, -44($fp)	# spill _tmp576 from $t5 to $fp-44
	sw $t6, -48($fp)	# spill _tmp577 from $t6 to $fp-48
	sw $t7, -52($fp)	# spill _tmp578 from $t7 to $fp-52
	beqz $t7, _L87	# branch if _tmp578 is zero 
	# _tmp579 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp580 = i * _tmp579
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	mul $t2, $t1, $t0	
	# _tmp581 = _tmp580 + _tmp579
	add $t3, $t2, $t0	
	# _tmp582 = _tmp573 + _tmp581
	lw $t4, -32($fp)	# load _tmp573 from $fp-32 into $t4
	add $t5, $t4, $t3	
	# Goto _L88
	# (save modified registers before flow of control change)
	sw $t0, -56($fp)	# spill _tmp579 from $t0 to $fp-56
	sw $t2, -60($fp)	# spill _tmp580 from $t2 to $fp-60
	sw $t3, -64($fp)	# spill _tmp581 from $t3 to $fp-64
	sw $t5, -64($fp)	# spill _tmp582 from $t5 to $fp-64
	b _L88		# unconditional branch
_L87:
	# _tmp583 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string54: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string54	# load label
	# PushParam _tmp583
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -68($fp)	# spill _tmp583 from $t0 to $fp-68
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L88:
	# _tmp584 = *(_tmp582)
	lw $t0, -64($fp)	# load _tmp582 from $fp-64 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp585 = *(_tmp584)
	lw $t2, 0($t1) 	# load with offset
	# _tmp586 = *(_tmp585 + 8)
	lw $t3, 8($t2) 	# load with offset
	# PushParam _tmp584
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# _tmp587 = ACall _tmp586
	# (save modified registers before flow of control change)
	sw $t1, -72($fp)	# spill _tmp584 from $t1 to $fp-72
	sw $t2, -76($fp)	# spill _tmp585 from $t2 to $fp-76
	sw $t3, -80($fp)	# spill _tmp586 from $t3 to $fp-80
	jalr $t3            	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# IfZ _tmp587 Goto _L85
	# (save modified registers before flow of control change)
	sw $t0, -84($fp)	# spill _tmp587 from $t0 to $fp-84
	beqz $t0, _L85	# branch if _tmp587 is zero 
	# _tmp588 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# _tmp589 = *(_tmp588)
	lw $t2, 0($t1) 	# load with offset
	# _tmp590 = i < _tmp589
	lw $t3, -8($fp)	# load i from $fp-8 into $t3
	slt $t4, $t3, $t2	
	# _tmp591 = -1
	li $t5, -1		# load constant value -1 into $t5
	# _tmp592 = _tmp591 < i
	slt $t6, $t5, $t3	
	# _tmp593 = _tmp592 && _tmp590
	and $t7, $t6, $t4	
	# IfZ _tmp593 Goto _L89
	# (save modified registers before flow of control change)
	sw $t1, -88($fp)	# spill _tmp588 from $t1 to $fp-88
	sw $t2, -92($fp)	# spill _tmp589 from $t2 to $fp-92
	sw $t4, -96($fp)	# spill _tmp590 from $t4 to $fp-96
	sw $t5, -100($fp)	# spill _tmp591 from $t5 to $fp-100
	sw $t6, -104($fp)	# spill _tmp592 from $t6 to $fp-104
	sw $t7, -108($fp)	# spill _tmp593 from $t7 to $fp-108
	beqz $t7, _L89	# branch if _tmp593 is zero 
	# _tmp594 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp595 = i * _tmp594
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	mul $t2, $t1, $t0	
	# _tmp596 = _tmp595 + _tmp594
	add $t3, $t2, $t0	
	# _tmp597 = _tmp588 + _tmp596
	lw $t4, -88($fp)	# load _tmp588 from $fp-88 into $t4
	add $t5, $t4, $t3	
	# Goto _L90
	# (save modified registers before flow of control change)
	sw $t0, -112($fp)	# spill _tmp594 from $t0 to $fp-112
	sw $t2, -116($fp)	# spill _tmp595 from $t2 to $fp-116
	sw $t3, -120($fp)	# spill _tmp596 from $t3 to $fp-120
	sw $t5, -120($fp)	# spill _tmp597 from $t5 to $fp-120
	b _L90		# unconditional branch
_L89:
	# _tmp598 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string55: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string55	# load label
	# PushParam _tmp598
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -124($fp)	# spill _tmp598 from $t0 to $fp-124
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L90:
	# _tmp599 = *(_tmp597)
	lw $t0, -120($fp)	# load _tmp597 from $fp-120 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp600 = *(_tmp599)
	lw $t2, 0($t1) 	# load with offset
	# _tmp601 = *(_tmp600 + 20)
	lw $t3, 20($t2) 	# load with offset
	# PushParam _tmp599
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# ACall _tmp601
	# (save modified registers before flow of control change)
	sw $t1, -128($fp)	# spill _tmp599 from $t1 to $fp-128
	sw $t2, -132($fp)	# spill _tmp600 from $t2 to $fp-132
	sw $t3, -136($fp)	# spill _tmp601 from $t3 to $fp-136
	jalr $t3            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# Goto _L86
	b _L86		# unconditional branch
_L85:
_L86:
	# _tmp602 = 1
	li $t0, 1		# load constant value 1 into $t0
	# _tmp603 = i + _tmp602
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	add $t2, $t1, $t0	
	# i = _tmp603
	move $t1, $t2		# copy value
	# Goto _L83
	# (save modified registers before flow of control change)
	sw $t0, -144($fp)	# spill _tmp602 from $t0 to $fp-144
	sw $t1, -8($fp)	# spill i from $t1 to $fp-8
	sw $t2, -140($fp)	# spill _tmp603 from $t2 to $fp-140
	b _L83		# unconditional branch
_L84:
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__House.TakeAllTurns:
	# BeginFunc 140
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 140	# decrement sp to make space for locals/temps
	# _tmp604 = 0
	li $t0, 0		# load constant value 0 into $t0
	# i = _tmp604
	move $t1, $t0		# copy value
	# (save modified registers before flow of control change)
	sw $t0, -12($fp)	# spill _tmp604 from $t0 to $fp-12
	sw $t1, -8($fp)	# spill i from $t1 to $fp-8
_L91:
	# _tmp605 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# _tmp606 = *(_tmp605)
	lw $t2, 0($t1) 	# load with offset
	# _tmp607 = i < _tmp606
	lw $t3, -8($fp)	# load i from $fp-8 into $t3
	slt $t4, $t3, $t2	
	# IfZ _tmp607 Goto _L92
	# (save modified registers before flow of control change)
	sw $t1, -20($fp)	# spill _tmp605 from $t1 to $fp-20
	sw $t2, -16($fp)	# spill _tmp606 from $t2 to $fp-16
	sw $t4, -24($fp)	# spill _tmp607 from $t4 to $fp-24
	beqz $t4, _L92	# branch if _tmp607 is zero 
	# _tmp608 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# _tmp609 = *(_tmp608)
	lw $t2, 0($t1) 	# load with offset
	# _tmp610 = i < _tmp609
	lw $t3, -8($fp)	# load i from $fp-8 into $t3
	slt $t4, $t3, $t2	
	# _tmp611 = -1
	li $t5, -1		# load constant value -1 into $t5
	# _tmp612 = _tmp611 < i
	slt $t6, $t5, $t3	
	# _tmp613 = _tmp612 && _tmp610
	and $t7, $t6, $t4	
	# IfZ _tmp613 Goto _L95
	# (save modified registers before flow of control change)
	sw $t1, -28($fp)	# spill _tmp608 from $t1 to $fp-28
	sw $t2, -32($fp)	# spill _tmp609 from $t2 to $fp-32
	sw $t4, -36($fp)	# spill _tmp610 from $t4 to $fp-36
	sw $t5, -40($fp)	# spill _tmp611 from $t5 to $fp-40
	sw $t6, -44($fp)	# spill _tmp612 from $t6 to $fp-44
	sw $t7, -48($fp)	# spill _tmp613 from $t7 to $fp-48
	beqz $t7, _L95	# branch if _tmp613 is zero 
	# _tmp614 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp615 = i * _tmp614
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	mul $t2, $t1, $t0	
	# _tmp616 = _tmp615 + _tmp614
	add $t3, $t2, $t0	
	# _tmp617 = _tmp608 + _tmp616
	lw $t4, -28($fp)	# load _tmp608 from $fp-28 into $t4
	add $t5, $t4, $t3	
	# Goto _L96
	# (save modified registers before flow of control change)
	sw $t0, -52($fp)	# spill _tmp614 from $t0 to $fp-52
	sw $t2, -56($fp)	# spill _tmp615 from $t2 to $fp-56
	sw $t3, -60($fp)	# spill _tmp616 from $t3 to $fp-60
	sw $t5, -60($fp)	# spill _tmp617 from $t5 to $fp-60
	b _L96		# unconditional branch
_L95:
	# _tmp618 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string56: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string56	# load label
	# PushParam _tmp618
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -64($fp)	# spill _tmp618 from $t0 to $fp-64
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L96:
	# _tmp619 = *(_tmp617)
	lw $t0, -60($fp)	# load _tmp617 from $fp-60 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp620 = *(_tmp619)
	lw $t2, 0($t1) 	# load with offset
	# _tmp621 = *(_tmp620 + 8)
	lw $t3, 8($t2) 	# load with offset
	# PushParam _tmp619
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# _tmp622 = ACall _tmp621
	# (save modified registers before flow of control change)
	sw $t1, -68($fp)	# spill _tmp619 from $t1 to $fp-68
	sw $t2, -72($fp)	# spill _tmp620 from $t2 to $fp-72
	sw $t3, -76($fp)	# spill _tmp621 from $t3 to $fp-76
	jalr $t3            	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# IfZ _tmp622 Goto _L93
	# (save modified registers before flow of control change)
	sw $t0, -80($fp)	# spill _tmp622 from $t0 to $fp-80
	beqz $t0, _L93	# branch if _tmp622 is zero 
	# _tmp623 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# _tmp624 = *(_tmp623)
	lw $t2, 0($t1) 	# load with offset
	# _tmp625 = i < _tmp624
	lw $t3, -8($fp)	# load i from $fp-8 into $t3
	slt $t4, $t3, $t2	
	# _tmp626 = -1
	li $t5, -1		# load constant value -1 into $t5
	# _tmp627 = _tmp626 < i
	slt $t6, $t5, $t3	
	# _tmp628 = _tmp627 && _tmp625
	and $t7, $t6, $t4	
	# IfZ _tmp628 Goto _L97
	# (save modified registers before flow of control change)
	sw $t1, -84($fp)	# spill _tmp623 from $t1 to $fp-84
	sw $t2, -88($fp)	# spill _tmp624 from $t2 to $fp-88
	sw $t4, -92($fp)	# spill _tmp625 from $t4 to $fp-92
	sw $t5, -96($fp)	# spill _tmp626 from $t5 to $fp-96
	sw $t6, -100($fp)	# spill _tmp627 from $t6 to $fp-100
	sw $t7, -104($fp)	# spill _tmp628 from $t7 to $fp-104
	beqz $t7, _L97	# branch if _tmp628 is zero 
	# _tmp629 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp630 = i * _tmp629
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	mul $t2, $t1, $t0	
	# _tmp631 = _tmp630 + _tmp629
	add $t3, $t2, $t0	
	# _tmp632 = _tmp623 + _tmp631
	lw $t4, -84($fp)	# load _tmp623 from $fp-84 into $t4
	add $t5, $t4, $t3	
	# Goto _L98
	# (save modified registers before flow of control change)
	sw $t0, -108($fp)	# spill _tmp629 from $t0 to $fp-108
	sw $t2, -112($fp)	# spill _tmp630 from $t2 to $fp-112
	sw $t3, -116($fp)	# spill _tmp631 from $t3 to $fp-116
	sw $t5, -116($fp)	# spill _tmp632 from $t5 to $fp-116
	b _L98		# unconditional branch
_L97:
	# _tmp633 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string57: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string57	# load label
	# PushParam _tmp633
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -120($fp)	# spill _tmp633 from $t0 to $fp-120
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L98:
	# _tmp634 = *(_tmp632)
	lw $t0, -116($fp)	# load _tmp632 from $fp-116 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp635 = *(_tmp634)
	lw $t2, 0($t1) 	# load with offset
	# _tmp636 = *(_tmp635 + 36)
	lw $t3, 36($t2) 	# load with offset
	# _tmp637 = *(this + 8)
	lw $t4, 4($fp)	# load this from $fp+4 into $t4
	lw $t5, 8($t4) 	# load with offset
	# PushParam _tmp637
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t5, 4($sp)	# copy param value to stack
	# PushParam _tmp634
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# ACall _tmp636
	# (save modified registers before flow of control change)
	sw $t1, -124($fp)	# spill _tmp634 from $t1 to $fp-124
	sw $t2, -128($fp)	# spill _tmp635 from $t2 to $fp-128
	sw $t3, -132($fp)	# spill _tmp636 from $t3 to $fp-132
	sw $t5, -136($fp)	# spill _tmp637 from $t5 to $fp-136
	jalr $t3            	# jump to function
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# Goto _L94
	b _L94		# unconditional branch
_L93:
_L94:
	# _tmp638 = 1
	li $t0, 1		# load constant value 1 into $t0
	# _tmp639 = i + _tmp638
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	add $t2, $t1, $t0	
	# i = _tmp639
	move $t1, $t2		# copy value
	# Goto _L91
	# (save modified registers before flow of control change)
	sw $t0, -144($fp)	# spill _tmp638 from $t0 to $fp-144
	sw $t1, -8($fp)	# spill i from $t1 to $fp-8
	sw $t2, -140($fp)	# spill _tmp639 from $t2 to $fp-140
	b _L91		# unconditional branch
_L92:
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__House.ResolveAllPlayers:
	# BeginFunc 156
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 156	# decrement sp to make space for locals/temps
	# _tmp640 = "\nTime to resolve bets.\n"
	.data			# create string constant marked with label
	_string58: .asciiz "\nTime to resolve bets.\n"
	.text
	la $t0, _string58	# load label
	# PushParam _tmp640
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -12($fp)	# spill _tmp640 from $t0 to $fp-12
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp641 = 0
	li $t0, 0		# load constant value 0 into $t0
	# i = _tmp641
	move $t1, $t0		# copy value
	# (save modified registers before flow of control change)
	sw $t0, -16($fp)	# spill _tmp641 from $t0 to $fp-16
	sw $t1, -8($fp)	# spill i from $t1 to $fp-8
_L99:
	# _tmp642 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# _tmp643 = *(_tmp642)
	lw $t2, 0($t1) 	# load with offset
	# _tmp644 = i < _tmp643
	lw $t3, -8($fp)	# load i from $fp-8 into $t3
	slt $t4, $t3, $t2	
	# IfZ _tmp644 Goto _L100
	# (save modified registers before flow of control change)
	sw $t1, -24($fp)	# spill _tmp642 from $t1 to $fp-24
	sw $t2, -20($fp)	# spill _tmp643 from $t2 to $fp-20
	sw $t4, -28($fp)	# spill _tmp644 from $t4 to $fp-28
	beqz $t4, _L100	# branch if _tmp644 is zero 
	# _tmp645 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# _tmp646 = *(_tmp645)
	lw $t2, 0($t1) 	# load with offset
	# _tmp647 = i < _tmp646
	lw $t3, -8($fp)	# load i from $fp-8 into $t3
	slt $t4, $t3, $t2	
	# _tmp648 = -1
	li $t5, -1		# load constant value -1 into $t5
	# _tmp649 = _tmp648 < i
	slt $t6, $t5, $t3	
	# _tmp650 = _tmp649 && _tmp647
	and $t7, $t6, $t4	
	# IfZ _tmp650 Goto _L103
	# (save modified registers before flow of control change)
	sw $t1, -32($fp)	# spill _tmp645 from $t1 to $fp-32
	sw $t2, -36($fp)	# spill _tmp646 from $t2 to $fp-36
	sw $t4, -40($fp)	# spill _tmp647 from $t4 to $fp-40
	sw $t5, -44($fp)	# spill _tmp648 from $t5 to $fp-44
	sw $t6, -48($fp)	# spill _tmp649 from $t6 to $fp-48
	sw $t7, -52($fp)	# spill _tmp650 from $t7 to $fp-52
	beqz $t7, _L103	# branch if _tmp650 is zero 
	# _tmp651 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp652 = i * _tmp651
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	mul $t2, $t1, $t0	
	# _tmp653 = _tmp652 + _tmp651
	add $t3, $t2, $t0	
	# _tmp654 = _tmp645 + _tmp653
	lw $t4, -32($fp)	# load _tmp645 from $fp-32 into $t4
	add $t5, $t4, $t3	
	# Goto _L104
	# (save modified registers before flow of control change)
	sw $t0, -56($fp)	# spill _tmp651 from $t0 to $fp-56
	sw $t2, -60($fp)	# spill _tmp652 from $t2 to $fp-60
	sw $t3, -64($fp)	# spill _tmp653 from $t3 to $fp-64
	sw $t5, -64($fp)	# spill _tmp654 from $t5 to $fp-64
	b _L104		# unconditional branch
_L103:
	# _tmp655 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string59: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string59	# load label
	# PushParam _tmp655
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -68($fp)	# spill _tmp655 from $t0 to $fp-68
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L104:
	# _tmp656 = *(_tmp654)
	lw $t0, -64($fp)	# load _tmp654 from $fp-64 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp657 = *(_tmp656)
	lw $t2, 0($t1) 	# load with offset
	# _tmp658 = *(_tmp657 + 8)
	lw $t3, 8($t2) 	# load with offset
	# PushParam _tmp656
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# _tmp659 = ACall _tmp658
	# (save modified registers before flow of control change)
	sw $t1, -72($fp)	# spill _tmp656 from $t1 to $fp-72
	sw $t2, -76($fp)	# spill _tmp657 from $t2 to $fp-76
	sw $t3, -80($fp)	# spill _tmp658 from $t3 to $fp-80
	jalr $t3            	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# IfZ _tmp659 Goto _L101
	# (save modified registers before flow of control change)
	sw $t0, -84($fp)	# spill _tmp659 from $t0 to $fp-84
	beqz $t0, _L101	# branch if _tmp659 is zero 
	# _tmp660 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# _tmp661 = *(_tmp660)
	lw $t2, 0($t1) 	# load with offset
	# _tmp662 = i < _tmp661
	lw $t3, -8($fp)	# load i from $fp-8 into $t3
	slt $t4, $t3, $t2	
	# _tmp663 = -1
	li $t5, -1		# load constant value -1 into $t5
	# _tmp664 = _tmp663 < i
	slt $t6, $t5, $t3	
	# _tmp665 = _tmp664 && _tmp662
	and $t7, $t6, $t4	
	# IfZ _tmp665 Goto _L105
	# (save modified registers before flow of control change)
	sw $t1, -88($fp)	# spill _tmp660 from $t1 to $fp-88
	sw $t2, -92($fp)	# spill _tmp661 from $t2 to $fp-92
	sw $t4, -96($fp)	# spill _tmp662 from $t4 to $fp-96
	sw $t5, -100($fp)	# spill _tmp663 from $t5 to $fp-100
	sw $t6, -104($fp)	# spill _tmp664 from $t6 to $fp-104
	sw $t7, -108($fp)	# spill _tmp665 from $t7 to $fp-108
	beqz $t7, _L105	# branch if _tmp665 is zero 
	# _tmp666 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp667 = i * _tmp666
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	mul $t2, $t1, $t0	
	# _tmp668 = _tmp667 + _tmp666
	add $t3, $t2, $t0	
	# _tmp669 = _tmp660 + _tmp668
	lw $t4, -88($fp)	# load _tmp660 from $fp-88 into $t4
	add $t5, $t4, $t3	
	# Goto _L106
	# (save modified registers before flow of control change)
	sw $t0, -112($fp)	# spill _tmp666 from $t0 to $fp-112
	sw $t2, -116($fp)	# spill _tmp667 from $t2 to $fp-116
	sw $t3, -120($fp)	# spill _tmp668 from $t3 to $fp-120
	sw $t5, -120($fp)	# spill _tmp669 from $t5 to $fp-120
	b _L106		# unconditional branch
_L105:
	# _tmp670 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string60: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string60	# load label
	# PushParam _tmp670
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -124($fp)	# spill _tmp670 from $t0 to $fp-124
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L106:
	# _tmp671 = *(_tmp669)
	lw $t0, -120($fp)	# load _tmp669 from $fp-120 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp672 = *(_tmp671)
	lw $t2, 0($t1) 	# load with offset
	# _tmp673 = *(_tmp672 + 32)
	lw $t3, 32($t2) 	# load with offset
	# _tmp674 = *(this + 4)
	lw $t4, 4($fp)	# load this from $fp+4 into $t4
	lw $t5, 4($t4) 	# load with offset
	# _tmp675 = *(_tmp674)
	lw $t6, 0($t5) 	# load with offset
	# _tmp676 = *(_tmp675 + 4)
	lw $t7, 4($t6) 	# load with offset
	# PushParam _tmp674
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t5, 4($sp)	# copy param value to stack
	# _tmp677 = ACall _tmp676
	# (save modified registers before flow of control change)
	sw $t1, -128($fp)	# spill _tmp671 from $t1 to $fp-128
	sw $t2, -132($fp)	# spill _tmp672 from $t2 to $fp-132
	sw $t3, -136($fp)	# spill _tmp673 from $t3 to $fp-136
	sw $t5, -140($fp)	# spill _tmp674 from $t5 to $fp-140
	sw $t6, -144($fp)	# spill _tmp675 from $t6 to $fp-144
	sw $t7, -148($fp)	# spill _tmp676 from $t7 to $fp-148
	jalr $t7            	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# PushParam _tmp677
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# PushParam _tmp671
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $t1, -128($fp)	# load _tmp671 from $fp-128 into $t1
	sw $t1, 4($sp)	# copy param value to stack
	# ACall _tmp673
	lw $t2, -136($fp)	# load _tmp673 from $fp-136 into $t2
	# (save modified registers before flow of control change)
	sw $t0, -152($fp)	# spill _tmp677 from $t0 to $fp-152
	jalr $t2            	# jump to function
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# Goto _L102
	b _L102		# unconditional branch
_L101:
_L102:
	# _tmp678 = 1
	li $t0, 1		# load constant value 1 into $t0
	# _tmp679 = i + _tmp678
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	add $t2, $t1, $t0	
	# i = _tmp679
	move $t1, $t2		# copy value
	# Goto _L99
	# (save modified registers before flow of control change)
	sw $t0, -160($fp)	# spill _tmp678 from $t0 to $fp-160
	sw $t1, -8($fp)	# spill i from $t1 to $fp-8
	sw $t2, -156($fp)	# spill _tmp679 from $t2 to $fp-156
	b _L99		# unconditional branch
_L100:
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__House.PrintAllMoney:
	# BeginFunc 80
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 80	# decrement sp to make space for locals/temps
	# _tmp680 = 0
	li $t0, 0		# load constant value 0 into $t0
	# i = _tmp680
	move $t1, $t0		# copy value
	# (save modified registers before flow of control change)
	sw $t0, -12($fp)	# spill _tmp680 from $t0 to $fp-12
	sw $t1, -8($fp)	# spill i from $t1 to $fp-8
_L107:
	# _tmp681 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# _tmp682 = *(_tmp681)
	lw $t2, 0($t1) 	# load with offset
	# _tmp683 = i < _tmp682
	lw $t3, -8($fp)	# load i from $fp-8 into $t3
	slt $t4, $t3, $t2	
	# IfZ _tmp683 Goto _L108
	# (save modified registers before flow of control change)
	sw $t1, -20($fp)	# spill _tmp681 from $t1 to $fp-20
	sw $t2, -16($fp)	# spill _tmp682 from $t2 to $fp-16
	sw $t4, -24($fp)	# spill _tmp683 from $t4 to $fp-24
	beqz $t4, _L108	# branch if _tmp683 is zero 
	# _tmp684 = *(this + 12)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 12($t0) 	# load with offset
	# _tmp685 = *(_tmp684)
	lw $t2, 0($t1) 	# load with offset
	# _tmp686 = i < _tmp685
	lw $t3, -8($fp)	# load i from $fp-8 into $t3
	slt $t4, $t3, $t2	
	# _tmp687 = -1
	li $t5, -1		# load constant value -1 into $t5
	# _tmp688 = _tmp687 < i
	slt $t6, $t5, $t3	
	# _tmp689 = _tmp688 && _tmp686
	and $t7, $t6, $t4	
	# IfZ _tmp689 Goto _L109
	# (save modified registers before flow of control change)
	sw $t1, -28($fp)	# spill _tmp684 from $t1 to $fp-28
	sw $t2, -32($fp)	# spill _tmp685 from $t2 to $fp-32
	sw $t4, -36($fp)	# spill _tmp686 from $t4 to $fp-36
	sw $t5, -40($fp)	# spill _tmp687 from $t5 to $fp-40
	sw $t6, -44($fp)	# spill _tmp688 from $t6 to $fp-44
	sw $t7, -48($fp)	# spill _tmp689 from $t7 to $fp-48
	beqz $t7, _L109	# branch if _tmp689 is zero 
	# _tmp690 = 4
	li $t0, 4		# load constant value 4 into $t0
	# _tmp691 = i * _tmp690
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	mul $t2, $t1, $t0	
	# _tmp692 = _tmp691 + _tmp690
	add $t3, $t2, $t0	
	# _tmp693 = _tmp684 + _tmp692
	lw $t4, -28($fp)	# load _tmp684 from $fp-28 into $t4
	add $t5, $t4, $t3	
	# Goto _L110
	# (save modified registers before flow of control change)
	sw $t0, -52($fp)	# spill _tmp690 from $t0 to $fp-52
	sw $t2, -56($fp)	# spill _tmp691 from $t2 to $fp-56
	sw $t3, -60($fp)	# spill _tmp692 from $t3 to $fp-60
	sw $t5, -60($fp)	# spill _tmp693 from $t5 to $fp-60
	b _L110		# unconditional branch
_L109:
	# _tmp694 = "Decaf runtime error: Array script out of bounds"
	.data			# create string constant marked with label
	_string61: .asciiz "Decaf runtime error: Array script out of bounds"
	.text
	la $t0, _string61	# load label
	# PushParam _tmp694
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -64($fp)	# spill _tmp694 from $t0 to $fp-64
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# LCall _Halt
	jal _Halt          	# jump to function
_L110:
	# _tmp695 = *(_tmp693)
	lw $t0, -60($fp)	# load _tmp693 from $fp-60 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp696 = *(_tmp695)
	lw $t2, 0($t1) 	# load with offset
	# _tmp697 = *(_tmp696 + 24)
	lw $t3, 24($t2) 	# load with offset
	# PushParam _tmp695
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# ACall _tmp697
	# (save modified registers before flow of control change)
	sw $t1, -68($fp)	# spill _tmp695 from $t1 to $fp-68
	sw $t2, -72($fp)	# spill _tmp696 from $t2 to $fp-72
	sw $t3, -76($fp)	# spill _tmp697 from $t3 to $fp-76
	jalr $t3            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp698 = 1
	li $t0, 1		# load constant value 1 into $t0
	# _tmp699 = i + _tmp698
	lw $t1, -8($fp)	# load i from $fp-8 into $t1
	add $t2, $t1, $t0	
	# i = _tmp699
	move $t1, $t2		# copy value
	# Goto _L107
	# (save modified registers before flow of control change)
	sw $t0, -84($fp)	# spill _tmp698 from $t0 to $fp-84
	sw $t1, -8($fp)	# spill i from $t1 to $fp-8
	sw $t2, -80($fp)	# spill _tmp699 from $t2 to $fp-80
	b _L107		# unconditional branch
_L108:
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
__House.PlayOneGame:
	# BeginFunc 112
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 112	# decrement sp to make space for locals/temps
	# _tmp700 = *(this + 8)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 8($t0) 	# load with offset
	# _tmp701 = *(_tmp700)
	lw $t2, 0($t1) 	# load with offset
	# _tmp702 = *(_tmp701 + 8)
	lw $t3, 8($t2) 	# load with offset
	# PushParam _tmp700
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# _tmp703 = ACall _tmp702
	# (save modified registers before flow of control change)
	sw $t1, -8($fp)	# spill _tmp700 from $t1 to $fp-8
	sw $t2, -12($fp)	# spill _tmp701 from $t2 to $fp-12
	sw $t3, -16($fp)	# spill _tmp702 from $t3 to $fp-16
	jalr $t3            	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp704 = 26
	li $t1, 26		# load constant value 26 into $t1
	# _tmp705 = _tmp703 < _tmp704
	slt $t2, $t0, $t1	
	# IfZ _tmp705 Goto _L111
	# (save modified registers before flow of control change)
	sw $t0, -20($fp)	# spill _tmp703 from $t0 to $fp-20
	sw $t1, -24($fp)	# spill _tmp704 from $t1 to $fp-24
	sw $t2, -28($fp)	# spill _tmp705 from $t2 to $fp-28
	beqz $t2, _L111	# branch if _tmp705 is zero 
	# _tmp706 = *(this + 8)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 8($t0) 	# load with offset
	# _tmp707 = *(_tmp706)
	lw $t2, 0($t1) 	# load with offset
	# _tmp708 = *(_tmp707 + 12)
	lw $t3, 12($t2) 	# load with offset
	# PushParam _tmp706
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# ACall _tmp708
	# (save modified registers before flow of control change)
	sw $t1, -32($fp)	# spill _tmp706 from $t1 to $fp-32
	sw $t2, -36($fp)	# spill _tmp707 from $t2 to $fp-36
	sw $t3, -40($fp)	# spill _tmp708 from $t3 to $fp-40
	jalr $t3            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# Goto _L112
	b _L112		# unconditional branch
_L111:
_L112:
	# _tmp709 = *(this)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp710 = *(_tmp709 + 20)
	lw $t2, 20($t1) 	# load with offset
	# PushParam this
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# ACall _tmp710
	# (save modified registers before flow of control change)
	sw $t1, -44($fp)	# spill _tmp709 from $t1 to $fp-44
	sw $t2, -48($fp)	# spill _tmp710 from $t2 to $fp-48
	jalr $t2            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp711 = "\nDealer starts. "
	.data			# create string constant marked with label
	_string62: .asciiz "\nDealer starts. "
	.text
	la $t0, _string62	# load label
	# PushParam _tmp711
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -52($fp)	# spill _tmp711 from $t0 to $fp-52
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp712 = *(this + 4)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 4($t0) 	# load with offset
	# _tmp713 = *(_tmp712)
	lw $t2, 0($t1) 	# load with offset
	# _tmp714 = *(_tmp713 + 16)
	lw $t3, 16($t2) 	# load with offset
	# _tmp715 = 0
	li $t4, 0		# load constant value 0 into $t4
	# PushParam _tmp715
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t4, 4($sp)	# copy param value to stack
	# PushParam _tmp712
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# ACall _tmp714
	# (save modified registers before flow of control change)
	sw $t1, -56($fp)	# spill _tmp712 from $t1 to $fp-56
	sw $t2, -60($fp)	# spill _tmp713 from $t2 to $fp-60
	sw $t3, -64($fp)	# spill _tmp714 from $t3 to $fp-64
	sw $t4, -68($fp)	# spill _tmp715 from $t4 to $fp-68
	jalr $t3            	# jump to function
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# _tmp716 = *(this + 4)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 4($t0) 	# load with offset
	# _tmp717 = *(_tmp716)
	lw $t2, 0($t1) 	# load with offset
	# _tmp718 = *(_tmp717 + 12)
	lw $t3, 12($t2) 	# load with offset
	# _tmp719 = *(this + 8)
	lw $t4, 8($t0) 	# load with offset
	# PushParam _tmp719
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t4, 4($sp)	# copy param value to stack
	# PushParam _tmp716
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# ACall _tmp718
	# (save modified registers before flow of control change)
	sw $t1, -72($fp)	# spill _tmp716 from $t1 to $fp-72
	sw $t2, -76($fp)	# spill _tmp717 from $t2 to $fp-76
	sw $t3, -80($fp)	# spill _tmp718 from $t3 to $fp-80
	sw $t4, -84($fp)	# spill _tmp719 from $t4 to $fp-84
	jalr $t3            	# jump to function
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# _tmp720 = *(this)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp721 = *(_tmp720 + 24)
	lw $t2, 24($t1) 	# load with offset
	# PushParam this
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# ACall _tmp721
	# (save modified registers before flow of control change)
	sw $t1, -88($fp)	# spill _tmp720 from $t1 to $fp-88
	sw $t2, -92($fp)	# spill _tmp721 from $t2 to $fp-92
	jalr $t2            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp722 = *(this + 4)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 4($t0) 	# load with offset
	# _tmp723 = *(_tmp722)
	lw $t2, 0($t1) 	# load with offset
	# _tmp724 = *(_tmp723 + 36)
	lw $t3, 36($t2) 	# load with offset
	# _tmp725 = *(this + 8)
	lw $t4, 8($t0) 	# load with offset
	# PushParam _tmp725
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t4, 4($sp)	# copy param value to stack
	# PushParam _tmp722
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# ACall _tmp724
	# (save modified registers before flow of control change)
	sw $t1, -96($fp)	# spill _tmp722 from $t1 to $fp-96
	sw $t2, -100($fp)	# spill _tmp723 from $t2 to $fp-100
	sw $t3, -104($fp)	# spill _tmp724 from $t3 to $fp-104
	sw $t4, -108($fp)	# spill _tmp725 from $t4 to $fp-108
	jalr $t3            	# jump to function
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# _tmp726 = *(this)
	lw $t0, 4($fp)	# load this from $fp+4 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp727 = *(_tmp726 + 8)
	lw $t2, 8($t1) 	# load with offset
	# PushParam this
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# ACall _tmp727
	# (save modified registers before flow of control change)
	sw $t1, -112($fp)	# spill _tmp726 from $t1 to $fp-112
	sw $t2, -116($fp)	# spill _tmp727 from $t2 to $fp-116
	jalr $t2            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
	# VTable for class House
	.data
	.align 2
	House:		# label for class House vtable
	.word __House.PlayOneGame
	.word __House.PrintAllMoney
	.word __House.ResolveAllPlayers
	.word __House.SetupGame
	.word __House.SetupPlayers
	.word __House.TakeAllBets
	.word __House.TakeAllTurns
	.text
__GetYesOrNo:
	# BeginFunc 40
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 40	# decrement sp to make space for locals/temps
	# PushParam prompt
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $t0, 4($fp)	# load prompt from $fp+4 into $t0
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp728 = " (y/n) "
	.data			# create string constant marked with label
	_string63: .asciiz " (y/n) "
	.text
	la $t0, _string63	# load label
	# PushParam _tmp728
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -12($fp)	# spill _tmp728 from $t0 to $fp-12
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp729 = LCall _ReadLine
	jal _ReadLine      	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# answer = _tmp729
	move $t1, $t0		# copy value
	# _tmp730 = "y"
	.data			# create string constant marked with label
	_string64: .asciiz "y"
	.text
	la $t2, _string64	# load label
	# PushParam _tmp730
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t2, 4($sp)	# copy param value to stack
	# PushParam answer
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# _tmp731 = LCall _StringEqual
	# (save modified registers before flow of control change)
	sw $t0, -16($fp)	# spill _tmp729 from $t0 to $fp-16
	sw $t1, -8($fp)	# spill answer from $t1 to $fp-8
	sw $t2, -24($fp)	# spill _tmp730 from $t2 to $fp-24
	jal _StringEqual   	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# PushParam _tmp731
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintBool
	# (save modified registers before flow of control change)
	sw $t0, -20($fp)	# spill _tmp731 from $t0 to $fp-20
	jal _PrintBool     	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp732 = "Y"
	.data			# create string constant marked with label
	_string65: .asciiz "Y"
	.text
	la $t0, _string65	# load label
	# PushParam _tmp732
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# PushParam answer
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $t1, -8($fp)	# load answer from $fp-8 into $t1
	sw $t1, 4($sp)	# copy param value to stack
	# _tmp733 = LCall _StringEqual
	# (save modified registers before flow of control change)
	sw $t0, -36($fp)	# spill _tmp732 from $t0 to $fp-36
	jal _StringEqual   	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# _tmp734 = "y"
	.data			# create string constant marked with label
	_string66: .asciiz "y"
	.text
	la $t1, _string66	# load label
	# PushParam _tmp734
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t1, 4($sp)	# copy param value to stack
	# PushParam answer
	subu $sp, $sp, 4	# decrement sp to make space for param
	lw $t2, -8($fp)	# load answer from $fp-8 into $t2
	sw $t2, 4($sp)	# copy param value to stack
	# _tmp735 = LCall _StringEqual
	# (save modified registers before flow of control change)
	sw $t0, -32($fp)	# spill _tmp733 from $t0 to $fp-32
	sw $t1, -44($fp)	# spill _tmp734 from $t1 to $fp-44
	jal _StringEqual   	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 8
	add $sp, $sp, 8	# pop params off stack
	# _tmp736 = _tmp735 || _tmp733
	lw $t1, -32($fp)	# load _tmp733 from $fp-32 into $t1
	or $t2, $t0, $t1	
	# Return _tmp736
	move $v0, $t2		# assign return value into $v0
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
main:
	# BeginFunc 76
	subu $sp, $sp, 8	# decrement sp to make space to save ra, fp
	sw $fp, 8($sp)	# save fp
	sw $ra, 4($sp)	# save ra
	addiu $fp, $sp, 8	# set up new fp
	subu $sp, $sp, 76	# decrement sp to make space for locals/temps
	# _tmp737 = 1
	li $t0, 1		# load constant value 1 into $t0
	# keepPlaying = _tmp737
	move $t1, $t0		# copy value
	# _tmp738 = 16
	li $t2, 16		# load constant value 16 into $t2
	# PushParam _tmp738
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t2, 4($sp)	# copy param value to stack
	# _tmp739 = LCall _Alloc
	# (save modified registers before flow of control change)
	sw $t0, -16($fp)	# spill _tmp737 from $t0 to $fp-16
	sw $t1, -8($fp)	# spill keepPlaying from $t1 to $fp-8
	sw $t2, -20($fp)	# spill _tmp738 from $t2 to $fp-20
	jal _Alloc         	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp740 = House
	la $t1, House	# load label
	# *(_tmp739) = _tmp740
	sw $t1, 0($t0) 	# store with offset
	# house = _tmp739
	move $t2, $t0		# copy value
	# _tmp741 = *(house)
	lw $t3, 0($t2) 	# load with offset
	# _tmp742 = *(_tmp741 + 12)
	lw $t4, 12($t3) 	# load with offset
	# PushParam house
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t2, 4($sp)	# copy param value to stack
	# ACall _tmp742
	# (save modified registers before flow of control change)
	sw $t0, -24($fp)	# spill _tmp739 from $t0 to $fp-24
	sw $t1, -28($fp)	# spill _tmp740 from $t1 to $fp-28
	sw $t2, -12($fp)	# spill house from $t2 to $fp-12
	sw $t3, -32($fp)	# spill _tmp741 from $t3 to $fp-32
	sw $t4, -36($fp)	# spill _tmp742 from $t4 to $fp-36
	jalr $t4            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp743 = *(house)
	lw $t0, -12($fp)	# load house from $fp-12 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp744 = *(_tmp743 + 16)
	lw $t2, 16($t1) 	# load with offset
	# PushParam house
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# ACall _tmp744
	# (save modified registers before flow of control change)
	sw $t1, -40($fp)	# spill _tmp743 from $t1 to $fp-40
	sw $t2, -44($fp)	# spill _tmp744 from $t2 to $fp-44
	jalr $t2            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
_L113:
	# IfZ keepPlaying Goto _L114
	lw $t0, -8($fp)	# load keepPlaying from $fp-8 into $t0
	beqz $t0, _L114	# branch if keepPlaying is zero 
	# _tmp745 = *(house)
	lw $t0, -12($fp)	# load house from $fp-12 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp746 = *(_tmp745)
	lw $t2, 0($t1) 	# load with offset
	# PushParam house
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# ACall _tmp746
	# (save modified registers before flow of control change)
	sw $t1, -48($fp)	# spill _tmp745 from $t1 to $fp-48
	sw $t2, -52($fp)	# spill _tmp746 from $t2 to $fp-52
	jalr $t2            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp747 = "\nDo you want to play another hand?"
	.data			# create string constant marked with label
	_string67: .asciiz "\nDo you want to play another hand?"
	.text
	la $t0, _string67	# load label
	# PushParam _tmp747
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# _tmp748 = LCall __GetYesOrNo
	# (save modified registers before flow of control change)
	sw $t0, -56($fp)	# spill _tmp747 from $t0 to $fp-56
	jal __GetYesOrNo   	# jump to function
	move $t0, $v0		# copy function return value from $v0
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# keepPlaying = _tmp748
	move $t1, $t0		# copy value
	# Goto _L113
	# (save modified registers before flow of control change)
	sw $t0, -60($fp)	# spill _tmp748 from $t0 to $fp-60
	sw $t1, -8($fp)	# spill keepPlaying from $t1 to $fp-8
	b _L113		# unconditional branch
_L114:
	# _tmp749 = *(house)
	lw $t0, -12($fp)	# load house from $fp-12 into $t0
	lw $t1, 0($t0) 	# load with offset
	# _tmp750 = *(_tmp749 + 4)
	lw $t2, 4($t1) 	# load with offset
	# PushParam house
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# ACall _tmp750
	# (save modified registers before flow of control change)
	sw $t1, -64($fp)	# spill _tmp749 from $t1 to $fp-64
	sw $t2, -68($fp)	# spill _tmp750 from $t2 to $fp-68
	jalr $t2            	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp751 = "Thank you for playing...come again soon.\n"
	.data			# create string constant marked with label
	_string68: .asciiz "Thank you for playing...come again soon.\n"
	.text
	la $t0, _string68	# load label
	# PushParam _tmp751
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -72($fp)	# spill _tmp751 from $t0 to $fp-72
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp752 = "\nCS143 BlackJack Copyright (c) 1999 by Peter Mor..."
	.data			# create string constant marked with label
	_string69: .asciiz "\nCS143 BlackJack Copyright (c) 1999 by Peter Mork.\n"
	.text
	la $t0, _string69	# load label
	# PushParam _tmp752
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -76($fp)	# spill _tmp752 from $t0 to $fp-76
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# _tmp753 = "(2001 mods by jdz)\n"
	.data			# create string constant marked with label
	_string70: .asciiz "(2001 mods by jdz)\n"
	.text
	la $t0, _string70	# load label
	# PushParam _tmp753
	subu $sp, $sp, 4	# decrement sp to make space for param
	sw $t0, 4($sp)	# copy param value to stack
	# LCall _PrintString
	# (save modified registers before flow of control change)
	sw $t0, -80($fp)	# spill _tmp753 from $t0 to $fp-80
	jal _PrintString   	# jump to function
	# PopParams 4
	add $sp, $sp, 4	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	move $sp, $fp		# pop callee frame off stack
	lw $ra, -4($fp)	# restore saved ra
	lw $fp, 0($fp)	# restore saved fp
	jr $ra		# return from function
