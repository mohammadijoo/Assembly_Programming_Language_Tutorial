; Chapter 6 - Lesson 12 (Example 8)
; Trampoline for mutual recursion (even/odd) to avoid unbounded stack growth.
; Even/odd are expressed as "steps" that RETURN the next step as a function pointer.
; The trampoline loop calls the current step and continues until termination.

BITS 64
DEFAULT REL

global _start

section .text

; Contract:
;   input : rdi = n
;   output: rax = 1 if even, 0 if odd
;
; trampoline:
;   rbx = current function pointer
;   rdi = current n
trampoline:
    mov rbx, even_step
.loop:
    call rbx                ; step updates (rbx,rdi) via return values
    test rbx, rbx
    jnz .loop
    ret

; even_step(n):
;   if n==0 => done(true)
;   else next = odd_step(n-1)
even_step:
    test rdi, rdi
    jz .even_done
    dec rdi
    mov rbx, odd_step
    ret
.even_done:
    mov eax, 1
    xor ebx, ebx            ; rbx=0 => stop
    ret

; odd_step(n):
;   if n==0 => done(false)
;   else next = even_step(n-1)
odd_step:
    test rdi, rdi
    jz .odd_done
    dec rdi
    mov rbx, even_step
    ret
.odd_done:
    xor eax, eax
    xor ebx, ebx
    ret

_start:
    mov rdi, 99             ; change this for testing
    call trampoline
    mov rdi, rax
    mov rax, 60
    syscall
