; Chapter 4 - Lesson 5
; File: Chapter4_Lesson5_Ex2.asm
; Topic: CMP sets flags; conditional jump consumes flags.
; Build:
;   nasm -felf64 Chapter4_Lesson5_Ex2.asm -o ex2.o
;   ld ex2.o -o ex2
; Run:
;   ./ex2

%include "Chapter4_Lesson5_Ex1.asm"

global _start

section .data
msg_eq: db "CMP demo: values are equal", 10, 0
msg_ne: db "CMP demo: values are NOT equal", 10, 0

section .text
_start:
    mov eax, 123456
    mov ebx, 123456

    cmp eax, ebx          ; like (eax - ebx) but result is not stored
    jne .not_equal

.equal:
    lea rsi, [rel msg_eq]
    call print_cstr
    SYS_EXIT 0

.not_equal:
    lea rsi, [rel msg_ne]
    call print_cstr
    SYS_EXIT 1
