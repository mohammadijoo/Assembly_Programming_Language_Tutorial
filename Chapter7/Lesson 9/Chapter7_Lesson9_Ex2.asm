; Chapter7_Lesson9_Ex2.asm
; Observe reuse patterns: free a block then allocate same size again.
; Note: exact reuse depends on allocator/version, but reuse is common.
; Build:
;   nasm -felf64 Chapter7_Lesson9_Ex2.asm -o ex2.o
;   gcc ex2.o -o ex2
; Run:
;   ./ex2

default rel
global main
extern malloc
extern free
extern printf

section .rodata
fmt_ptr: db "p%d = %p", 10, 0

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 64

    ; p1 = malloc(64)
    mov edi, 64
    call malloc
    mov [rbp-8], rax

    ; p2 = malloc(64)
    mov edi, 64
    call malloc
    mov [rbp-16], rax

    ; p3 = malloc(64)
    mov edi, 64
    call malloc
    mov [rbp-24], rax

    ; print p1, p2, p3
    mov edi, 1
    mov rsi, [rbp-8]
    lea rdi, [fmt_ptr]
    xor eax, eax
    call printf

    mov edi, 2
    mov rsi, [rbp-16]
    lea rdi, [fmt_ptr]
    xor eax, eax
    call printf

    mov edi, 3
    mov rsi, [rbp-24]
    lea rdi, [fmt_ptr]
    xor eax, eax
    call printf

    ; free(p2)
    mov rdi, [rbp-16]
    call free

    ; p4 = malloc(64)
    mov edi, 64
    call malloc
    mov [rbp-32], rax

    ; print p4
    mov edi, 4
    mov rsi, [rbp-32]
    lea rdi, [fmt_ptr]
    xor eax, eax
    call printf

    ; cleanup remaining blocks
    mov rdi, [rbp-8]
    call free
    mov rdi, [rbp-24]
    call free
    mov rdi, [rbp-32]
    call free

    xor eax, eax
    leave
    ret
