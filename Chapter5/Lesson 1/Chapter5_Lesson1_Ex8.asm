BITS 64
default rel
global _start

; Hard exercise (with solution): Branchless inclusive range test for unsigned 64-bit.
;   between_u64(x, lo, hi) returns AL = 1 iff lo <= x <= hi (unsigned), else 0.
;   No conditional branches inside between_u64.

section .data
msg_ok   db "OK", 10
msg_ok_len equ $-msg_ok
msg_fail db "FAIL", 10
msg_fail_len equ $-msg_fail

section .text
between_u64:
    ; Inputs: RDI=x, RSI=lo, RDX=hi
    ; Output: AL = 0/1
    mov rax, rdi
    cmp rax, rsi
    setae al                 ; unsigned: x >= lo
    mov rcx, rax             ; save (AL in low byte is enough)

    mov rax, rdi
    cmp rax, rdx
    setbe al                 ; unsigned: x <= hi

    and al, cl               ; combine
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
    ; Test 1: x=10, lo=10, hi=20 => true
    mov rdi, 10
    mov rsi, 10
    mov rdx, 20
    call between_u64
    cmp al, 1
    jne .fail

    ; Test 2: x=21, lo=10, hi=20 => false
    mov rdi, 21
    mov rsi, 10
    mov rdx, 20
    call between_u64
    cmp al, 0
    jne .fail

    ; Test 3: x=0, lo=1, hi=1 => false
    mov rdi, 0
    mov rsi, 1
    mov rdx, 1
    call between_u64
    cmp al, 0
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
