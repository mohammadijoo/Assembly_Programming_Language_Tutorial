\
; Chapter2_Lesson6_Ex12.asm
; Programming Exercise 1 (Solution): dual-mode build via conditional assembly.
;
; Build path A (libc):
;   nasm -f elf64 -g -F dwarf -D USE_LIBC=1 Chapter2_Lesson6_Ex12.asm -o ex12.o
;   gcc -no-pie -g ex12.o -o ex12
;   ./ex12
;
; Build path B (pure syscalls):
;   nasm -f elf64 -g -F dwarf Chapter2_Lesson6_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o
;   ./ex12

BITS 64
default rel

section .rodata
msg_nl: db "Hello (selected at assemble-time).", 10, 0
msg:    db "Hello (selected at assemble-time).", 0
msg_nl_len equ ($ - msg_nl) - 1

%ifdef USE_LIBC
    extern puts
    global main
section .text
main:
    lea rdi, [msg]           ; puts expects NUL-terminated string
    xor eax, eax
    call puts
    xor eax, eax
    ret
%else
    global _start
section .text
_start:
    mov eax, 1               ; SYS_write
    mov edi, 1               ; STDOUT
    lea rsi, [msg_nl]
    mov edx, msg_nl_len
    syscall

    mov eax, 60              ; SYS_exit
    xor edi, edi
    syscall
%endif
