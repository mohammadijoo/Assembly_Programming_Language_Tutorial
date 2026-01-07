; Chapter 4 - Lesson 5
; File: Chapter4_Lesson5_Ex5.asm
; Topic: Three-way unsigned compare using CMP + Jcc.
; Build:
;   nasm -felf64 Chapter4_Lesson5_Ex5.asm -o ex5.o
;   ld ex5.o -o ex5

%include "Chapter4_Lesson5_Ex1.asm"

global _start

section .data
A: dq 0x00000000000000FF
B: dq 0x0000000000000100

msg_lt: db "A < B (unsigned)", 10, 0
msg_eq: db "A == B", 10, 0
msg_gt: db "A > B (unsigned)", 10, 0
msg_A:  db "A = ", 0
msg_B:  db "B = ", 0

section .text
_start:
    lea rsi, [rel msg_A]
    call print_cstr
    mov rax, [rel A]
    call print_hex64

    lea rsi, [rel msg_B]
    call print_cstr
    mov rax, [rel B]
    call print_hex64

    mov rax, [rel A]
    mov rbx, [rel B]
    cmp rax, rbx
    je .eq
    jb .lt          ; unsigned: CF=1
    ja .gt          ; unsigned: CF=0 and ZF=0

.lt:
    lea rsi, [rel msg_lt]
    call print_cstr
    SYS_EXIT 0
.eq:
    lea rsi, [rel msg_eq]
    call print_cstr
    SYS_EXIT 0
.gt:
    lea rsi, [rel msg_gt]
    call print_cstr
    SYS_EXIT 0
