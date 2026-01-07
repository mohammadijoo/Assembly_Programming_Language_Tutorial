; Chapter 2 - Lesson 7 (Execution Flow) - Exercise Solution 1
; Hard: Iterative Euclidean GCD using DIV (control-flow heavy).
; Build:
;   nasm -f elf64 Chapter2_Lesson7_Ex10.asm -o ex10.o
;   ld ex10.o -o ex10

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .data
a dq 1071
b dq 462

SECTION .text
_start:
    mov rax, [a]
    mov rbx, [b]
    call gcd_u64

    ; Exit with low byte of gcd to observe via shell ($?).
    and eax, 0xFF
    mov edi, eax
    mov eax, 60
    syscall

; uint64_t gcd_u64(uint64_t a, uint64_t b)
; Input: RAX=a, RBX=b
; Output: RAX=gcd(a,b)
gcd_u64:
.loop:
    test rbx, rbx
    jz   .done              ; if b==0 return a

    ; rax = a, rbx = b
    xor edx, edx            ; RDX:RAX is dividend (unsigned)
    div rbx                 ; quotient in RAX, remainder in RDX

    ; Next: (a,b) = (b, rem)
    mov rax, rbx
    mov rbx, rdx
    jmp .loop

.done:
    ret
