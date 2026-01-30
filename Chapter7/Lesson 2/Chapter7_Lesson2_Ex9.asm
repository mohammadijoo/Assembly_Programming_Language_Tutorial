; Chapter7_Lesson2_Ex9.asm
; Chapter 7, Lesson 2 — Programming Exercise 1 (Solution)
; Hard: Implement sum_array(ptr, n) with a disciplined stack frame and ABI rules.
; Prototype: long sum_array(const long* ptr, long n)
;   rdi = ptr, rsi = n, return rax
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter7_Lesson2_Ex9.asm -o ex9.o
;   gcc -no-pie ex9.o -o ex9
; Run:
;   ./ex9

default rel
extern printf
global main

section .rodata
fmt: db "sum_array = %ld", 10, 0

section .data
arr: dq 5, -2, 7, 11, -9, 13, 0, 4

section .text
sum_array:
    push rbp
    mov rbp, rsp
    sub rsp, 32                ; locals + alignment (even though we do not call out)

    ; locals:
    ; [rbp-8]  = i
    ; [rbp-16] = acc (spill slot for demonstration)
    mov qword [rbp-8], 0
    mov qword [rbp-16], 0

.loop:
    mov rax, [rbp-8]
    cmp rax, rsi
    jge .done

    ; load ptr[i]
    mov rdx, rax
    shl rdx, 3                 ; i*8
    mov rcx, [rdi + rdx]
    add qword [rbp-16], rcx

    inc qword [rbp-8]
    jmp .loop

.done:
    mov rax, [rbp-16]
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    lea rdi, [arr]
    mov rsi, 8
    call sum_array

    lea rdi, [fmt]
    mov rsi, rax
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret
