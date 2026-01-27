; Chapter6_Lesson3_Ex8.asm
; Example 8 (SysV AMD64): callee-saved registers matter when passing parameters.
;
; Signature:
;   int64 scale_add(int64 a, int64 b, int64 scale) = a + scale*b
; SysV args: a=RDI, b=RSI, scale=RDX
; We'll use RBX (callee-saved) to hold "scale", so we must preserve it.
;
; Build:
;   nasm -f elf64 Chapter6_Lesson3_Ex8.asm -o ex8.o
;   ld -o ex8 ex8.o
; Run:
;   ./ex8 ; exit code = 29  (5 + 3*8)

global _start

section .text

scale_add:
    push    rbx            ; preserve callee-saved RBX
    mov     rbx, rdx       ; scale

    mov     rax, rsi       ; rax = b
    imul    rax, rbx       ; rax = b*scale
    add     rax, rdi       ; rax = a + b*scale

    pop     rbx
    ret

_start:
    mov     edi, 5
    mov     esi, 8
    mov     edx, 3
    call    scale_add

    mov     edi, eax
    mov     eax, 60
    syscall
