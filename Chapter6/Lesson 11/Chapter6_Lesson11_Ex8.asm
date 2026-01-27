; Chapter 6 - Lesson 11, Exercise 1 (with solution)
; File: Chapter6_Lesson11_Ex8.asm
; Topic: Leaf strlen using REPNE SCASB, DF discipline (must leave DF=0)
; Build:
;   nasm -felf64 Chapter6_Lesson11_Ex8.asm -o ex8.o
;   ld -o ex8 ex8.o
; Run:
;   ./ex8 ; exit code should be strlen("leaf-fn") = 7

global _start

section .data
s db "leaf-fn", 0

section .text

; size_t strlen_leaf(const char* s)
; Returns length in RAX.
strlen_leaf:
    ; ABI hygiene: ensure DF=0 (it should be already, but don't assume when called from ASM).
    cld

    mov rdi, rdi         ; s pointer already in RDI
    xor eax, eax         ; AL = 0 (terminator)
    mov rcx, -1          ; RCX = 0xFFFFFFFFFFFFFFFF
    repne scasb          ; scan for AL (0), increments RDI, decrements RCX
    not rcx              ; rcx = ~rcx
    dec rcx              ; exclude terminator
    mov rax, rcx
    ret

_start:
    lea rdi, [s]
    call strlen_leaf

    mov edi, eax
    mov eax, 60
    syscall
