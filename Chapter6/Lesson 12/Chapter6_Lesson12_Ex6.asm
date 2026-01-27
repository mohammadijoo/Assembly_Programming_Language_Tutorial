; Chapter 6 - Lesson 12 (Example 6)
; A tiny NASM macro to standardize "restore frame + tail jump".
; This is NOT magic: correctness still depends on ABI constraints.

BITS 64
DEFAULT REL

global _start

%macro TAILJMP 1
    leave
    jmp %1
%endmacro

section .text

; h(x) = x + 42
h:
    lea rax, [rdi + 42]
    ret

; k(x): allocate locals, then tail-call h(x*2)
k:
    push rbp
    mov rbp, rsp
    sub rsp, 48

    lea rdi, [rdi + rdi]    ; x*2
    TAILJMP h

_start:
    mov rdi, 11
    call k
    mov rdi, rax
    mov rax, 60
    syscall
