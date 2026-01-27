; Chapter 6 - Lesson 11, Example 4
; File: Chapter6_Lesson11_Ex4.asm
; Topic: Non-leaf function: stack alignment before CALL
; Build:
;   nasm -felf64 Chapter6_Lesson11_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o
; Run:
;   ./ex4 ; exit code should be ((3+4)*10)=70

%include "Chapter6_Lesson11_Ex1.asm"

global _start

section .text

; int64_t scale_i64(int64_t x, int64_t k)  => x*k
scale_i64:
    mov rax, rdi
    imul rax, rsi
    ret

; int64_t sum_and_scale(int64_t a, int64_t b, int64_t k) => (a+b)*k
; This is a NON-LEAF function because it calls scale_i64.
sum_and_scale:
    ; On entry: RSP % 16 == 8.
    ; We must align before CALL: subtract 8 so (RSP % 16 == 0).
    ALIGN_BEFORE_CALL

    lea rdi, [rdi + rsi]   ; rdi = a+b
    mov rsi, rdx           ; rsi = k
    call scale_i64

    UNALIGN_AFTER_CALL
    ret

_start:
    mov rdi, 3
    mov rsi, 4
    mov rdx, 10
    call sum_and_scale

    mov edi, eax
    mov eax, 60
    syscall
