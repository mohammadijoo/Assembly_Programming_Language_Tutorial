;
; Chapter 4 - Lesson 1 (Arithmetic): Example 4
; Topic: Unsigned MUL: implicit operands and 128-bit product in RDX:RAX
;
; Build:
;   nasm -f elf64 Chapter4_Lesson1_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o
;
; Notes:
;   mul r/m64 computes: RDX:RAX = RAX * r/m64 (unsigned)
;   CF and OF are set to 1 iff high half (RDX) != 0. Other flags are undefined.

BITS 64
DEFAULT REL
GLOBAL _start

SECTION .data
a       dq  0xFFFFFFFFFFFFFFF0   ; large value
b       dq  0x0000000000000100   ; 256

SECTION .bss
prod_lo resq 1
prod_hi resq 1
ofcf    resb 2

SECTION .text
_start:
    mov rax, [a]
    mul qword [b]         ; RDX:RAX = a*b

    mov [prod_lo], rax
    mov [prod_hi], rdx

    ; Snapshot OF/CF from this MUL
    seto byte [ofcf+0]
    setc byte [ofcf+1]

    int3

    ; Exit code: (OF<<1) | CF
    movzx eax, byte [ofcf+0]
    shl eax, 1
    or  al, byte [ofcf+1]
    mov edi, eax
    mov eax, 60
    syscall
