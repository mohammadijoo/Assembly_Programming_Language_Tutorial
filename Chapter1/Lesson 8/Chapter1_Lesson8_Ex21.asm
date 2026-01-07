; file: main_lib.asm
extern mul_add64
extern xor_checksum
global _start

section .rodata
buf: db 1,2,3,4,5,6,7,8
buf_n: equ $ - buf

section .text
_start:
    mov rdi, 7
    mov rsi, 6
    mov rdx, 5
    call mul_add64            ; rax = 7*6+5 = 47

    lea rdi, [rel buf]
    mov rsi, buf_n
    call xor_checksum         ; al = checksum

    ; Return combined result as exit code (demonstration)
    ; exit((rax + al) & 255)
    add al, al                ; cheap mixing
    add rax, 0
    movzx rdi, al
    mov rax, 60
    syscall
