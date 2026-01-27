; Chapter6_Lesson3_Ex2.asm
; Example 2 (SysV AMD64 / Linux): first 6 integer args in registers,
; additional args on the stack.
;
; Signature:
;   int64 sum8(int64 a1,a2,a3,a4,a5,a6,a7,a8)
; SysV: a1..a6 in RDI,RSI,RDX,RCX,R8,R9 ; a7,a8 on stack.
;
; Build:
;   nasm -f elf64 Chapter6_Lesson3_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o
; Run:
;   ./ex2 ; exit code = 36

global _start

section .text

sum8:
    push    rbp
    mov     rbp, rsp

    mov     rax, rdi
    add     rax, rsi
    add     rax, rdx
    add     rax, rcx
    add     rax, r8
    add     rax, r9

    ; Stack args with frame pointer:
    ; [rbp+16] = a7, [rbp+24] = a8
    add     rax, [rbp + 16]
    add     rax, [rbp + 24]

    pop     rbp
    ret

_start:
    mov     edi, 1
    mov     esi, 2
    mov     edx, 3
    mov     ecx, 4
    mov     r8d, 5
    mov     r9d, 6

    ; Push stack args right-to-left so a7 is closest to return address.
    push    8
    push    7
    call    sum8
    add     rsp, 16

    mov     edi, eax
    mov     eax, 60
    syscall
