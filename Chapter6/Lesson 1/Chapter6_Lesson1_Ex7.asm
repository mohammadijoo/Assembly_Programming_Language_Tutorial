; Chapter6_Lesson1_Ex7.asm
; Recursion as "self-calls": factorial(n) with a stack frame.
; Demonstrates:
;   - base case
;   - saving a value across recursive call
;   - call depth consumes stack
;
; Build:
;   nasm -felf64 Chapter6_Lesson1_Ex7.asm -o ex7.o
;   ld ex7.o -o ex7
; Run:
;   ./ex7 ; echo $?  (factorial(7)=5040 -> exit code 5040 mod 256 = 176)

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

; uint64_t fact(uint64_t n)  (n in RDI)
fact:
    push rbp
    mov rbp, rsp

    cmp rdi, 1
    jbe .base

    push rdi                  ; save n on stack
    dec rdi                   ; n-1
    call fact                 ; rax = fact(n-1)
    pop rcx                   ; rcx = original n
    imul rax, rcx             ; rax *= n
    jmp .done

.base:
    mov rax, 1

.done:
    leave
    ret

_start:
    mov rdi, 7
    call fact
    mov edi, eax
    mov eax, 60
    syscall
