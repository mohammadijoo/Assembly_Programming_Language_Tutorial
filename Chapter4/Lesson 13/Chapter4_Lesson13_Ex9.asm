; Chapter4_Lesson13_Ex9.asm
; Exercise Solution: assemble-time alignment assertions for hot labels.
; Uses NASM's $$ (start of section) to express a section-relative address.
;
; Important: This validates *within the section layout*; the linker may place the section
; at a different absolute address, but the alignment guarantee of ALIGN is preserved.

BITS 64
GLOBAL _start

%macro ASSERT_ALIGNED 2
    ; ASSERT_ALIGNED label, alignment
    %if ((%1 - $$) % %2) != 0
        %error "Alignment assertion failed for " %+ %1
    %endif
%endmacro

SECTION .text
_start:
    ; Introduce some bytes so the next label is not trivially aligned.
    db 0xCC, 0xCC, 0xCC

    align 32, db 0x90
hot_loop:
    ASSERT_ALIGNED hot_loop, 32

    mov r8d, 1000
.loop:
    add eax, 1
    dec r8d
    jnz .loop

    mov eax, 60
    xor edi, edi
    syscall
