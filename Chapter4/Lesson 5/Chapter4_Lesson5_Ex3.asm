; Chapter 4 - Lesson 5
; File: Chapter4_Lesson5_Ex3.asm
; Topic: Immediate size and sign-extension surprises with CMP (imm8 sign-extends).
; Build:
;   nasm -felf64 Chapter4_Lesson5_Ex3.asm -o ex3.o
;   ld ex3.o -o ex3

%include "Chapter4_Lesson5_Ex1.asm"

global _start

section .data
msg1: db "cmp ax, byte 0x80: NOT equal because imm8 sign-extends to 0xFF80", 10, 0
msg2: db "cmp ax, word 0x0080: equal (explicit operand size avoids sign-extension)", 10, 0

section .text
_start:
    mov ax, 0x0080         ; +128

    ; Here imm8 = 0x80 is treated as -128 when sign-extended to 16-bit (0xFF80).
    cmp ax, byte 0x80
    je .bad_equal
    lea rsi, [rel msg1]
    call print_cstr

    ; Explicitly compare to 0x0080 (word immediate)
    cmp ax, word 0x0080
    jne .bad_not_equal
    lea rsi, [rel msg2]
    call print_cstr
    SYS_EXIT 0

.bad_equal:
    lea rsi, [rel msg1]
    call print_cstr
    SYS_EXIT 2

.bad_not_equal:
    lea rsi, [rel msg2]
    call print_cstr
    SYS_EXIT 3
