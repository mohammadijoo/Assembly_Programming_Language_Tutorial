global get_const_ptr
section .rodata
myconst: dq 0x1122334455667788

section .text
get_const_ptr:
    ; return &myconst in RAX (SysV)
    lea rax, [rel myconst]
    ret
