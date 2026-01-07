; Linux x86-64: write(1, msg, len), then exit(0)
; rax = syscall number
; rdi, rsi, rdx, r10, r8, r9 = args 1..6

global _start

section .data
msg:    db  "Low-level means state transitions.", 10
len:    equ $ - msg

section .text
_start:
    ; ssize_t write(int fd, const void* buf, size_t count)
    mov     rax, 1          ; SYS_write
    mov     rdi, 1          ; fd = stdout
    lea     rsi, [rel msg]  ; buf = &msg
    mov     rdx, len        ; count = len
    syscall

    ; void exit(int status)
    mov     rax, 60         ; SYS_exit
    xor     rdi, rdi        ; status = 0
    syscall
