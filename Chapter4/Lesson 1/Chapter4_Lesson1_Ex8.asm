;
; Chapter 4 - Lesson 1 (Arithmetic): Exercise 1 (Very Hard) - Solution
; Topic: 128-bit addition with carry propagation + reporting carry-out
;
; Build:
;   nasm -f elf64 Chapter4_Lesson1_Ex8.asm -o ex8.o
;   ld -o ex8 ex8.o

BITS 64
DEFAULT REL
GLOBAL _start

SECTION .data
; A = 0xFFFFFFFFFFFFFFFF_FFFFFFFFFFFFFFFF
a_lo dq 0xFFFFFFFFFFFFFFFF
a_hi dq 0xFFFFFFFFFFFFFFFF

; B = 0x0000000000000001_0000000000000002
b_lo dq 0x0000000000000002
b_hi dq 0x0000000000000001

SECTION .bss
s_lo resq 1
s_hi resq 1
carry resb 1

SECTION .text
_start:
    mov rax, [a_lo]
    add rax, [b_lo]
    mov [s_lo], rax

    mov rax, [a_hi]
    adc rax, [b_hi]       ; add high with carry-in
    mov [s_hi], rax

    setc byte [carry]     ; carry-out of the top word

    int3

    movzx edi, byte [carry]
    mov eax, 60
    syscall
