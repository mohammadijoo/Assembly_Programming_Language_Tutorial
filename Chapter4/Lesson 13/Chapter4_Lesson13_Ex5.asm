; Chapter4_Lesson13_Ex5.asm
; Layout-oriented NOP padding: keeping a hot path contiguous and aligning branch targets.
; Demonstrates "hot/cold" splitting within a single function using labels and padding.

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
    ; Simulate a "hot" fall-through path and a cold error handler.
    ; We align the hot loop to 32 bytes, and we align the cold handler far away
    ; so it doesn't pollute the hot I-cache line as easily.

    mov r8d, 30000000
    xor eax, eax

    align 32, db 0x90
hot_loop:
    ; Hot path: tight arithmetic + predictable branch
    add eax, 3
    sub eax, 1
    dec r8d
    jnz hot_loop

    ; Done: jump over the cold code.
    jmp done

    ; Optional padding to force cold code onto a different boundary.
    ; This is intentionally "large enough" to separate hot/cold.
    NOP_BYTES 48

cold_error_path:
    ; Cold path: would be reached rarely; here we just set a nonzero exit status.
    mov edi, 2
    mov eax, 60
    syscall

done:
    xor edi, edi
    mov eax, 60
    syscall
