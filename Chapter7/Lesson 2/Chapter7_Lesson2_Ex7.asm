; Chapter7_Lesson2_Ex7.asm
; Lesson 2 (Chapter 7): Stack Frames and Stack Operations
; Demo: The SysV AMD64 red zone (128 bytes below RSP) for leaf functions.
; This leaf function uses [rsp-..] without changing RSP.
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter7_Lesson2_Ex7.asm -o ex7.o
;   gcc -no-pie ex7.o -o ex7
; Run:
;   ./ex7

default rel
extern printf
global main

section .rodata
fmt: db "leaf_add3 result = %ld", 10, 0

section .text
leaf_add3:
    ; rdi,rsi,rdx are inputs
    ; Use red-zone slots as scratch (do not write above rsp).
    mov [rsp-8],  rdi
    mov [rsp-16], rsi
    mov [rsp-24], rdx

    mov rax, [rsp-8]
    add rax, [rsp-16]
    add rax, [rsp-24]
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov rdi, 10
    mov rsi, 20
    mov rdx, 30
    call leaf_add3              ; rax = 60

    lea rdi, [fmt]
    mov rsi, rax
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret
