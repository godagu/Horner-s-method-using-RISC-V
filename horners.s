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
    
    # print the string
    la a0, msg
    li a7, 4
    ecall
    
    # exit
    li a7, 10
    ecall 