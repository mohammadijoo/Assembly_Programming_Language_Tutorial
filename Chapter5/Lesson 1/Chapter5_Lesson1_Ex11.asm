BITS 64
default rel
global _start

; Very hard exercise (with solution): Ternary operator (cond ? a : b) without branching.
; cond derived from (x != 0).
; Output computed via mask blend:
;   mask = (x != 0) ? -1 : 0
;   y = (a & mask) | (b & ~mask)

section .data
msg_ok   db "OK", 10
msg_ok_len equ $-msg_ok
msg_fail db "FAIL", 10
msg_fail_len equ $-msg_fail

section .text
select_u64:
    ; Inputs: RDI=x (condition source), RSI=a, RDX=b
    ; Output: RAX = (x!=0) ? a : b
    mov rcx, rdi
    test rcx, rcx
    setnz al
    movzx rax, al
    neg rax                    ; rax = 0 or -1 (mask)

    mov r8,  rsi               ; a
    mov r9,  rdx               ; b

    and r8,  rax               ; a & mask
    not rax
    and r9,  rax               ; b & ~mask
    or  r8,  r9

    mov rax, r8
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
    ; Case 1: x=0 -> select b
    mov rdi, 0
    mov rsi, 111
    mov rdx, 222
    call select_u64
    cmp rax, 222
    jne .fail

    ; Case 2: x=7 -> select a
    mov rdi, 7
    mov rsi, 111
    mov rdx, 222
    call select_u64
    cmp rax, 111
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
