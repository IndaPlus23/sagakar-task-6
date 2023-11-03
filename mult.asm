jal factorial
nop
j end
nop
# int multiply(int a, int b)
# a -> $a0, b -> $a1
multiply:
	li $v0 0 # sum = 0
	li $t0 0 # i = 0
	blez $a0 skip_mult_loop # don't execute loop if a < starting value of i
	nop
	mult_loop:
		add $v0 $v0 $a1
		addi $t0 $t0 1
		sub $t1 $a0 $t0 # Store a - i in a temporary varaible
		bgtz $t1 mult_loop # if a - i > 0, do another iteration
		nop
	skip_mult_loop:
	jr $ra
	nop

factorial:
	li $v0 1 # fac = 1
	move $t0 $a0 # i = n
	subi $t1 $t0 1 # store i - 1 in temp variable
	blez $t1 skip_fac_loop # don't execute loop if starting value of i < 1
	nop
	move $t9 $ra # temporarily move return address to prevent overwriting
	fac_loop:
		# According to the original code:
		# move $a0 $v0
		# move $a1 $t0
		# This causes an ever rising number of loop iterations, and was too painful not to fix
		move $a0 $t0
		move $a1 $v0
		move $t8 $t0 # temporarily move contents of t0 to prevent being overwritten
		jal multiply # multiply (fac, i)
		nop
		move $t0 $t8 # restore t0
		subi $t0 $t0 1 # i--
		subi $t1 $t0 1 # store i - 1 in temporary variable
		bgtz $t1 fac_loop # if i - 1 > 0, do another iteration
		nop
	move $ra $t9 # restore return address
	skip_fac_loop:
	jr $ra
	nop

end:
	move $a0 $v0 # return value to a0
	li $v0 1 # set syscall to print_int
	syscall
	li $v0 10 # set syscall to exit
	syscall
	
	