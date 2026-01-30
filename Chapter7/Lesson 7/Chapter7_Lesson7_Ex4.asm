; Chapter7_Lesson7_Ex4.asm
; SysV AMD64 red zone demo (128 bytes below RSP usable by LEAF functions).
; The function sum3_redzone() does NOT adjust RSP and does NOT CALL anything.
;
; WARNING:
; - Red zone is not part of the Microsoft x64 ABI (Windows).
; - In kernel/interrupt contexts, treat red zone as unavailable.

global _start

section .text

_start:
    mov     rdi, 11
    mov     rsi, 22
    mov     rdx, 33
    call    sum3_redzone

    ; exit(status = rax & 255)
    mov     rdi, rax
    and     rdi, 255
    mov     eax, 60
    syscall

sum3_redzone:
    ; Store temporaries in the red zone (below RSP).
    mov     [rsp-8],  rdi
    mov     [rsp-16], rsi
    mov     [rsp-24], rdx

    mov     rax, [rsp-8]
    add     rax, [rsp-16]
    add     rax, [rsp-24]
    ret
