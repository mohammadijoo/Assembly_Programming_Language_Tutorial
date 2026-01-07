\
; Chapter2_Lesson6_Ex1.asm
; NASM + ELF64 + Linux syscalls: write(1, msg, len) then exit(0).
;
; Build (Linux):
;   nasm -f elf64 -g -F dwarf Chapter2_Lesson6_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
;   ./ex1

BITS 64
default rel

section .rodata
msg:     db "Hello from NASM (ELF64)!", 10
msg_len: equ $ - msg

section .text
global _start
_start:
    ; write(STDOUT=1, msg, msg_len)
    mov eax, 1              ; SYS_write
    mov edi, 1              ; fd = 1
    lea rsi, [msg]          ; buf
    mov edx, msg_len        ; count
    syscall

    ; exit(0)
    mov eax, 60             ; SYS_exit
    xor edi, edi
    syscall
