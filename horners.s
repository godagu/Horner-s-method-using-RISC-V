.equ VARIABLE_SIZE, 4

# hello pookie bear
.data
    msgDegr: .asciz "Please enter the degree of the polynomial: "
    msgCoef: .asciz "Please enter the polynomial coefficients separated by space. (e.g. for polynomial 3x^3 + 6x^2 - 4x + 8 enter '3 6 -4 8': "
    msgX: .asciz "Please enter the x value: "
    array: .word 0
    x_value: .word 0
    size: .byte 0
    
    buffer: .word 0
    
.global main

.text

main:
    
    # input the degree of the polynomial
    la a0, msgDegr #load symbol address to a0
    li a7, 4 #system call for printing string
    ecall
    
    # read from input the degree of polynomial
    li a7, 63 # system call to read
    add a0, zero, zero # 0 for reading from stdin
    la a1, buffer # load to a1 the address of the buffer
    li a2, 2 # load to a2 the maximum bytes to read (enter included)
    ecall
    
    la t0, buffer # load address of buffer to t0
    lb t0, 0(t0) # load the value from buffer (t0) to t0
    
    addi t0, t0, -0x2F # subtract '0' + 1 to make decimal and add one
    
    la t1, size # load address of size to t1
    sb t0, 0(t1) # store byte of t0 (input) to t1
    
    la a0, msgCoef #load symbol address to a0
    li a7, 4 # system call for printing string
    ecall
    
    # input the coefficients
    li a7, 63 # system call to read 
    add a0, zero, zero # 0 foor reading from stdin
    la a1, buffer # load buffer of the address to a1
    li a2, 255 # load to a2 max bytes to read
    ecall
    
    
    la t3, buffer # load address of the buffer to t3
    add t6, zero, zero # reset value of t6 (will be used later,)
    
    # loop for parsing the buffer    
    loop_parse_buffer:
        lb t0, 0(t3) # load one byte from t3 to t0
        
        li t2, 0x20 # load 20 to t2 (ASCII space code)
        beq t0, t2, write_num_to_array # compare if the symbol in t0 is space, if yes jump to label for writing numbers to array
        
        addi t2, zero, 0x0A # load 0xA to t2 (ASCII enter code)
        beq t0, t2, write_num_to_array # see if the symbol in t0 is minus (if so, jump to further)
        
        li t2, 0x30 # load 0x30 to t2 (ASCII code for 0)
        blt t0, t2, exit_loop # if its below 0x30, jump to exit
        
        li t2, 0x39 # load 0x39 to t2 (ASCII code for 9)
        blt t2, t0, exit_loop # if its below 0x30, jump to exit
        
        addi t0, t0, -0x30 # subtract zero from t0 (to store a decimal value)
        
        li t2, 0xA # load 0xA to t2
        mul t6, t6, t2 # multiply t6 by t2 (10)
        add t6, t0, t6 # add t6 to t0 and store in t6
         
    continue_loop:
        addi t3, t3, 1 # add one to t3 (to point at the next symbol in the buffer)
        addi a0, a0, -1 # reduce the a1 by one (holds the number of bytes read)
        
        bne a0, zero, loop_parse_buffer # if read bytes sizev (a0) is bigger than 0, continue parsing
        
        
    write_num_to_array:
        addi sp, sp, -VARIABLE_SIZE # subtract the variable size from the stack pointer (to)
        
        # if minus flag is not 1 skip
        beq t5, zero, no_minususe # check t5 ("minus flag"), its its zero jump to no_minususe label
        
        # else multiply -1 by minus flag andd multiply by t6 
        addi t4, zero, -1 # add -1 to t4 register
        mul t6, t6, t4 # multiply the t6 ("minus flag") by t4
        
        no_minususe:
            sw t6, 0(sp) # store word in t6 to stack
            add t6, zero, zero #reset t6 to zero (for later use)
        
            addi t3, t3, 1 # add one to t3 (to point to the next symbol)
            addi a0, a0, -1 # reduce the read bytes size by one
        
            beq a0, zero, loop_completed # exit if all bytes in buffer read
        
            add t5, zero, zero # reset the flag
            lb t1, 0(t3) # load t3 byte to t1
        
            li t2, 0x2D # load t2 0x2d (ASCII minus value)
            bne t1, t2, minuse # compate t1 and t2 (to see if the next symbol is a minus)
        
            addi t5, t5, 1 # if minus was found add 1 to t5 ("minus flag")
            addi t3, t3, 1 # add 1 to t3 (to point to the next symbol in the buffer)
            addi a0, a0, -1 # reduce the ready bytes size
        
        minuse:
            bgtz a0, loop_parse_buffer # if a0 is greater than 0 (there are more bytes to read), continue parsing the buffer
        
    # label if all buffer was read
    loop_completed:
    la t3, array # load array address to t3
    sw sp, 0(t3) # store stack to t3
        
    # input the x value   
    la a0, msgX #load symbol address to a0
    li a7, 4 #system call for printing string
    ecall
    
    # read from input the degree of polynomial
    li a7, 63 # system call to read
    li a0, 0 # 0 for reading from stdin
    la a1, buffer # load to a1 the address of the buffer
    li a2, 2 # load to a2 the maximum bytes to read
    ecall
    
    la t0, buffer # load address of buffer to t0
    lb t0, 0(t0) # load the value from buffer (t0) to t0
    
    li t2, 0x30
    blt t0, t2, exit_loop
        
    li t2, 0x40
    blt t2, t0, exit_loop
    
        addi t0, t0, -0x30 # subtract '0' to make decimal
    
    la t1, x_value # load address of size to t1
    sw t0, 0(t1) # store byte of t0 (input) to t1
    
    
    la a0, array # load array address to a0 register
    lw a0, 0(a0)
    
    la t1, size # temporary store size value 0x30address in t1 register
    lb a1, 0(t1) # load word (size value stored in t1) to a1 register
    
    la t1, x_value # temporary store x_value address in t1 register
    lb a2, 0(t1) # load x_value to a2 register
    
    jal ra, print # save the return address to ran and jump to label print
    
    # good practice to clean up the stack
    
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
    
 exit_loop:
   # exit
    li a7, 10
    ecall 
        # do sth not a number
