; Chapter 6 - Lesson 6 (Calling Conventions Overview)
; Example 2: SysV AMD64 - pointer arguments, callee-saved discipline (Linux ELF64)
; Build (Linux):
;   nasm -felf64 Chapter6_Lesson6_Ex2.asm -o ex2.o
;   ld -o ex2 ex2.o
; Run:
;   ./ex2 ; exit status 0 means swap succeeded

BITS 64
DEFAULT REL
GLOBAL _start

SECTION .data
a dq 1
b dq 2

SECTION .text

; void swap_u64(uint64* p, uint64* q)
; SysV AMD64: p=RDI, q=RSI
swap_u64:
    push rbx                ; RBX is callee-saved in SysV
    mov rbx, [rdi]
    mov rax, [rsi]
    mov [rdi], rax
    mov [rsi], rbx
    pop rbx
    ret

_start:
    lea rdi, [a]
    lea rsi, [b]
    call swap_u64

    mov rax, [a]
    cmp rax, 2
    jne .bad
    mov rax, [b]
    cmp rax, 1
    jne .bad
    xor edi, edi
    jmp .done

.bad:
    mov edi, 1

.done:
    mov eax, 60
    syscall
