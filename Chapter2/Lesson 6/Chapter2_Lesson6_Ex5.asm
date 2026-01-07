\
; Chapter2_Lesson6_Ex5.asm
; NASM: macro expansion + repeat blocks to generate boilerplate.
; This program prints three messages by generating "write+newline" sequences.
;
; Build (Linux):
;   nasm -f elf64 -g -F dwarf Chapter2_Lesson6_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o
;   ./ex5

BITS 64
default rel

%define SYS_write 1
%define SYS_exit  60
%define STDOUT    1

%macro WRITE_MSG 2
    ; write(STDOUT, %1, %2)
    mov eax, SYS_write
    mov edi, STDOUT
    lea rsi, [%1]
    mov edx, %2
    syscall
%endmacro

section .rodata
m1: db "Macro-generated write #1", 10
l1: equ $ - m1
m2: db "Macro-generated write #2", 10
l2: equ $ - m2
m3: db "Macro-generated write #3", 10
l3: equ $ - m3

section .text
global _start
_start:
    WRITE_MSG m1, l1
    WRITE_MSG m2, l2
    WRITE_MSG m3, l3

    mov eax, SYS_exit
    xor edi, edi
    syscall
