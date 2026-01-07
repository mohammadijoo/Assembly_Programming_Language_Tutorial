BITS 64
default rel
global _start

; Ex2: NEG semantics and flags.
; NEG r/m computes: 0 - operand.
; CF is set iff operand != 0. OF is set on the most-negative value (e.g., 0x800..0).

section .data
    rflags_neg_zero    dq 0
    rflags_neg_nonzero dq 0
    rflags_neg_min     dq 0
    res_neg_min        dq 0

section .text
_start:
    ; Case 1: operand = 0  -> result = 0, CF = 0
    xor rax, rax
    neg rax
    pushfq
    pop qword [rflags_neg_zero]

    ; Case 2: operand = 5  -> result = -5, CF = 1
    mov rax, 5
    neg rax
    pushfq
    pop qword [rflags_neg_nonzero]

    ; Case 3: operand = INT64_MIN -> overflow, OF = 1 (result unchanged)
    mov rax, 0x8000000000000000
    neg rax
    mov [res_neg_min], rax
    pushfq
    pop qword [rflags_neg_min]

    mov eax, 60
    xor edi, edi
    syscall
