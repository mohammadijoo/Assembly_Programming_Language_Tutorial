; Chapter 6 - Lesson 11, Example 3
; File: Chapter6_Lesson11_Ex3.asm
; Topic: Leaf function using the SysV red zone (no RSP adjustment)
; Build:
;   nasm -felf64 Chapter6_Lesson11_Ex3.asm -o ex3.o
;   ld -o ex3 ex3.o
; Run:
;   ./ex3 ; exit code should be ((7*9)+5)=68

global _start

section .text

; int64_t mul_add_redzone(int64_t x, int64_t y, int64_t z)
; returns x*y + z
mul_add_redzone:
    ; Red zone is memory below RSP that we can use without sub rsp, ...
    ; We'll store an intermediate there: [rsp-8].
    mov rax, rdi
    imul rax, rsi
    mov [rsp-8], rax       ; temporary in red zone
    mov rax, [rsp-8]
    add rax, rdx
    ret

_start:
    mov rdi, 7
    mov rsi, 9
    mov rdx, 5
    call mul_add_redzone

    mov edi, eax
    mov eax, 60
    syscall
