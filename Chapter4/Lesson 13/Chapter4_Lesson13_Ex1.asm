; Chapter4_Lesson13_Ex1.asm
; Demonstrating architectural NOPs and common multi-byte NOP encodings (NASM, x86-64).

BITS 64
GLOBAL _start

SECTION .text
_start:
    ; 1-byte NOP (0x90)
    nop

    ; 2-byte NOP: 66 90  (xchg ax, ax)
    xchg ax, ax

    ; 3-byte NOP: 0F 1F 00
    db 0x0F, 0x1F, 0x00

    ; 4-byte NOP: 0F 1F 40 00
    db 0x0F, 0x1F, 0x40, 0x00

    ; 5-byte NOP: 0F 1F 44 00 00
    db 0x0F, 0x1F, 0x44, 0x00, 0x00

    ; 6-byte NOP: 66 0F 1F 44 00 00
    db 0x66, 0x0F, 0x1F, 0x44, 0x00, 0x00

    ; 7-byte NOP: 0F 1F 80 00 00 00 00
    db 0x0F, 0x1F, 0x80, 0x00, 0x00, 0x00, 0x00

    ; 8-byte NOP: 0F 1F 84 00 00 00 00 00
    db 0x0F, 0x1F, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00

    ; 9-byte NOP: 66 0F 1F 84 00 00 00 00 00
    db 0x66, 0x0F, 0x1F, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00

    ; Exit(0)
    mov eax, 60
    xor edi, edi
    syscall
