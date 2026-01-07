; Chapter 4 - Lesson 5
; File: Chapter4_Lesson5_Ex8.asm
; Topic: Power-of-two test using TEST (x != 0 and (x & (x-1)) == 0).
; Build:
;   nasm -felf64 Chapter4_Lesson5_Ex8.asm -o ex8.o
;   ld ex8.o -o ex8

%include "Chapter4_Lesson5_Ex1.asm"

global _start

section .data
x: dq 1024

msg_yes: db "x is a power of two.", 10, 0
msg_no:  db "x is NOT a power of two.", 10, 0

section .text
_start:
    mov rax, [rel x]

    test rax, rax
    jz .not_pow2            ; x == 0

    mov rbx, rax
    dec rbx
    test rax, rbx
    jz .is_pow2

.not_pow2:
    lea rsi, [rel msg_no]
    call print_cstr
    SYS_EXIT 0

.is_pow2:
    lea rsi, [rel msg_yes]
    call print_cstr
    SYS_EXIT 0
