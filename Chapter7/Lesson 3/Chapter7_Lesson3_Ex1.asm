; Chapter 7 - Lesson 3 - Example 1
; Dynamic Memory Allocation in Assembly (malloc/free) — Linux x86-64 SysV, NASM
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex1.asm -o ex1.o
;   gcc -no-pie ex1.o -o ex1
;
; Demonstrates:
;   - Calling malloc(size) and free(ptr)
;   - Filling a heap buffer and printing it with printf
;   - Stack alignment + callee-saved register discipline

default rel
global main
extern malloc
extern free
extern printf

section .data
fmt db "buffer: %s", 10, 0

section .text
main:
    ; SysV AMD64: at entry, RSP mod 16 == 8. Make it 16-byte aligned before calls.
    push rbp
    mov  rbp, rsp
    push rbx
    sub  rsp, 8                ; align to 16

    mov  edi, 64               ; size_t size = 64
    call malloc
    test rax, rax
    jz   .alloc_failed

    mov  rbx, rax              ; save pointer (RBX is callee-saved, so we restore later)

    ; Fill first 63 bytes with 'A'
    lea  rdi, [rbx]
    mov  ecx, 63
    mov  al, 'A'
    rep  stosb
    mov  byte [rbx+63], 0      ; null terminator

    lea  rdi, [fmt]
    mov  rsi, rbx
    xor  eax, eax              ; required for SysV varargs
    call printf

    mov  rdi, rbx
    call free

    xor  eax, eax              ; return 0
    add  rsp, 8
    pop  rbx
    pop  rbp
    ret

.alloc_failed:
    mov  eax, 1                ; nonzero exit code
    add  rsp, 8
    pop  rbx
    pop  rbp
    ret
