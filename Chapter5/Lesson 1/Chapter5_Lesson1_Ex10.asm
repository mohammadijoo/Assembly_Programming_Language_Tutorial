BITS 64
default rel
global _start

; Very hard exercise (with solution): Branchless clamp for signed 64-bit.
; clamp_i64(x, lo, hi) = lo if x < lo, hi if x > hi, else x.
; No conditional branches inside clamp_i64.

section .data
msg_ok   db "OK", 10
msg_ok_len equ $-msg_ok
msg_fail db "FAIL", 10
msg_fail_len equ $-msg_fail

section .text
clamp_i64:
    ; Inputs: RDI=x, RSI=lo, RDX=hi
    ; Output: RAX
    mov rax, rdi

    ; if x < lo -> rax = lo
    cmp rax, rsi
    cmovl rax, rsi

    ; if rax > hi -> rax = hi
    cmp rax, rdx
    cmovg rax, rdx

    ret

print_ok:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_ok
    mov rdx, msg_ok_len
    syscall
    ret

print_fail:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_fail
    mov rdx, msg_fail_len
    syscall
    ret

_start:
    ; Test 1: x=5, lo=0, hi=10 -> 5
    mov rdi, 5
    mov rsi, 0
    mov rdx, 10
    call clamp_i64
    cmp rax, 5
    jne .fail

    ; Test 2: x=-7, lo=-3, hi=10 -> -3
    mov rdi, -7
    mov rsi, -3
    mov rdx, 10
    call clamp_i64
    cmp rax, -3
    jne .fail

    ; Test 3: x=99, lo=0, hi=10 -> 10
    mov rdi, 99
    mov rsi, 0
    mov rdx, 10
    call clamp_i64
    cmp rax, 10
    jne .fail

    call print_ok
    xor rdi, rdi
    jmp .exit

.fail:
    call print_fail
    mov rdi, 1

.exit:
    mov rax, 60
    syscall
