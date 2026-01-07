\
; Chapter2_Lesson6_Ex11.asm
; Programming Exercise 1 (Starter): dual-mode build via conditional assembly.
; Goal: implement two output paths selected at assemble-time:
;   - If USE_LIBC is defined: call puts() and return from main.
;   - Otherwise: use Linux syscalls from _start (no libc) and exit().
;
; Assemble-time selection examples:
;   nasm -f elf64 -D USE_LIBC=1 Chapter2_Lesson6_Ex11.asm -o ex11.o
;   nasm -f elf64               Chapter2_Lesson6_Ex11.asm -o ex11.o
;
; NOTE: This starter assembles but does not satisfy the goal yet.

BITS 64
default rel

section .rodata
msg: db "TODO: implement dual-mode output path.", 10, 0
msg_len equ ($ - msg) - 1    ; exclude NUL

%ifdef USE_LIBC
    extern puts
    global main
section .text
main:
    ; TODO:
    ; 1) pass msg to puts()
    ; 2) return 0 from main
    xor eax, eax
    ret
%else
    global _start
section .text
_start:
    ; TODO:
    ; 1) write(STDOUT, msg, msg_len)
    ; 2) exit(0)
    mov eax, 60
    mov edi, 111             ; distinct exit code to show "incomplete"
    syscall
%endif
