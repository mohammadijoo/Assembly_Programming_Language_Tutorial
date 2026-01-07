; sys_exit.asm
default rel
global sys_exit

section .text
sys_exit:
    mov eax, 60
    syscall
    hlt
