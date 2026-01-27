; Chapter 6 - Lesson 7 - Exercise 2 (Solution)
; Title: SSE dot product (float32) with alignment contract + fast path
;
; Contract:
;   - rdi = ptrA (float*)
;   - rsi = ptrB (float*)
;   - rdx = n (count of float32)
; Requirements (fast path):
;   - ptrA and ptrB are 16-byte aligned
;   - n is multiple of 4
; Returns:
;   - xmm0 = dot product (float)
;
; Build (Linux, for object use in C or further asm):
;   nasm -felf64 Chapter6_Lesson7_Ex9.asm -o ex9.o
;
; Note: This is a library-style file; no _start/main provided.

BITS 64
DEFAULT REL

GLOBAL dot_f32_aligned4

SECTION .text

dot_f32_aligned4:
    push rbp
    mov rbp, rsp
    ; No calls, but we still keep a clean frame for debug readability.

    ; Validate n % 4 == 0
    test rdx, 3
    jne .bad

    ; Validate alignment: (ptr & 15) == 0
    mov rax, rdi
    or  rax, rsi
    and rax, 15
    jne .bad

    ; xmm0 = accumulator
    pxor xmm0, xmm0

.loop:
    test rdx, rdx
    je .done

    movaps xmm1, [rdi]
    movaps xmm2, [rsi]
    mulps  xmm1, xmm2
    addps  xmm0, xmm1

    add rdi, 16
    add rsi, 16
    sub rdx, 4
    jmp .loop

.done:
    ; Horizontal sum of xmm0 lanes: (((x0+x1)+(x2+x3)))
    movaps xmm1, xmm0
    shufps xmm1, xmm1, 0b11101110   ; swap pairs
    addps  xmm0, xmm1
    movaps xmm1, xmm0
    shufps xmm1, xmm1, 0b00010001
    addss  xmm0, xmm1

    pop rbp
    ret

.bad:
    ; Return 0.0f on contract violation
    pxor xmm0, xmm0
    pop rbp
    ret
