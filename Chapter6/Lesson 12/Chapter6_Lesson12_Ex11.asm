; Chapter 6 - Lesson 12 (Exercise 2 - Starter)
; Build a trampoline-based even/odd checker WITHOUT mutual CALL recursion.
; Requirements:
;   - Input : rdi = n
;   - Output: rax = 1 if even else 0
;   - Use a trampoline loop that repeatedly invokes "step" functions.
;   - Each step should set the next step (function pointer) and update n.
;   - Terminate by setting next pointer to 0.

BITS 64
DEFAULT REL

global _start
section .text

trampoline:
    ; TODO: set initial step and loop
    xor eax, eax
    ret

even_step:
    ; TODO
    ret

odd_step:
    ; TODO
    ret

_start:
    mov rdi, 100
    call trampoline
    mov rdi, rax
    mov rax, 60
    syscall
