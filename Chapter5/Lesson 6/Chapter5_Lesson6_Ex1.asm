bits 64
default rel

global _start
section .text

; Ex1: Let NASM choose the shortest encoding (short vs near) based on distance.
; Build:
;   nasm -felf64 Chapter5_Lesson6_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
; Inspect encoding:
;   nasm -felf64 -l ex1.lst Chapter5_Lesson6_Ex1.asm
;   objdump -d -Mintel ex1 | less

_start:
    jmp .close_target           ; typically encodes as EB cb  (rel8)

    ; A few bytes of filler so the label is not immediately after the jump.
    nop
    nop

.close_target:
    ; Force a long distance so NASM must use rel32 (near jump, opcode E9 cd).
    jmp .far_target             ; typically encodes as E9 cd cd cd cd (rel32)

    times 300 nop               ; 300 bytes => out of rel8 range

.far_target:
    ; Exit(0)
    mov eax, 60
    xor edi, edi
    syscall
