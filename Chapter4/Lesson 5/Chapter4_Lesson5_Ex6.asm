; Chapter 4 - Lesson 5
; File: Chapter4_Lesson5_Ex6.asm
; Topic: Range check with CMP (unsigned interval [low, high]).
; Build:
;   nasm -felf64 Chapter4_Lesson5_Ex6.asm -o ex6.o
;   ld ex6.o -o ex6

%include "Chapter4_Lesson5_Ex1.asm"

global _start

section .data
value: dd 37
low:   dd 10
high:  dd 50

msg_in:  db "Value is inside the interval [low, high] (unsigned check).", 10, 0
msg_out: db "Value is OUTSIDE the interval [low, high] (unsigned check).", 10, 0

section .text
_start:
    mov eax, [rel value]
    cmp eax, [rel low]
    jb .out          ; value < low (unsigned)
    cmp eax, [rel high]
    ja .out          ; value > high (unsigned)

.in:
    lea rsi, [rel msg_in]
    call print_cstr
    SYS_EXIT 0

.out:
    lea rsi, [rel msg_out]
    call print_cstr
    SYS_EXIT 1
