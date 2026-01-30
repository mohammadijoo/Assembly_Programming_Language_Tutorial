; Chapter7_Lesson2_Ex6.asm
; Lesson 2 (Chapter 7): Stack Frames and Stack Operations
; Demo: Dynamic stack allocation (alloca-style) with 16-byte alignment.
;
; alloc_demo(requested):
;   - rounds requested up to a multiple of 16
;   - subtracts that amount from RSP (dynamic local area)
;   - prints requested, aligned size, and the buffer address
;   - restores RSP before returning
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter7_Lesson2_Ex6.asm -o ex6.o
;   gcc -no-pie ex6.o -o ex6
; Run:
;   ./ex6

default rel
extern printf
global main

section .rodata
fmt: db "Requested=%ld bytes, aligned=%ld bytes, buffer=%p", 10, 0

section .text
alloc_demo:
    ; rdi = requested bytes
    push rbp
    mov rbp, rsp
    sub rsp, 32                ; fixed locals, keeps alignment

    mov [rbp-16], rdi          ; save requested
    mov [rbp-8],  rsp          ; save base rsp (after fixed locals)

    mov rax, rdi
    add rax, 15
    and rax, -16               ; rax = align16(requested)
    mov [rbp-24], rax

    sub rsp, rax               ; dynamic allocation (multiple of 16 keeps alignment)

    lea rdi, [fmt]
    mov rsi, [rbp-16]          ; requested
    mov rdx, [rbp-24]          ; aligned
    mov rcx, rsp               ; buffer
    xor eax, eax
    call printf

    mov rsp, [rbp-8]           ; restore base rsp (undo dynamic alloc)
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov rdi, 37
    call alloc_demo

    xor eax, eax
    leave
    ret
