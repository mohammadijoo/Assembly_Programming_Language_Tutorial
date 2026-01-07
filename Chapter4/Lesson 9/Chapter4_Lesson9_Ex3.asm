; Chapter4_Lesson9_Ex3.asm
; Signed int8 accumulation: MOVSX is required to preserve sign.

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .data
arr db -1, 2, -3, 4, -5
len equ $-arr

SECTION .text
_start:
    lea rsi, [arr]
    mov ecx, len
    xor rax, rax             ; sum in RAX (signed)

.s_loop:
    movsx rdx, byte [rsi]    ; RDX = sign-extended element
    add rax, rdx

    inc rsi
    dec ecx
    jnz .s_loop

    ; Expected sum: (-1)+2+(-3)+4+(-5) = -3. Inspect RAX to confirm.

    mov eax, 60
    xor edi, edi
    syscall
