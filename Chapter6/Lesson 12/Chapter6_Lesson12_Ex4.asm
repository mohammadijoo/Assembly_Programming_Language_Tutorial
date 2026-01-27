; Chapter 6 - Lesson 12 (Example 4)
; Sibling tail call: f(n) does local work, then tail-calls g(n-1).
; Key idea: restore our stack frame, then JMP (not CALL) into g.

BITS 64
DEFAULT REL

global _start

section .text

; uint64_t g(uint64_t x) = 3*x + 7
g:
    lea rax, [rdi + 2*rdi]  ; 3*x
    add rax, 7
    ret

; uint64_t f(uint64_t n)
; if n<=1 return 0; else return g(n-1)  (tail position)
f:
    push rbp
    mov rbp, rsp
    sub rsp, 32             ; pretend we have locals (for demo)

    cmp rdi, 1
    jbe .ret0

    lea rdi, [rdi - 1]      ; argument for g
    leave                   ; undo locals + pop rbp
    jmp g                   ; sibling tail call

.ret0:
    xor eax, eax
    leave
    ret

_start:
    mov rdi, 10
    call f
    mov rdi, rax
    mov rax, 60
    syscall
