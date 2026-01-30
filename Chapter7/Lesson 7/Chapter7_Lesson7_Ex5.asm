; Chapter7_Lesson7_Ex5.asm
; Why you must avoid red-zone storage in NON-LEAF functions:
; a CALL in the middle will typically use space below your RSP, overlapping your red zone.
; Here we do it correctly: use an explicit stack frame for locals.

global _start

section .text

_start:
    mov     rdi, 7
    mov     rsi, 8
    mov     rdx, 9
    call    sum3_via_call

    mov     rdi, rax
    and     rdi, 255
    mov     eax, 60
    syscall

; rdi=a, rsi=b, rdx=c
sum3_via_call:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32             ; 3 qwords + padding, keeps 16B alignment (after push rbp)

    mov     [rbp-8],  rdi
    mov     [rbp-16], rsi
    mov     [rbp-24], rdx

    mov     rdi, [rbp-8]
    mov     rsi, [rbp-16]
    call    add2                ; safe: stack remains aligned

    add     rax, [rbp-24]

    mov     rsp, rbp
    pop     rbp
    ret

; rdi=x, rsi=y => rax=x+y
add2:
    lea     rax, [rdi + rsi]
    ret
