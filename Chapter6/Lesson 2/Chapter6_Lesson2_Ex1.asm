; Chapter 6 - Lesson 2 - Example 1
; File: Chapter6_Lesson2_Ex1.asm
; Topic: Minimal procedure declaration (NASM, x86-64, SysV-friendly)
;
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson2_Ex1.asm -o ex1.o
;   # Link into a C program or an ASM program that calls asm_return_42.
;
; Exported symbol:
;   long asm_return_42(void);

default rel
section .text
global asm_return_42

asm_return_42:
    ; Return value in RAX (SysV)
    mov eax, 42
    ret
