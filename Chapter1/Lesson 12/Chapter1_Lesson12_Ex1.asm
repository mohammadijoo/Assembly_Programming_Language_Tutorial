; hello_nasm.asm (Linux x86-64, SysV ABI, syscall interface)
; Assemble: nasm -f elf64 hello_nasm.asm -o hello_nasm.o
; Link:     ld -o hello_nasm hello_nasm.o

global _start

section .rodata
msg:    db "Hello from NASM!", 10
msg_len equ $ - msg

section .text
_start:
    ; write(1, msg, msg_len)
    mov rax, 1          ; SYS_write
    mov rdi, 1          ; fd = stdout
    lea rsi, [rel msg]  ; buffer
    mov rdx, msg_len    ; length
    syscall

    ; exit(0)
    mov rax, 60         ; SYS_exit
    xor rdi, rdi
    syscall