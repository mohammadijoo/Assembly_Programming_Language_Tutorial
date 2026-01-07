; Chapter3_Lesson12_Ex1.asm
; Fixed-point basics: Q16.16 constants and simple addition
;
; build:
;   nasm -felf64 Chapter3_Lesson12_Ex1.asm -o Chapter3_Lesson12_Ex1.o
;   ld -o Chapter3_Lesson12_Ex1 Chapter3_Lesson12_Ex1.o
; run:
;   ./Chapter3_Lesson12_Ex1
;
; Inspect sum_result in a debugger to verify the raw Q16.16 value.

BITS 64
default rel

%define SYS_exit 60

section .data
; Q16.16 constants (signed 32-bit):
;   value_real = value_raw / 65536
one_q16_16     dd 0x00010000          ; 1.0
neg_quarter    dd 0xFFFFC000          ; -0.25  ( -1/4 * 65536 )
one_and_half   dd 0x00018000          ; 1.5    ( 3/2  * 65536 )

sum_result     dd 0                   ; will hold 1.25 (0x00014000)

section .text
global _start

_start:
    mov eax, [one_and_half]
    add eax, [neg_quarter]            ; 1.5 + (-0.25) = 1.25
    mov [sum_result], eax

    xor edi, edi
    mov eax, SYS_exit
    syscall
