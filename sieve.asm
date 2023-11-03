##################################################################
#
#   Template for subassignment "Inbyggda System-mastern, här kommer jag!"
#
#   Author: Viola Söderlund <violaso@kth.se>
#
#   Created: 2020-10-25
#
#   See: MARS Syscall Sheet (https://courses.missouristate.edu/KenVollmar/mars/Help/SyscallHelp.html)
#   See: MIPS Documentation (https://ecs-network.serv.pacific.edu/ecpe-170/tutorials/mips-instruction-set)
#   See: Sieve of Eratosthenes (https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes)
#
##################################################################

### Data Declaration Section ###

.data

primes:		.space  1000            # reserves a block of 1000 bytes in application memory
err_msg:	.asciiz "Invalid input! Expected integer n, where 1 < n < 1001.\n"
newline:	.asciiz "\n"

### Executable Code Section ###

.text

main:
    # get input
    li      $v0,5                   # set system call code to "read integer"
    syscall                         # read integer from standard input stream to $v0

    # validate input
    li 	    $t0,1001                # $t0 = 1001
    slt	    $t1,$v0,$t0		        # $t1 = input < 1001
    beq     $t1,$zero,invalid_input # if !(input < 1001), jump to invalid_input
    nop
    li	    $t0,1                   # $t0 = 1
    slt     $t1,$t0,$v0		        # $t1 = 1 < input
    beq     $t1,$zero,invalid_input # if !(1 < input), jump to invalid_input
    nop
    
    # initialise primes array
    la	    $t0,primes              # $s1 = address of the first element in the array
    li 	    $t1,999
    li 	    $t2,0
    li	    $t3,1
    
    # set every element to 1
init_loop:
    sb	    $t3, ($t0)              # primes[i] = 1
    addi    $t0, $t0, 1             # increment pointer
    addi    $t2, $t2, 1             # increment counter
    bne	    $t2, $t1, init_loop     # loop if counter != 999
    nop
    
    ### Continue implementation of Sieve of Eratosthenes ###
    # Initialize sieving
    la $t0, primes # reset pointer
    li $t3, 0 # we will use $t3 to set non-primes to 0
    sb $t3, ($t0) # primes[0] = 0 (since 1 is not prime)
    addi $t0, $t0, 1 # start from 2
    li $t2, 2 # step = 2
    li $t4, 0 # set offset to 0


    # cross off all numbers that are a multiple of step
sieve_loop:
    add $t4, $t4, $t2 # offset += step
    add $t0, $t0, $t4 # pointer += offset
    sb $t3, ($t0) # primes[i + offset] = 0
    blt $t4, $v0, sieve_loop # if offset < n, loop
    nop
    li $t4, 0 # reset offset to 0 for next prime
    # reset pointer to primes + counter - 1
    la $t0, primes
    add $t0, $t0, $t2
    subi $t0, $t0, 1
    j next_prime_loop # else find next prime
    nop
    
    # increment step and pointer until a new prime is found
next_prime_loop:
    addi $t0, $t0, 1 # pointer++
    addi $t2, $t2, 1 # step++
    bgt $t2, $v0, print_init # exit loop and print primes if step > n (i.e. all primes n and under have been found)
    nop
    lb $t6, ($t0) # get the value at primes[i] (1 if prime, 0 if not)
    beq $t6, 0, next_prime_loop # if primes[i] is not prime, increment and try again
    nop
    j sieve_loop # else, cross out all multiples of step
    

    ### Print nicely to output stream ###
print_init:
    li $t5, 0
    add $t5, $t5, $v0 # move n to $t5 to clear up $v0 for syscalls
    li $v0, 1 # set syscall to print integer
    la $t0, primes # reset pointer
    li $a0, 1 # set counter to 1
print_loop:
    addi $t0, $t0, 1 # pointer++
    addi $a0, $a0, 1 # counter++
    lb $t6, ($t0) # read value of primes[i]
    beq $t6, 0, skip_print # if not prime, do not print
    nop
    syscall # print the value of counter
skip_print:
    blt $a0, $t5, print_loop # do another iteration if counter < n
    nop
    
    # exit program
    j       exit_program
    nop

invalid_input:
    # print error message
    li      $v0, 4                  # set system call code "print string"
    la      $a0, err_msg            # load address of string err_msg into the system call argument registry
    syscall                         # print the message to standard output stream

exit_program:
    # exit program
    li $v0, 10                      # set system call code to "terminate program"
    syscall                         # exit program