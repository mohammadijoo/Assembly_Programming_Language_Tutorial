;
; Chapter 4 - Lesson 1 (Arithmetic): Example 5
; Topic: Signed IMUL forms (1-op, 2-op, 3-op) and overflow signaling via OF/CF
;
; Build:
;   nasm -f elf64 Chapter4_Lesson1_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o

BITS 64
DEFAULT REL
GLOBAL _start

SECTION .data
x       dq  -5000000000          ; fits in 64-bit
y       dq  3
k       dq  10

SECTION .bss
r1_lo   resq 1
r1_hi   resq 1
r2      resq 1
r3      resq 1
cc      resb 3

SECTION .text
_start:
    ; 1-operand IMUL: RDX:RAX = RAX * r/m64 (signed)
    mov rax, [x]
    imul qword [y]
    mov [r1_lo], rax
    mov [r1_hi], rdx
    seto byte [cc+0]

    ; 2-operand IMUL: r64 = r64 * r/m64 (low half only, flags signal truncation)
    mov rax, [x]
    imul rax, qword [k]      ; rax = x*10 (low 64 bits)
    mov [r2], rax
    seto byte [cc+1]

    ; 3-operand IMUL: r64 = r/m64 * imm (no need to pre-load destination)
    imul rbx, qword [x], 7   ; rbx = x*7
    mov [r3], rbx
    seto byte [cc+2]

    int3

    ; Exit code = cc[0] + 2*cc[1] + 4*cc[2]
    movzx eax, byte [cc+0]
    movzx ebx, byte [cc+1]
    shl ebx, 1
    add eax, ebx
    movzx ebx, byte [cc+2]
    shl ebx, 2
    add eax, ebx

    mov edi, eax
    mov eax, 60
    syscall
