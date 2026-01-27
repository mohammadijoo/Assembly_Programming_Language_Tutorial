; Chapter 6 - Lesson 11, Example 5
; File: Chapter6_Lesson11_Ex5.asm
; Topic: Classic frame-pointer prologue/epilogue (RBP-based addressing)
; Build:
;   nasm -felf64 Chapter6_Lesson11_Ex5.asm -o ex5.o
;   ld -o ex5 ex5.o
; Run:
;   ./ex5 ; exit code should be factorial(6)=720 mod 256 = 208

%include "Chapter6_Lesson11_Ex1.asm"

global _start

section .text

; uint64_t factorial_fp(uint64_t n)
; - Demonstrates locals accessed via [rbp-offsetof]
factorial_fp:
    ; local layout (example):
    ;   [rbp-8]  = i
    ;   [rbp-16] = acc
    PROLOGUE_FP 16

    mov qword [rbp-8], 1      ; i = 1
    mov qword [rbp-16], 1     ; acc = 1

.loop:
    mov rax, [rbp-8]          ; rax = i
    cmp rax, rdi              ; i ? n
    ja .done

    mov rax, [rbp-16]         ; acc
    imul rax, [rbp-8]         ; acc *= i
    mov [rbp-16], rax

    inc qword [rbp-8]
    jmp .loop

.done:
    mov rax, [rbp-16]
    EPILOGUE_FP 16

_start:
    mov rdi, 6
    call factorial_fp

    mov edi, eax
    mov eax, 60
    syscall
