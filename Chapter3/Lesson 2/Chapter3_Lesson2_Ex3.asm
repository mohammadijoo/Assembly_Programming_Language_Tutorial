; Chapter 3 - Lesson 2 (Example 3)
; Uninitialized variables in .bss and runtime initialization with REP STOSB

BITS 64
default rel

section .bss
buf         resb 33         ; 32 bytes payload + newline at the end

section .text
global _start

_start:
    cld                     ; ensure DF=0 for forward REP string ops

    ; Fill buf[0..31] with '*'
    lea     rdi, [buf]
    mov     ecx, 32
    mov     al, '*'
    rep stosb

    ; buf[32] = '\n'
    mov     byte [buf + 32], 10

    ; write 33 bytes
    mov     eax, 1          ; SYS_write
    mov     edi, 1          ; stdout
    lea     rsi, [buf]
    mov     edx, 33
    syscall

    mov     eax, 60         ; SYS_exit
    xor     edi, edi
    syscall
