; Chapter 6 - Lesson 7 - Example 7
; Title: Alignment-sensitive SSE spills: MOVAPS vs MOVUPS
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson7_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o
;
; This program does not print; it simply exercises the routines.

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

_start:
    ; Call the safe version (works regardless of stack alignment assumptions)
    call spill_xmm_movups

    ; Call the fast/aligned version (requires correct prologue)
    call spill_xmm_movaps

    mov eax, 60
    xor edi, edi
    syscall

; spill_xmm_movups: uses unaligned moves (MOVUPS), no alignment requirements.
spill_xmm_movups:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    pxor xmm0, xmm0
    movups [rsp], xmm0
    movups xmm1, [rsp]

    add rsp, 16
    pop rbp
    ret

; spill_xmm_movaps: uses aligned moves (MOVAPS), requires [rsp] 16-aligned.
spill_xmm_movaps:
    push rbp
    mov rbp, rsp

    ; After push rbp, rsp is 16-aligned if ABI entry was respected.
    sub rsp, 16

    pxor xmm0, xmm0
    movaps [rsp], xmm0
    movaps xmm1, [rsp]

    add rsp, 16
    pop rbp
    ret
