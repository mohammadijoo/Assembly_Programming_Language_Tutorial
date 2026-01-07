; Chapter 3 - Lesson 2 (Programming Exercise 2 — Solution)
; Reverse a string in place using pointer variables and indexed addressing.

BITS 64
default rel

%include "Chapter3_Lesson2_Ex8.asm"

section .rodata
before_lbl  db "Before: "
before_lbl_len equ $ - before_lbl

after_lbl   db "After : "
after_lbl_len equ $ - after_lbl

nl          db 10
nl_len      equ 1

section .data
; Null-terminated string, but we will use compile-time length for SYS_write.
s           db "Assembly variables: reverse me!", 0
s_len       equ $ - s - 1

; Pointer variables (addresses of bytes)
p_left      dq 0
p_right     dq 0

section .text
global _start

_start:
    ; Print before
    WRITE   before_lbl, before_lbl_len
    mov     eax, SYS_write
    mov     edi, STDOUT
    lea     rsi, [s]
    mov     edx, s_len
    syscall
    WRITE   nl, nl_len

    ; Initialize pointers
    lea     rax, [s]
    mov     qword [p_left], rax

    lea     rax, [s + s_len - 1]
    mov     qword [p_right], rax

.swap_loop:
    mov     rbx, qword [p_left]
    mov     rcx, qword [p_right]
    cmp     rbx, rcx
    jae     .done

    mov     al, byte [rbx]
    mov     dl, byte [rcx]
    mov     byte [rbx], dl
    mov     byte [rcx], al

    inc     rbx
    dec     rcx
    mov     qword [p_left], rbx
    mov     qword [p_right], rcx
    jmp     .swap_loop

.done:
    ; Print after
    WRITE   after_lbl, after_lbl_len
    mov     eax, SYS_write
    mov     edi, STDOUT
    lea     rsi, [s]
    mov     edx, s_len
    syscall
    WRITE   nl, nl_len

    EXIT    0
