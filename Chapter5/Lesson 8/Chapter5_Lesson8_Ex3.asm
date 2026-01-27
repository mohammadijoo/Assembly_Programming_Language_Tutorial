; Chapter 5 - Lesson 8, Example 3
; Hot/cold layout: likely path fall-through, cold error path out-of-line.
; Target: Linux x86-64, NASM

BITS 64
DEFAULT REL

global _start

section .data
values      dq  10, 20, 30, 40, 50, 60, 70, 80
n_values    dq  8
result      dq  0

section .text
validate_and_accumulate:
    xor     rax, rax
    xor     rcx, rcx
.loop:
    cmp     rcx, rsi
    je      .done
    mov     rdx, [rdi + rcx*8]
    cmp     rdx, 0
    jl      .error
    cmp     rdx, 100
    jg      .error
    add     rax, rdx
    inc     rcx
    jmp     .loop
.error:
    mov     rax, -1
    ret
.done:
    ret

_start:
    lea     rdi, [values]
    mov     rsi, [n_values]
    call    validate_and_accumulate
    mov     [result], rax
    mov     eax, 60
    xor     edi, edi
    syscall
