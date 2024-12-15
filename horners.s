.equ VARIABLE_SIZE, 4                       # declare a constant variable size as integer

.data                                       # start of the data section where static variables and strings are declared.

    msgDegr: .asciz "Please enter the degree of the polynomial (no extra symbols): "
                                            # declare a null-terminated string (message) to prompt the user to enter the degree of the polynomial
    msgCoef: .asciz "Please enter the polynomial coefficients separated by space in ascending degree order (e.g. for polynomial 3x^3 + 6x^2 - 4x + 8 enter '8 -4 6 3'. Input must end in a number.): "
                                            # declare a null-terminated string (message) to prompt the user to input polynomial coefficients
    msgX: .asciz "Please enter the x value (no extra symbols): "
                                            # declare a null-terminated string (message) to prompt the user to input the value of x
    array: .word 0                          # declare a word (4 bytes) to store the polynomial coefficient
    x_value: .word 0                        # declare a word to store the x value
    size: .byte 0                           # declare a byte to store the degree of the polynomial
    buffer: .word 0                         # declare a word to temporarily store data during processing

.global main                                # define the entry point of the program ('main' is visible and accessible globally)

.text                                       # start of the text section where eexecutable code is written

main:
    # input the degree of the polynomial
    la a0, msgDegr                          # load symbol address to a0
    li a7, 4                                # system call for printing string
    ecall
    
    # read from input the degree of polynomial (max two digit number!)
    li a7, 63                               # system call to read
    add a0, zero, zero                      # 0 for reading from stdin
    la a1, buffer                           # load to a1 the address of the buffer
    li a2, 3                                # load to a2 the maximum bytes to read (enter included)
    ecall
    
    la t3, buffer                           # load address of buffer to t0
    add t6, zero, zero                      # reset the value of t6
    
    degree_parse_loop:
        lb t0, 0(t3)                        # load the value from buffer (t0) to t0
                
        addi t2, zero, 0x0A                 # load 0xA to t2 (ASCII enter code)
        beq t0, t2, write_num_to_degree     # see if the symbol in t0 is enter (if so, jump to further)
        
        li t2, 0x30                         # load 0x30 to t2 (ASCII code for 0)
        blt t0, t2, exit_loop               # if its below 0x30, jump to exit
        
        li t2, 0x39                         # load 0x39 to t2 (ASCII code for 9)
        blt t2, t0, exit_loop               # if its below 0x30, jump to exit
     
        addi t0, t0, -0x30                  # subtract 0x30 to store decimal value
        
        li t2, 0xA                          # load 0xA (10) to t2
        mul t6, t6, t2                      # multiply t6 by t2 (10)
        add t6, t0, t6                      # add t6 to t0 and store in t6
        
    continute_loop_deg:
        addi t3, t3, 1                      # point to the next symbol in the buffer
        addi a0, a0, 1                      # reduce the bytes read
        
        bne a0, zero, degree_parse_loop     # check if all bytes where read (compare a0 to zero)
        
    write_num_to_degree:
        addi t6, t6, 1                      # add 1 to t6 to (because for numb. 2 polynomial there should be 3 coefficients)
        la t1, size                         # load the address of "size" to t1
        sb t6, 0(t1)                        # store the value of t6 (the degree) in t1 ("size")
        
    
    # input the coefficients
    la a0, msgCoef                          # load symbol address to a0
    li a7, 4                                # system call for printing string
    ecall
    
    li a7, 63                               # system call to read
    add a0, zero, zero                      # 0 foor reading from stdin
    la a1, buffer                           # load buffer of the address to a1
    li a2, 255                              # load to a2 max bytes to read
    ecall
    
    
    la t3, buffer                           # load address of the buffer to t3
    add t6, zero, zero                      # reset value of t6 (will be used later,)
    
    add t5, zero, zero                      # reset t5 just in case
    
    lb t0, 0(t3)
    li t2, 0x2D                             # load 0x2D to t2 (ASCII minus code)
    
    bne t0, t2, loop_parse_buffer           # branch if the sybol was 0
    
    addi t5, t5, 1                          # if the symbol was a minus, set the t5 to 1 (used as a minus flag)
    addi t3, t3, 1                          # access the next element of the bufffer
    addi a0, a0, -1                         # reduce the size of the buffer
    
    # loop for parsing the buffer    
    loop_parse_buffer:
        lb t0, 0(t3)                        # load one byte from t3 to t0
        
        li t2, 0x20                         # load 20 to t2 (ASCII space code)
        beq t0, t2, write_num_to_array      # compare if the symbol in t0 is space, if yes jump to label for writing numbers to array
        
        addi t2, zero, 0x0A                 # load 0xA to t2 (ASCII enter code)
        beq t0, t2, write_num_to_array      # see if the symbol in t0 is enter (if so, jump to further)
        
        li t2, 0x30                         # load 0x30 to t2 (ASCII code for 0)
        blt t0, t2, exit_loop               # if its below 0x30, jump to exit
        
        li t2, 0x39                         # load 0x39 to t2 (ASCII code for 9)
        blt t2, t0, exit_loop               # if its below 0x30, jump to exit
        
        addi t0, t0, -0x30                  # subtract zero from t0 (to store a decimal value)
        
        li t2, 0xA                          # load 0xA to t2
        mul t6, t6, t2                      # multiply t6 by t2 (10)
        add t6, t0, t6                      # add t6 to t0 and store in t6
         
    continue_loop:
        addi t3, t3, 1                      # add one to t3 (to point at the next symbol in the buffer)
        addi a0, a0, -1                     # reduce the a1 by one (holds the number of bytes read)
        
        bne a0, zero, loop_parse_buffer     # if read bytes sizev (a0) is bigger than 0, continue parsing
        
    write_num_to_array:
        addi sp, sp, -VARIABLE_SIZE         # subtract the variable size from the stack pointer (to)
        
        # if minus flag is not 1 skip
        beq t5, zero, no_minususe           # check t5 ("minus flag"), its its zero jump to no_minususe label
        
        # else multiply -1 by minus flag andd multiply by t6 
        addi t4, zero, -1                   # add -1 to t4 register
        mul t6, t6, t4                      # multiply the t6 ("minus flag") by t4
        
        no_minususe:
            sw t6, 0(sp)                    # store word in t6 to stack
            add t6, zero, zero              # reset t6 to zero (for later use)
        
            addi t3, t3, 1                  # add one to t3 (to point to the next symbol)
            addi a0, a0, -1                 # reduce the read bytes size by one
        
            blez a0, loop_completed         # exit if all bytes in buffer read
        
            add t5, zero, zero              # reset the flag
            lb t1, 0(t3)                    # load t3 byte to t1
        
            li t2, 0x2D                     # load t2 0x2d (ASCII minus value)
            bne t1, t2, minuse              # compate t1 and t2 (to see if the next symbol is a minus)
        
            addi t5, t5, 1                  # if minus was found add 1 to t5 ("minus flag")
            addi t3, t3, 1                  # add 1 to t3 (to point to the next symbol in the buffer)
            addi a0, a0, -1                 # reduce the ready bytes size
        
        minuse:
            bgtz a0, loop_parse_buffer      # if a0 is greater than 0 (there are more bytes to read), continue parsing the buffer
        
    # label if all buffer was read
    loop_completed:
    la t3, array                            # load array address to t3
    sw sp, 0(t3)                            # store stack to t3
        
    # input the x value   
    la a0, msgX                             # load symbol address to a0
    li a7, 4                                # system call for printing string
    ecall
    
    # read from input the x value (positive or negative three digit number)
    li a7, 63                               # system call to read
    li a0, 0                                # 0 for reading from stdin
    la a1, buffer                           # load to a1 the address of the buffer
    li a2, 5                                # load to a2 the maximum bytes to read
    ecall
    
    add t6, zero, zero                      # reset the t6 (used later)
    
    la t3, buffer                           # load address of buffer to t0
    
    lb t0, 0(t3)                            # load byte from t3 to t1
    li t2, 0x2D                             # load 0x2D to t2 (ASCII minus code)
    
    bne t0, t2, x_value_parse_buffer
    
    # if equal to minus, then handle minus sign
    addi t5, t5, 1                          # use t5 as a minus flag
    
    addi t3, t3, 1                          # point to the next bit of buffer
    addi a0, a0, -1                         # reduce bytes read size
    
    beq a0, zero, exit_loop
    x_value_parse_buffer:
        lb t0, 0(t3)                        # load the value from buffer (t3) to t0
        
        addi t2, zero, 0x0A                 # load 0xA to t2 (ASCII enter code)
        beq t0, t2, write_num_to_x_value    # see if the symbol in t0 is enter (if so, jump to further)
        
        li t2, 0x30                         # load 0x30 to t2 (ASCII code for 0)
        blt t0, t2, exit_loop               # if its below 0x30, jump to exit
        
        li t2, 0x39                         # load 0x39 to t2 (ASCII code for 9)
        blt t2, t0, exit_loop               # if its below 0x30, jump to exit
        
        addi t0, t0, -0x30                  # subtract zero from t0 (to store a decimal value)
        
        li t2, 0xA                          # load 0xA to t2
        mul t6, t6, t2                      # multiply t6 by t2 (10)
        add t6, t0, t6                      # add t6 to t0 and store in t6
    
    x_value_continue_loop:
        addi t3, t3, 1                      # point to next symbol in the buffer
        addi a0, a0, -1                     # reduce the bytes read size
        bne a0, zero, x_value_parse_buffer  # compare if bytes read is not 0
        
    write_num_to_x_value:
        beq t5, zero, no_minus              # check if the minus flag (t5) is set
        
        add t1, zero, zero                  # make t1 contain value -1
        addi t1, t1, -1
        mul t6, t6, t1                      # multiply t6 reg (with result) by -1 (in t1)
        
        no_minus:
            la t1, x_value                  # load the address of x_value to t1
            sw t6, 0(t1)                    # store the result (t6) in address t1 (x_value)
        
    la a0, array                            # load array address to a0 register
    lw a0, 0(a0)
    
    la t1, size                             # temporary store size value 0x30address in t1 register
    lb a1, 0(t1)                            # load word (size value stored in t1) to a1 register
    
    la t1, x_value                          # temporary store x_value address in t1 register
    lb a2, 0(t1)                            # load x_value to a2 register
    
    jal ra, horners                         # save the return address to ran and jump to label print
        
    # exit
    li a7, 10                               # system call to end a program
    ecall 
    
horners:
    add a3, a0, x0                          # save a0 contents to a3 (in this case the address of the array)
    lw t0, 0(a3)                            # set the result to the first coefficient
    
    addi a3, a3, VARIABLE_SIZE              # access the second element of the array
    addi a1, a1, -1                         # decrement the size
    
    beq a1, x0, end                         # check if the there is still symbols to read (if not, jump to end)
    loop:
        lw a4, 0(a3)                        # store the next element of the array in a4
        
        mul t0, t0, a2                      # multiply the current result by x_value (result = result * x)
        add t0, t0, a4                      # add the next array value to the result (result = result + array[i])
         
        addi a3, a3, VARIABLE_SIZE          # move to the next element of the array
        
        addi a1, a1, -1                     # decrement the size
        bne a1, x0, loop                    # check if size is not zero
   
    end: 
        add a0, t0, x0                      # add the value of result in t0 to a0 for printing
        li a7, 1                            # print an int (sys call provided by ripes)
        ecall 
        ret
    
 exit_loop:
    li a7, 10                               # system call to exit
    ecall 
