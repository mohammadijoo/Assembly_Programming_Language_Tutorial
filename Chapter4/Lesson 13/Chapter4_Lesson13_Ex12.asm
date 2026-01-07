; Chapter4_Lesson13_Ex12.asm
; Exercise Solution (Very Hard): A "patch-friendly call site" template.
; Idea: reserve enough bytes after a call to allow later patching to:
;   - replace CALL rel32 (5 bytes) with NOPs (to disable)
;   - replace CALL with JMP or vice versa
;   - extend a short conditional jump into a longer sequence by rewriting a nearby area
;
; This file demonstrates *layout discipline* and size checks, not runtime self-modification.

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
    ; A patchable call site: 5-byte CALL + 11 bytes of post-call padding.
    ; Many toolchains keep such "landing pads" so future patching can insert a short sequence.
callsite_start:
    call target
callsite_pad:
    NOP_BYTES 11
callsite_end:

%if (callsite_end - callsite_start) != (5 + 11)
    %error "Callsite size mismatch; expected 16 bytes total"
%endif

    ; Exit with 0
    mov eax, 60
    xor edi, edi
    syscall

target:
    ; Minimal target function
    ret
