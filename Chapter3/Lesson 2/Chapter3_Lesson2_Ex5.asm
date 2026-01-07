; Chapter 3 - Lesson 2 (Example 5)
; Address-of, RIP-relative addressing, and pointer variables

BITS 64
default rel

section .rodata
msg         db "Pointer indirection works (p_msg -> msg).", 10
msg_len     equ $ - msg

section .data
p_msg       dq 0            ; variable that will hold an address (pointer)

section .text
global _start

_start:
    ; Obtain the address of msg in a position-friendly way:
    lea     rax, [rel msg]
    mov     qword [p_msg], rax

    ; Dereference pointer variable and use it as buffer address
    mov     rsi, qword [p_msg]

    mov     eax, 1          ; SYS_write
    mov     edi, 1          ; stdout
    mov     edx, msg_len
    syscall

    mov     eax, 60         ; SYS_exit
    xor     edi, edi
    syscall
