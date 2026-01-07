; Chapter4_Lesson13_Ex8.asm
; Exercise Solution: a non-greedy NOP decomposition that minimizes prefix usage.
; Strategy:
;   - Prefer 8-byte NOPs over 9-byte NOPs in some cases to reduce 0x66 prefix density.
;   - Use a small set of building blocks and a decomposition heuristic.
;
; This is *one* reasonable policy; different CPUs may have different sweet spots.

BITS 64
GLOBAL _start

; Emit a single "block" NOP of length L in {1..8}.
%macro NOP_BLOCK 1
    %if %1 = 1
        nop
    %elif %1 = 2
        xchg ax, ax
    %elif %1 = 3
        db 0x0F, 0x1F, 0x00
    %elif %1 = 4
        db 0x0F, 0x1F, 0x40, 0x00
    %elif %1 = 5
        db 0x0F, 0x1F, 0x44, 0x00, 0x00
    %elif %1 = 6
        db 0x66, 0x0F, 0x1F, 0x44, 0x00, 0x00
    %elif %1 = 7
        db 0x0F, 0x1F, 0x80, 0x00, 0x00, 0x00, 0x00
    %elif %1 = 8
        db 0x0F, 0x1F, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00
    %else
        %error "NOP_BLOCK supports only 1..8"
    %endif
%endmacro

; Emit N bytes of NOP padding using a heuristic decomposition.
%macro NOP_BYTES_HEUR 1
    %assign __n %1
    %if __n <= 0
        ; nothing
    %elif __n <= 8
        NOP_BLOCK __n
    %else
        ; Heuristic:
        ; - If remainder would be 1, avoid ending with a 1-byte NOP by using 7+... instead of 8+...
        ; - Otherwise, prefer 8-byte blocks.
        %assign __rem (__n % 8)
        %if __rem = 1
            NOP_BLOCK 7
            NOP_BYTES_HEUR (__n - 7)
        %else
            NOP_BLOCK 8
            NOP_BYTES_HEUR (__n - 8)
        %endif
    %endif
%endmacro

SECTION .text
_start:
region_a:
    NOP_BYTES_HEUR 31
region_a_end:

%if (region_a_end - region_a) != 31
    %error "NOP_BYTES_HEUR length mismatch"
%endif

    mov eax, 60
    xor edi, edi
    syscall
