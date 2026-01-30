; Chapter7_Lesson2_Ex10.asm
; Chapter 7, Lesson 2 — Programming Exercise 2 (Solution)
; Hard: Implement a memcmp-like routine with early exit and a normalized result.
; Prototype: long memcmp_u8(const void* a, const void* b, long n)
; Return: -1 if a is less than b, 0 if equal, +1 if a is greater than b
; (lexicographic by unsigned bytes).
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter7_Lesson2_Ex10.asm -o ex10.o
;   gcc -no-pie ex10.o -o ex10
; Run:
;   ./ex10

default rel
extern printf
global main

section .rodata
fmt: db "memcmp_u8 result = %ld", 10, 0

section .data
a1: db "stackframe", 0
b1: db "stackframes", 0

section .text
memcmp_u8:
    ; rdi=a, rsi=b, rdx=n
    push rbp
    mov rbp, rsp
    sub rsp, 32

    xor rcx, rcx               ; i = 0
.loop:
    cmp rcx, rdx
    jge .equal

    mov al,  [rdi + rcx]
    mov r8b, [rsi + rcx]
    cmp al, r8b
    jne .diff

    inc rcx
    jmp .loop

.diff:
    ; unsigned compare via flags from cmp
    ; if al below r8b => return -1, else return +1
    mov rax, 1
    jb .ret
    mov rax, -1
.ret:
    leave
    ret

.equal:
    xor eax, eax
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    lea rdi, [a1]
    lea rsi, [b1]
    mov rdx, 10                ; compare first 10 bytes
    call memcmp_u8

    lea rdi, [fmt]
    mov rsi, rax
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret
