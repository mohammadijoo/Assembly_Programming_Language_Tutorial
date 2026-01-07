; Chapter4_Lesson9_Ex6.asm
; Sign-extending an odd width: signed 24-bit little-endian -> signed 32-bit in EAX.

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .data
; Example value: 0x00FF80 (24-bit). As signed 24-bit, this is negative because bit23=1.
b0 db 0x80
b1 db 0xFF
b2 db 0x00

SECTION .text
_start:
    ; Build 24-bit value in EAX = b0 | (b1<<8) | (b2<<16)
    movzx eax, byte [b0]
    movzx ecx, byte [b1]
    shl ecx, 8
    or  eax, ecx
    movzx ecx, byte [b2]
    shl ecx, 16
    or  eax, ecx

    ; Sign-extend from 24 to 32 using shift pair:
    ; Move sign bit (bit23) to bit31, then arithmetic shift back.
    shl eax, 8
    sar eax, 8

    ; Inspect EAX: it now contains the signed 32-bit equivalent.

    mov eax, 60
    xor edi, edi
    syscall
