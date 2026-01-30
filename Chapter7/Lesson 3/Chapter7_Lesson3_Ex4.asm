; Chapter 7 - Lesson 3 - Example 4
; Allocation failure + errno-aware reporting via perror
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex4.asm -o ex4.o
;   gcc -no-pie ex4.o -o ex4

default rel
global main
extern malloc
extern free
extern perror

section .data
tag db "malloc failed", 0

section .text
main:
    push rbp
    mov  rbp, rsp
    mov  rdi, -1               ; request an absurdly large size_t to force failure
    call malloc
    test rax, rax
    jnz  .ok

    lea  rdi, [tag]
    call perror                ; prints tag + strerror(errno) to stderr
    mov  eax, 1
    pop  rbp
    ret

.ok:
    ; If it unexpectedly succeeds, free it.
    mov  rdi, rax
    call free
    xor  eax, eax
    pop  rbp
    ret
