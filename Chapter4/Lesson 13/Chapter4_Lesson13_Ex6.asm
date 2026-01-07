; Chapter4_Lesson13_Ex6.asm
; NOP padding around a jump table: aligning the table and case labels.
; Illustrates why compilers sometimes insert NOPs to keep tables/case blocks aligned.

BITS 64
GLOBAL _start

SECTION .text
_start:
    ; rdi = selector (0..3). Pick a value deterministically.
    mov edi, 2

    ; Bounds check
    cmp edi, 3
    ja default_case

    ; Compute address of jump target from table of rel32 offsets
    lea rbx, [rel jt_base]
    movsxd rax, dword [rbx + rdi*4]      ; sign-extend rel32
    lea rbx, [rbx + rax]                ; rbx = &target
    jmp rbx

default_case:
    mov edi, 9
    jmp finish

    ; Align the jump table itself (improves density and can reduce I-fetch splits)
    align 16, db 0x90
jt_base:
    dd case0 - jt_base
    dd case1 - jt_base
    dd case2 - jt_base
    dd case3 - jt_base

    ; Align frequently-used case blocks (toy example)
    align 16, db 0x90
case0:
    mov edi, 10
    jmp finish

    align 16, db 0x90
case1:
    mov edi, 11
    jmp finish

    align 16, db 0x90
case2:
    mov edi, 12
    jmp finish

    align 16, db 0x90
case3:
    mov edi, 13
    jmp finish

finish:
    mov eax, 60
    syscall
