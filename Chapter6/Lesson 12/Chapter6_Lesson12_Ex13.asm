; Chapter 6 - Lesson 12 (Exercise 3 - Starter)
; Tail-call with 8 integer arguments using ONLY caller-provided stack arg slots.
; Implement:
;   f8_affine(a1..a8) tail-calls g8_sum( a1*3+5, a2..a8 )
; Requirements:
;   - SysV AMD64 ABI
;   - No pushing new stack args in f8_affine
;   - g8_sum must read a7 and a8 from [rsp+8] and [rsp+16]
;
; Write a minimal _start that passes 8 args and exits with result.

BITS 64
DEFAULT REL

global _start

section .text

g8_sum:
    ; TODO: sum 8 args and return in rax
    xor eax, eax
    ret

f8_affine:
    ; TODO: a1 = a1*3 + 5 then tail-jump to g8_sum
    ret

_start:
    ; TODO: provide 8 args (a7/a8 on stack), call f8_affine, clean stack, exit
    mov rax, 60
    xor rdi, rdi
    syscall
