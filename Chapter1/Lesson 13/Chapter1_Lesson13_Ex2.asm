; src/main_nasm.asm (NASM, Linux x86-64)
; Build target: ELF64 executable using syscalls

global _start
extern print_str

section .rodata
msg:    db "Hello from NASM workflow!", 10, 0

section .text
_start:
    lea rdi, [rel msg]      ; arg1: pointer to C-style string
    call print_str

    mov eax, 60             ; SYS_exit
    xor edi, edi            ; status = 0
    syscall
