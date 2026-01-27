; Chapter 6 - Lesson 12 (Example 2)
; Tail recursion eliminated by hand: factorial with accumulator and a loop.

BITS 64
DEFAULT REL

global _start

section .text

; uint64_t fact_tail(uint64_t n, uint64_t acc)
;   input : rdi = n, rsi = acc
;   output: rax = n! * acc
fact_tail:
.loop:
    cmp rdi, 1
    jbe .done
    imul rsi, rdi           ; acc *= n
    dec rdi                 ; n--
    jmp .loop               ; explicit tail-call elimination
.done:
    mov rax, rsi
    ret

_start:
    mov rdi, 10             ; n
    mov rsi, 1              ; acc
    call fact_tail
    mov rdi, rax
    mov rax, 60
    syscall
