; Chapter4_Lesson13_Ex4.asm
; Compile-time verification: prove your padding macro emitted exactly the requested number of bytes.
; Uses NASM's location counter ($) and local label arithmetic.

BITS 64
GLOBAL _start

%macro NOP_BYTES 1
    %assign __n %1
    %if __n <= 0
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
        db 0x66, 0x0F, 0x1F, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00
        NOP_BYTES (__n - 9)
    %endif
%endmacro

SECTION .text
_start:
    ; Reserve exactly 5 bytes for a future patch (e.g., E9 rel32 jmp or E8 rel32 call).
patch_region_start:
    NOP_BYTES 5
patch_region_end:

%if (patch_region_end - patch_region_start) != 5
    %error "NOP_BYTES failed: patch region is not 5 bytes"
%endif

    ; Exit(0)
    mov eax, 60
    xor edi, edi
    syscall
