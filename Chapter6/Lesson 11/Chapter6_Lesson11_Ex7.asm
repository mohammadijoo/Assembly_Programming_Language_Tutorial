; Chapter 6 - Lesson 11, Example 7
; File: Chapter6_Lesson11_Ex7.asm
; Topic: Callee-saved discipline integrated with a prologue/epilogue
; Build:
;   nasm -felf64 Chapter6_Lesson11_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o
; Run:
;   ./ex7 ; exit code should be sum([10,20,30,40])=100

%include "Chapter6_Lesson11_Ex1.asm"

global _start

section .data
arr dq 10, 20, 30, 40

section .text

; uint64_t sum_array_rbx(const uint64_t* p, uint64_t n)
; Uses RBX as a loop pointer (callee-saved), so we must preserve it.
sum_array_rbx:
    push rbx
    xor rax, rax
    mov rbx, rdi         ; rbx = p
    mov rcx, rsi         ; rcx = n (caller-saved, ok)

.loop:
    test rcx, rcx
    jz .done
    add rax, [rbx]
    add rbx, 8
    dec rcx
    jmp .loop

.done:
    pop rbx
    ret

_start:
    lea rdi, [arr]
    mov rsi, 4
    call sum_array_rbx

    mov edi, eax
    mov eax, 60
    syscall
