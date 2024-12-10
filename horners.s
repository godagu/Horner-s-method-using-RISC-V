.equ VARIABLE_SIZE, 4

# hello pookie bear
.data
    msg: .asciz "Hello World!"
    array: .word 2, 3, 4
    x_value: .word 5
    size: .byte 3
    
    # i need to define the pointer to array? or the whole array?
    # size?
    # place for x value
    
.global main

.text

main:
    la a0, array # load array address to a0 register
    
    la t1, size # temporary store size value address in t1 register
    lw a1, 0(t1) # load word (size value stored in t1) to a1 register
    
    la t1, x_value # temporary store x_value address in t1 register
    lw a2, 0(t1) # load x_value to a2 register
    
    jal ra, print # save the return address to ran and jump to label print
    
    # exit
    li a7, 10
    ecall 
    
print:
    add a3, a0, x0 # save a0 contents to a3 (in this case the address of the array)
    lw t0, 0(a3) # set the result to the first coefficient
    
    addi a3, a3, VARIABLE_SIZE # access the second element of the array
    addi a1, a1, -1 # decrement the size


    loop:
        lw a4, 0(a3) # store the next element of the array in a4
        
        mul t0, t0, a2 # multiply the current result by x_value (result = result * x)
        add t0, t0, a4 # add the next array value to the result (result = result + array[i])
         
        addi a3, a3, VARIABLE_SIZE # move to the next element of the array
        
        addi a1, a1, -1 # decrement the size
        bne a1, x0, loop # check if size is not zero
        
    add a0, t0, x0  # add the value of result in t0 to a0 for printing
    li a7, 1 # print an int (sys call provided by ripes)
    ecall 
    ret
