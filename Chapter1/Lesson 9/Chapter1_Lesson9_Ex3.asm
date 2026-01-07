; file: sys_write_exit.asm
; Linux x86-64 syscalls:
;   write(fd=1, buf, len)  => rax=1, rdi=fd, rsi=buf, rdx=len
;   exit(code)             => rax=60, rdi=code

default rel
global sys_write
global sys_exit

section .text

sys_write:
    ; rdi=fd, rsi=buf, rdx=len
    mov eax, 1
    syscall
    ret

sys_exit:
    ; rdi=exit_code
    mov eax, 60
    syscall
    ; no return
    hlt
