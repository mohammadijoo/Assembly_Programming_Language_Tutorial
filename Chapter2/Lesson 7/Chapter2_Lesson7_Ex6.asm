; Chapter 2 - Lesson 7 (Execution Flow) - Example 6
; Uses an include file to reduce boilerplate and emphasize flow.
; Build:
;   nasm -f elf64 Chapter2_Lesson7_Ex6.asm -o ex6.o
;   ld ex6.o -o ex6

BITS 64
DEFAULT REL

%include "Chapter2_Lesson7_Ex5.asm"

GLOBAL _start

SECTION .data
msg_in    db "Entering decision region", 10
len_in    equ $-msg_in

msg_hot   db "Hot path executed", 10
len_hot   equ $-msg_hot

msg_cold  db "Cold path executed", 10
len_cold  equ $-msg_cold

SECTION .text
_start:
    PRINT msg_in, len_in

    ; Example predicate: (x & 1) == 0 ?
    mov eax, 13
    test eax, 1
    jz  .even

.odd:
    PRINT msg_cold, len_cold
    EXIT 0

.even:
    PRINT msg_hot, len_hot
    EXIT 0
