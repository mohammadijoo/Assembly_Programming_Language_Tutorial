; Chapter7_Lesson7_Ex3.asm
; Alignment pitfalls when saving an "odd" number of 8-byte registers.
; We intentionally push RBX in addition to a standard RBP frame, which flips alignment.
; Then we fix alignment before CALLing nested().

global _start

section .text

_start:
    call    caller
    ; rax holds nested() entry alignment (expected 8)
    mov     rdi, rax
    mov     eax, 60
    syscall

caller:
    push    rbp
    mov     rbp, rsp

    push    rbx                 ; extra push => may break 16B alignment before a call

    sub     rsp, 32             ; locals (multiple of 16) keep current mod 16
    ; At this point, RSP is misaligned for a CALL (likely RSP mod 16 == 8)

    sub     rsp, 8              ; fix: bring RSP to 0 mod 16 before CALL
    call    nested
    add     rsp, 8

    add     rsp, 32
    pop     rbx
    pop     rbp
    ret

nested:
    ; Record entry alignment.
    mov     rax, rsp
    and     rax, 15
    ret
