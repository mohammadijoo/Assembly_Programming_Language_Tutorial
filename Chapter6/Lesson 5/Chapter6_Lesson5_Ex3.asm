bits 64
default rel
global _start

section .text
_start:
    ; Recursive factorial demo: fact_rec(10) = 3628800
    mov edi, 10
    call fact_rec

    mov rcx, 3628800
    cmp rax, rcx
    jne .bad

.good:
    xor edi, edi
    mov eax, 60
    syscall

.bad:
    mov edi, 1
    mov eax, 60
    syscall

; uint64_t fact_rec(uint64_t n)
; - Base case: n <= 1 -> 1
; - Recursive case: n * fact_rec(n-1)
fact_rec:
    cmp rdi, 1
    jbe .base

    ; Non-leaf: create a frame to keep 'n' across the recursive call.
    push rbp
    mov rbp, rsp
    sub rsp, 16               ; reserve locals; keeps stack aligned for CALL

    mov [rbp-8], rdi          ; save n
    dec rdi                   ; n-1
    call fact_rec             ; returns fact(n-1) in RAX

    mov rcx, [rbp-8]          ; reload n
    imul rax, rcx             ; n * fact(n-1)

    leave
    ret

.base:
    mov eax, 1
    ret
