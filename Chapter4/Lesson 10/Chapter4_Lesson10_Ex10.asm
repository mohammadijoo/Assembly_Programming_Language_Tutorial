bits 64
default rel

; Exercise 1 (solution):
; Implement mul_29(x) using only LEA/ADD/SUB (no IMUL/MUL).
; Here we compute 29x = 32x - 3x with two LEAs + one LEA + SUB.

global _start

section .text
mul_29:
    ; input: rdi = x
    ; output: rax = 29*x
    lea rax, [rdi*8]        ; 8x
    lea rax, [rax*4]        ; 32x
    lea rcx, [rdi + rdi*2]  ; 3x
    sub rax, rcx            ; 29x
    ret

_start:
    mov rdi, 7
    call mul_29             ; 203

    ; exit status = 203 (fits in 0..255)
    mov eax, 60
    mov edi, 203
    syscall
