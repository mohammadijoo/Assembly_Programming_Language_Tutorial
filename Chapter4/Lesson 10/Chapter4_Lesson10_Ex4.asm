bits 64
default rel

; Strength-reduction style constant multiplies using LEA (+ add/sub when needed).
; No IMUL is used.

global _start

section .text
_start:
    mov rdi, 123            ; x = 123

    ; 10*x = (5*x)*2 where 5*x = x + 4*x
    lea rax, [rdi + rdi*4]  ; 5x
    lea rax, [rax*2]        ; 10x  (valid: base absent, index=rax, scale=2)

    ; 29*x = 32*x - 3*x
    ; 32*x computed as (x*8)*4 (two LEAs)
    lea rcx, [rdi*8]        ; 8x
    lea rcx, [rcx*4]        ; 32x
    lea rdx, [rdi + rdi*2]  ; 3x
    sub rcx, rdx            ; 29x in rcx

    ; Exit code = (10x + 29x) mod 256 (just to have an observable result)
    add rax, rcx
    mov eax, 60
    mov edi, eax
    syscall
