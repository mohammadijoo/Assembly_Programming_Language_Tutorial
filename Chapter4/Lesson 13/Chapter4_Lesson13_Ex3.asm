; Chapter4_Lesson13_Ex3.asm
; A NASM macro that emits *exactly* N bytes worth of preferred multi-byte NOPs.
; This is closer to what modern compilers do for alignment padding than emitting N single-byte NOPs.

BITS 64
GLOBAL _start

%macro NOP_BYTES 1
    %assign __n %1
    %if __n <= 0
        ; nothing
    %elif __n = 1
        nop
    %elif __n = 2
        xchg ax, ax
    %elif __n = 3
        db 0x0F, 0x1F, 0x00
    %elif __n = 4
        db 0x0F, 0x1F, 0x40, 0x00
    %elif __n = 5
        db 0x0F, 0x1F, 0x44, 0x00, 0x00
    %elif __n = 6
        db 0x66, 0x0F, 0x1F, 0x44, 0x00, 0x00
    %elif __n = 7
        db 0x0F, 0x1F, 0x80, 0x00, 0x00, 0x00, 0x00
    %elif __n = 8
        db 0x0F, 0x1F, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00
    %elif __n = 9
        db 0x66, 0x0F, 0x1F, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00
    %else
        ; Greedy decomposition: 9-byte NOP + remainder.
        db 0x66, 0x0F, 0x1F, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00
        NOP_BYTES (__n - 9)
    %endif
%endmacro

SECTION .text
_start:
    ; Create a 23-byte padding region using optimal chunks.
pad_start:
    NOP_BYTES 23
pad_end:

    ; Exit(0)
    mov eax, 60
    xor edi, edi
    syscall
