; Linux x86-64 (SysV ABI). Assemble with NASM:
; nasm -f elf64 inspect.asm -o inspect.o
; ld inspect.o -o inspect
;
; This program writes N bytes starting at label code_start to stdout.

global _start

section .text

_start:
    ; write(1, code_start, code_len)
    mov eax, 1              ; SYS_write
    mov edi, 1              ; fd = stdout
    lea rsi, [rel code_start]
    mov edx, code_len
    syscall

    ; exit(0)
    mov eax, 60             ; SYS_exit
    xor edi, edi
    syscall

code_start:
    ; A small code snippet whose bytes we will print
    mov eax, 0x11223344
    add eax, 7
    ret

code_end:
code_len equ code_end - code_start
