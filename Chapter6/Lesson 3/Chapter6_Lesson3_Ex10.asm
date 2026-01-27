; Chapter6_Lesson3_Ex10.asm
; Programming Exercise 1 (Hard): sum10 on SysV AMD64 (10 parameters).
;
; Signature:
;   int64 sum10(int64 a1..a10)
; a1..a6 in regs, a7..a10 on stack.
;
; Build:
;   nasm -f elf64 Chapter6_Lesson3_Ex10.asm -o ex10.o
;   ld -o ex10 ex10.o
; Run:
;   ./ex10 ; exit code = 55

global _start

section .text

sum10:
    push    rbp
    mov     rbp, rsp

    mov     rax, rdi
    add     rax, rsi
    add     rax, rdx
    add     rax, rcx
    add     rax, r8
    add     rax, r9

    add     rax, [rbp + 16]  ; a7
    add     rax, [rbp + 24]  ; a8
    add     rax, [rbp + 32]  ; a9
    add     rax, [rbp + 40]  ; a10

    pop     rbp
    ret

_start:
    mov     edi, 1
    mov     esi, 2
    mov     edx, 3
    mov     ecx, 4
    mov     r8d, 5
    mov     r9d, 6

    push    10
    push    9
    push    8
    push    7
    call    sum10
    add     rsp, 32

    mov     edi, eax
    mov     eax, 60
    syscall
