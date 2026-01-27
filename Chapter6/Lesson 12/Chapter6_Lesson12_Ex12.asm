; Chapter 6 - Lesson 12 (Exercise 2 - Solution)
; Trampoline-based even/odd checker (constant stack).

BITS 64
DEFAULT REL

global _start
section .text

; rdi = n
; returns rax = 1 if even else 0
trampoline:
    mov rbx, even_step
.loop:
    call rbx
    test rbx, rbx
    jnz .loop
    ret

even_step:
    test rdi, rdi
    jz .even_done
    dec rdi
    mov rbx, odd_step
    ret
.even_done:
    mov eax, 1
    xor ebx, ebx
    ret

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
    mov rdi, 100
    call trampoline
    mov rdi, rax
    mov rax, 60
    syscall
