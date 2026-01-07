;
; Chapter 4 - Lesson 1 (Arithmetic): Example 3
; Topic: SUB, SBB, and multiword subtraction (128-bit) + borrow propagation
;
; Build:
;   nasm -f elf64 Chapter4_Lesson1_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o

BITS 64
DEFAULT REL
GLOBAL _start

SECTION .data
; A = 0x0000000000000001_FFFFFFFFFFFFFFFF
a_lo    dq  0xFFFFFFFFFFFFFFFF
a_hi    dq  0x0000000000000001

; B = 0x0000000000000000_0000000000000002
b_lo    dq  0x0000000000000002
b_hi    dq  0x0000000000000000

SECTION .bss
r_lo    resq 1
r_hi    resq 1
borrow  resb 1

SECTION .text
_start:
    ; r = A - B (128-bit)
    mov rax, [a_lo]
    sub rax, [b_lo]
    mov [r_lo], rax

    mov rax, [a_hi]
    sbb rax, [b_hi]       ; subtract high words with borrow
    mov [r_hi], rax

    ; Record whether final borrow occurred (CF after SBB)
    setc byte [borrow]

    int3

    ; Exit code = borrow (0 or 1)
    movzx edi, byte [borrow]
    mov eax, 60
    syscall
