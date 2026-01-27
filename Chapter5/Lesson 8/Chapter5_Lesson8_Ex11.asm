; Chapter 5 - Lesson 8, Exercise Solution 3
; Hot-path numeric parser with cold error path.
; Target: Linux x86-64, NASM

BITS 64
DEFAULT REL

global _start

section .data
s_good      db "12345678901234567890", 0
s_bad       db "1234x67890", 0
result_good dq 0
result_bad  dq 0

section .text
parse_u64_decimal:
    xor rax, rax
    xor rdx, rdx
.loop:
    mov bl, [rdi]
    test bl, bl
    je   .done
    cmp  bl, '0'
    jb   .error
    cmp  bl, '9'
    ja   .error
    imul rax, rax, 10
    movzx rcx, bl
    sub  rcx, '0'
    add  rax, rcx
    inc  rdi
    jmp  .loop
.error:
    mov rdx, 1
    ret
.done:
    ret

_start:
    lea rdi, [s_good]
    call parse_u64_decimal
    mov [result_good], rax

    lea rdi, [s_bad]
    call parse_u64_decimal
    mov [result_bad], rax

    mov eax, 60
    xor edi, edi
    syscall
