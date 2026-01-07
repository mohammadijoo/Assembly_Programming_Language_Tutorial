; src/hello_syscall.asm
; Writes a message to stdout using Linux sys_write, then exits.

global _start

section .data
msg:    db "Environment OK: NASM + ld + Linux syscalls", 10
msg_len equ $ - msg

section .text
_start:
    ; ssize_t write(int fd, const void *buf, size_t count)
    mov     rax, 1              ; syscall: write
    mov     rdi, 1              ; fd = 1 (stdout)
    lea     rsi, [rel msg]      ; buf = &msg
    mov     rdx, msg_len        ; count
    syscall

    mov     rax, 60             ; syscall: exit
    xor     rdi, rdi
    syscall
