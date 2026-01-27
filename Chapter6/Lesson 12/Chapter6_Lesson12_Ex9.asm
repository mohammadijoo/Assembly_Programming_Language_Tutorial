; Chapter 6 - Lesson 12 (Exercise 1 - Starter)
; Implement powmod(base, exp, mod) using a tail-recursive (loop) strategy.
; Requirements:
;   - SysV AMD64 ABI
;   - Inputs: rdi=base, rsi=exp, rdx=mod
;   - Output: rax = (base^exp) mod mod
; Constraints:
;   - mod > 0
;   - You MUST avoid recursion (constant stack).
; Hint: binary exponentiation with an accumulator.

BITS 64
DEFAULT REL

global _start
section .text

; uint64_t powmod(uint64_t base, uint64_t exp, uint64_t mod)
powmod:
    ; TODO:
    ;   acc = 1
    ;   while exp != 0:
    ;       if (exp & 1) acc = (acc*base) % mod
    ;       base = (base*base) % mod
    ;       exp >>= 1
    ;   return acc
    xor eax, eax
    ret

_start:
    mov rdi, 7              ; base
    mov rsi, 13             ; exp
    mov rdx, 97             ; mod
    call powmod
    mov rdi, rax
    mov rax, 60
    syscall
