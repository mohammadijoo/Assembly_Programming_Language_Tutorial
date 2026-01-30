; Chapter7_Lesson2_Ex4.asm
; Lesson 2 (Chapter 7): Stack Frames and Stack Operations
; Demo: Passing stack arguments beyond the 6 GP registers (SysV AMD64).
; Function sum8(a1..a8): a1..a6 in regs, a7/a8 on stack.
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter7_Lesson2_Ex4.asm -o ex4.o
;   gcc -no-pie ex4.o -o ex4
; Run:
;   ./ex4

default rel
extern printf
global main

section .rodata
fmt: db "sum8 result = %ld", 10, 0

section .text
sum8:
    push rbp
    mov rbp, rsp

    ; args:
    ; rdi,rsi,rdx,rcx,r8,r9
    ; [rbp+16] = arg7, [rbp+24] = arg8
    mov rax, rdi
    add rax, rsi
    add rax, rdx
    add rax, rcx
    add rax, r8
    add rax, r9
    add rax, [rbp+16]
    add rax, [rbp+24]

    pop rbp
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32                ; 16 bytes for args7/8 + 16 bytes padding (keeps alignment)

    ; a1..a6 in registers
    mov rdi, 1
    mov rsi, 2
    mov rdx, 3
    mov rcx, 4
    mov r8,  5
    mov r9,  6

    ; a7/a8 on stack: at callee entry, these become [rbp+16], [rbp+24]
    mov qword [rsp],   7       ; arg7
    mov qword [rsp+8], 8       ; arg8

    call sum8                  ; rax = 1+...+8 = 36

    lea rdi, [fmt]
    mov rsi, rax
    xor eax, eax
    call printf

    xor eax, eax
    add rsp, 32
    pop rbp
    ret
