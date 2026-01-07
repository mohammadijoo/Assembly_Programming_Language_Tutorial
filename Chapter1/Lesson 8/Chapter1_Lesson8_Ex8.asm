; file: crash_demo.asm (NASM, x86-64)

global _start

section .text
_start:
    xor rbx, rbx         ; rbx = 0
    mov rax, [rbx]       ; crash: invalid memory read at address 0

    ; unreachable
    mov rax, 60
    xor rdi, rdi
    syscall
