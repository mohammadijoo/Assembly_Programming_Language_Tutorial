; Chapter6_Lesson3_Ex5.asm
; Example 5 (SysV AMD64 / Linux): multiple outputs via pointer parameters.
;
; Signature:
;   uint64 divmod_u64(uint64 numer, uint64 denom, uint64 *q_out, uint64 *r_out)
; SysV: numer=RDI, denom=RSI, q_out=RDX, r_out=RCX
;
; div uses RDX:RAX / r/m64 => quotient in RAX, remainder in RDX,
; so we must save q_out and r_out before using RDX.
;
; Build:
;   nasm -f elf64 Chapter6_Lesson3_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o
; Run:
;   ./ex5 ; exit code = 14 (100/7)

global _start

section .bss
q_out resq 1
r_out resq 1

section .text

divmod_u64:
    mov     r8, rdx        ; save q_out pointer
    mov     r9, rcx        ; save r_out pointer

    mov     rax, rdi       ; numerator
    xor     edx, edx       ; high half = 0 for unsigned division
    div     rsi            ; RAX = quotient, RDX = remainder

    mov     [r8], rax
    mov     [r9], rdx
    ret

_start:
    mov     rdi, 100
    mov     rsi, 7
    lea     rdx, [rel q_out]
    lea     rcx, [rel r_out]
    call    divmod_u64

    mov     edi, eax
    mov     eax, 60
    syscall
