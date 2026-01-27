; Chapter5_Lesson2_Ex7.asm
; Topic demo: Loop unrolling + remainder handling (a classic optimization pattern)
;
; Sum a qword array with unroll factor 4:
;   - "main loop" handles groups of 4
;   - "remainder loop" handles 0..3 leftover items
;
; Build:
;   nasm -felf64 Chapter5_Lesson2_Ex7.asm -o Chapter5_Lesson2_Ex7.o
;   ld -o Chapter5_Lesson2_Ex7 Chapter5_Lesson2_Ex7.o
;
; Exit status = (sum mod 256)

BITS 64
default rel

section .data
arr: dq 1,2,3,4, 5,6,7,8, 9,10,11,12, 13,14
len_q equ ($-arr)/8

section .text
global _start

_start:
    lea rsi, [arr]
    xor rax, rax            ; accumulator

    mov edx, len_q          ; EDX = total count
    mov ecx, edx
    shr ecx, 2              ; ECX = groups of 4
    and edx, 3              ; EDX = remainder (0..3)

    test ecx, ecx
    jz .remainder

.group_loop:
    add rax, [rsi]
    add rax, [rsi+8]
    add rax, [rsi+16]
    add rax, [rsi+24]
    add rsi, 32
    dec ecx
    jnz .group_loop

.remainder:
    test edx, edx
    jz .done

.rem_loop:
    add rax, [rsi]
    add rsi, 8
    dec edx
    jnz .rem_loop

.done:
    and eax, 255
    mov edi, eax
    mov eax, 60
    syscall
