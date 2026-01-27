; Chapter5_Lesson9_Ex1.asm
; Structured IF/ELSE pattern (readable labels, single fall-through policy)
; NASM x86-64, Linux (SysV). Build:
;   nasm -felf64 Chapter5_Lesson9_Ex1.asm -o ex1.o
;   ld ex1.o -o ex1
; Run:
;   ./ex1 ; echo $?

BITS 64
DEFAULT REL

SECTION .text
global _start

_start:
    ; Example: compute max(a,b) with a structured "diamond" but arranged for fall-through.
    mov     edi, 7          ; a
    mov     esi, 3          ; b

    ; Convention: put the "likely" path as fall-through when you know it.
    ; Here we do not assume likelihood; we choose a consistent layout:
    ; if (a >= b) r = a else r = b
    mov     eax, edi        ; r = a
    cmp     edi, esi
    jge     .L_if_end       ; if true, keep r=a and skip else
    mov     eax, esi        ; else: r = b
.L_if_end:

    ; Exit status = r (low 8 bits)
    mov     edi, eax
    mov     eax, 60         ; sys_exit
    syscall
