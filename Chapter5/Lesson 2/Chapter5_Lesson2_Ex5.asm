; Chapter5_Lesson2_Ex5.asm
; Topic demo: The LOOP instruction (legacy counted loop)
;
; Compute factorial(10) using LOOP (which decrements RCX and jumps if RCX != 0).
;
; Notes:
; - LOOP is compact, but often slower than DEC/JNZ on modern x86-64 cores.
; - LOOP implicitly uses RCX/ECX: do not use RCX for anything else in the loop body.
;
; Build:
;   nasm -felf64 Chapter5_Lesson2_Ex5.asm -o Chapter5_Lesson2_Ex5.o
;   ld -o Chapter5_Lesson2_Ex5 Chapter5_Lesson2_Ex5.o
;
; Exit status = (10! mod 256)

BITS 64
default rel

section .text
global _start

_start:
    mov rcx, 10          ; loop count
    mov rax, 1           ; result

.fact:
    imul rax, rcx        ; result *= rcx
    loop .fact           ; rcx-- ; if rcx != 0 jump

    and eax, 255
    mov edi, eax
    mov eax, 60          ; SYS_exit
    syscall
