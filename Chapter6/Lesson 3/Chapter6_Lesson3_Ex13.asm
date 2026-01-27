; Chapter6_Lesson3_Ex13.asm
; Programming Exercise 4 (Very Hard): printf with a double (SysV varargs rule).
;
; SysV AMD64 special rule for variadic functions (like printf):
;   AL must contain the number of XMM registers used to pass floating-point args.
;
; Here we call:
;   printf("v=%f\n", v)
; where v is a double in XMM0, so AL=1.
;
; Build:
;   nasm -f elf64 Chapter6_Lesson3_Ex13.asm -o ex13.o
;   gcc -no-pie ex13.o -o ex13
; Run:
;   ./ex13

default rel
global  main
extern  printf

section .rodata
fmt db "v=%f", 10, 0
v   dq 1.2345

section .text
main:
    push    rbp
    mov     rbp, rsp

    lea     rdi, [rel fmt]     ; format string
    movsd   xmm0, [rel v]      ; double argument in XMM0

    mov     eax, 1             ; AL = 1 vector (XMM) argument
    call    printf

    xor     eax, eax
    pop     rbp
    ret
