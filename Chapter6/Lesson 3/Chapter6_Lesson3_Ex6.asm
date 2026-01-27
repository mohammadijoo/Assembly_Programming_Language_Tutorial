; Chapter6_Lesson3_Ex6.asm
; Example 6 (SysV AMD64 / Linux): floating-point parameters in XMM registers.
;
; Signature:
;   double dot2d(double ax, double ay, double bx, double by)
; SysV: ax=XMM0, ay=XMM1, bx=XMM2, by=XMM3, return in XMM0
;
; This program computes dot2d(1.5, -2.0, 4.0, 0.5) and stores the result
; (1.5*4.0 + (-2.0)*0.5 = 5.0) to memory, then exits with status 0.
;
; Build:
;   nasm -f elf64 Chapter6_Lesson3_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o
; Run:
;   ./ex6 ; exit code = 0

global _start

section .rodata
ax dq 1.5
ay dq -2.0
bx dq 4.0
by dq 0.5

section .bss
out resq 1

section .text

dot2d:
    mulsd   xmm0, xmm2
    mulsd   xmm1, xmm3
    addsd   xmm0, xmm1
    ret

_start:
    movsd   xmm0, [rel ax]
    movsd   xmm1, [rel ay]
    movsd   xmm2, [rel bx]
    movsd   xmm3, [rel by]
    call    dot2d
    movsd   [rel out], xmm0

    xor     edi, edi
    mov     eax, 60
    syscall
