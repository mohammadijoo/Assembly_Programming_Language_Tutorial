; Chapter4_Lesson13_Ex10.asm
; Exercise Solution: "Branch island" layout to keep hot path linear and cold path out-of-line.
; Compilers often create out-of-line cold blocks and may pad so that the hot path stays within
; fewer I-cache lines and avoids problematic fetch boundaries.

BITS 64
GLOBAL _start

%macro ALIGN_CODE 1
    align %1, db 0x90
%endmacro

SECTION .text
_start:
    mov r8d, 25000000
    xor eax, eax

    ; Hot entry aligned to 16, hot loop aligned to 32.
    ALIGN_CODE 16
entry:
    test r8d, r8d
    jle cold_exit

    ALIGN_CODE 32
hot:
    add eax, 5
    sub eax, 2
    dec r8d
    jnz hot

    ; Keep the hot fall-through linear; jump over the cold island.
    jmp finish

    ; Cold island: force to its own alignment boundary.
    ALIGN_CODE 64
cold_exit:
    mov edi, 1
    mov eax, 60
    syscall

finish:
    xor edi, edi
    mov eax, 60
    syscall
