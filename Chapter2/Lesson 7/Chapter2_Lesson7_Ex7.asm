; Chapter 2 - Lesson 7 (Execution Flow) - Example 7
; Jump table ("switch") with an indirect branch.
; Build:
;   nasm -f elf64 Chapter2_Lesson7_Ex7.asm -o ex7.o
;   ld ex7.o -o ex7

BITS 64
DEFAULT REL

%include "Chapter2_Lesson7_Ex5.asm"

GLOBAL _start

SECTION .data
msg0 db "case 0", 10
len0 equ $-msg0
msg1 db "case 1", 10
len1 equ $-msg1
msg2 db "case 2", 10
len2 equ $-msg2
msg3 db "case 3", 10
len3 equ $-msg3
msgD db "default case", 10
lenD equ $-msgD

ALIGN 8
jump_table:
    dq case0, case1, case2, case3

SECTION .text
_start:
    ; Selector in RAX (simulate runtime input)
    mov eax, 2              ; change 0..3 for a matching case
    cmp eax, 3
    ja  default_case        ; out of range => default

    lea rdx, [jump_table]
    jmp qword [rdx + rax*8] ; indirect control transfer

case0:
    PRINT msg0, len0
    EXIT 0
case1:
    PRINT msg1, len1
    EXIT 0
case2:
    PRINT msg2, len2
    EXIT 0
case3:
    PRINT msg3, len3
    EXIT 0

default_case:
    PRINT msgD, lenD
    EXIT 0
