; Chapter4_Lesson9_Ex7.asm
; Sign-extending a masked field: signed 12-bit sample stored in low 12 bits of a word.

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .data
sample dw 0x0F34              ; low 12 bits = 0xF34, sign bit (bit11) = 1 -> negative

SECTION .text
_start:
    movzx eax, word [sample]  ; EAX = 0x00000F34
    and eax, 0x0FFF           ; keep only the 12-bit field

    ; Sign-extend 12->32: shift left (32-12)=20, then arithmetic shift right 20
    shl eax, 20
    sar eax, 20

    ; Inspect EAX to verify sign-extended value.

    mov eax, 60
    xor edi, edi
    syscall
