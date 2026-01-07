; ex4_two_line_printer.asm
BITS 64

%define SYS_write 1
%define SYS_exit  60
%define STDOUT_FD 1

section .data
    a db "Line A: reuse a print routine", 10
    a_len equ $ - a
    b db "Line B: same routine, different args", 10
    b_len equ $ - b

section .text
global _start

; print_buf(rsi=buf, edx=len)
; Clobbers: rax, rdi
print_buf:
    mov eax, SYS_write
    mov edi, STDOUT_FD
    syscall
    ret

_start:
    lea rsi, [rel a]
    mov edx, a_len
    call print_buf

    lea rsi, [rel b]
    mov edx, b_len
    call print_buf

    mov eax, SYS_exit
    xor edi, edi
    syscall
