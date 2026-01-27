bits 64
default rel

global _start
section .text

; Ex14 (Exercise Solution 4):
; Hot/Cold splitting with a "branch island" to keep hot-path conditionals short.
; The hot header is compact and uses short Jcc; cold work lives far away.

%macro JCC_ISLAND 2
    ; If condition holds, branch to a local island (short), then near-jump to target.
    j%1 short %%island
    jmp short %%after
%%island:
    jmp near %2
%%after:
%endmacro

_start:
    ; rdi: pretend input argument (here set to 0 to trigger cold)
    xor edi, edi

    test edi, edi
    ; If rdi==0, go to cold_work (far) but keep the conditional short.
    JCC_ISLAND e, cold_work

    ; hot path (tiny)
    mov edi, 0
    mov eax, 60
    syscall

    times 1024 nop

section .text.cold
align 16

cold_work:
    ; cold path is large and slow (simulated)
    times 2048 nop
    mov edi, 3
    mov eax, 60
    syscall
