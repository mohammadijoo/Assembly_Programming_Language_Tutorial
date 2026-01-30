; Chapter 7 - Lesson 3 - Example 10
; Heap buffer interop with libc functions (strlen, memcpy)
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex10.asm -o ex10.o
;   gcc -no-pie ex10.o -o ex10

default rel
global main
extern malloc
extern free
extern strlen
extern memcpy
extern printf

section .data
src db "dynamic interop", 0
fmt db "copied string='%s' (len=%d)", 10, 0

section .text
main:
    push rbp
    mov  rbp, rsp
    push rbx
    push r12

    ; len = strlen(src)
    lea  rdi, [src]
    call strlen
    mov  ebx, eax               ; EBX holds len

    ; allocate len+1
    lea  edi, [rbx+1]
    call malloc
    test rax, rax
    jz   .fail
    mov  r12, rax               ; use R12 (callee-saved)

    ; memcpy(dst, src, len+1)
    mov  rdi, r12
    lea  rsi, [src]
    lea  rdx, [rbx+1]
    call memcpy

    lea  rdi, [fmt]
    mov  rsi, r12
    mov  edx, ebx
    xor  eax, eax
    call printf

    mov  rdi, r12
    call free

    xor  eax, eax
    pop  r12
    pop  rbx
    pop  rbp
    ret

.fail:
    mov  eax, 1
    pop  r12
    pop  rbx
    pop  rbp
    ret
