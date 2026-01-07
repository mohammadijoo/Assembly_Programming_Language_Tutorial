; Chapter2_Lesson9_Ex11.asm
; Build:
;   nasm -felf64 Chapter2_Lesson9_Ex11.asm -o ex11.o
;   ld -o ex11 ex11.o
;
; This program demonstrates MOV and LEA to set up syscall arguments,
; while using a tiny include file for constants/macros.

%include "Chapter2_Lesson9_Ex10.asm"

default rel
global _start

section .data
msg db "MOV / LEA / XCHG: basic sanity check", 10
len equ $ - msg

section .text
_start:
    lea rsi, [msg]         ; buffer address
    mov edx, len           ; length
    write_stdout rsi, rdx

    exit 0
