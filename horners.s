.equ VARIABLE_SIZE, 4

# hello pookie bear
.data
    msgDegr: .asciz "Please enter the degree of the polynomial:"
    msgCoef: .asciz "Please enter the polynomial coefficients separated by space. (e.g. for polynomial 3x^3 + 6x^2 - 4x + 8 enter '3 6 -4 8'"
    msgX: .asciz "Please enter the x value:"
    array: .word 0
    x_value: .word 0
    size: .byte 0
    
    buffer: .asciz "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    
    # i need to define the pointer to array? or the whole array?
    # size?
    # place for x value
    
.global main

.text

main:
    la a0, msgDegr #load symbol address to a0
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
    
    addi t0, t0, -0x2F # subtract '0' to make decimal
    
    la t1, size # load address of size to t1
    sb t0, 0(t1) # store byte of t0 (input) to t1
    
    la a0, msgCoef #load symbol address to a0
    li a7, 4 #system call for printing string
    ecall
    
    li a7, 63
    add a0, zero, zero
    la a1, buffer
    li a2, 255
    ecall
    
    # eini per bufferi
    la t3, buffer
    
    add t6, zero, zero
    loop_parse_buffer:
        lb t0, 0(t3) 
        li t2, 0x20
    
        beq t0, t2, write_num_to_array
        
        addi t2, zero, 0x0A
        beq t0, t2, write_num_to_array
        
        li t2, 0x30
        blt t0, t2, exit_loop
        
        li t2, 0x39
        blt t2, t0, exit_loop
        
        addi t0, t0, -0x30
        
        li t2, 0xA
        mul t6, t6, t2
        add t6, t0, t6     
         
    continue_loop:
        addi t3, t3, 1
        addi a0, a0, -1 
        
        bne a0, zero, loop_parse_buffer
        
        
    write_num_to_array:
        addi sp, sp, -VARIABLE_SIZE
        
        sw t6, 0(sp)
        add t6, zero, zero
        
        addi t3, t3, 1
        addi a0, a0, -1 
        
        bgtz a0, loop_parse_buffer
        
    # loop completed
    loop_completed:
    la t3, array
    sw sp, 0(t3)
        
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
