; Chapter4_Lesson9_Ex2.asm
; Unsigned byte accumulation: why MOVZX is the "safe load" idiom.

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .data
arr db 1, 2, 250, 4, 5
len equ $-arr

SECTION .text
_start:
    lea rsi, [arr]
    mov ecx, len
    xor eax, eax             ; sum in EAX

.u_loop:
    ; Correct: each load is widened to a clean 32-bit value in EDX (0..255)
    movzx edx, byte [rsi]
    add eax, edx

    inc rsi
    dec ecx
    jnz .u_loop

    ; EAX now holds the sum (expected 262). Inspect EAX to confirm.

    mov eax, 60
    xor edi, edi
    syscall
