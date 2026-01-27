; Chapter6_Lesson3_Ex7.asm
; Example 7 (SysV AMD64): calling an external function (printf) and
; respecting register argument passing + stack alignment at call boundary.
;
; Key rule (SysV AMD64): before CALL, RSP must be 16-byte aligned.
; When main is entered by the C runtime, RSP is typically 8 (mod 16),
; so a standard "push rbp" makes it aligned (0 mod 16).
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter6_Lesson3_Ex7.asm -o ex7.o
;   gcc -no-pie ex7.o -o ex7
; Run:
;   ./ex7

default rel
global  main
extern  printf

section .rodata
fmt db "a=%ld b=%ld c=%ld", 10, 0

section .text
main:
    push    rbp
    mov     rbp, rsp

    lea     rdi, [rel fmt]  ; 1st arg: format string
    mov     esi, 7          ; 2nd arg: a (in RSI)
    mov     edx, 11         ; 3rd arg: b (in RDX)
    mov     ecx, 13         ; 4th arg: c (in RCX)

    xor     eax, eax        ; SysV varargs: AL = number of XMM regs used (0 here)
    call    printf

    xor     eax, eax
    pop     rbp
    ret
