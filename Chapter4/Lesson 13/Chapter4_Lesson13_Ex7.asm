; Chapter4_Lesson13_Ex7.asm
; "Header-style" macro bundle: you would normally put this in an .inc file and %include it.
; Kept as .asm per course packaging requirement.

; ---- BEGIN align_nop "header" ----
%ifndef ALIGN_NOP_INC_GUARD
%define ALIGN_NOP_INC_GUARD 1

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

; Align a label to a power-of-two boundary using a high-quality padding strategy:
;   1) use NASM's ALIGN for coarse padding
;   2) if you need an exact size, use NOP_BYTES around label arithmetic checks
%macro ALIGN_CODE 1
    align %1, db 0x90
%endmacro

%endif
; ---- END align_nop "header" ----

; Dummy stub so assembling this file alone succeeds.
BITS 64
GLOBAL _start
SECTION .text
_start:
    mov eax, 60
    xor edi, edi
    syscall
