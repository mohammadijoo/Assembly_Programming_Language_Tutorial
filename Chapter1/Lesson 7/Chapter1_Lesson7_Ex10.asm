; exitcode.asm
; Build:
;   nasm -f elf64 exitcode.asm -o exitcode.o
;   ld -o exitcode exitcode.o
; Run:
;   ./exitcode
;   echo $?

BITS 64
section .text
global _start

_start:
    mov eax, 60     ; SYS_exit
    mov edi, 137    ; status
    syscall
