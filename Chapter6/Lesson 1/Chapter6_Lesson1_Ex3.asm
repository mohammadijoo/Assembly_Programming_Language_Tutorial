; Chapter6_Lesson1_Ex3.asm
; Callee-saved register discipline: using RBX inside a procedure.
; SysV AMD64: RBX is non-volatile (callee-saved). If you modify it, restore it.
;
; Build:
;   nasm -felf64 Chapter6_Lesson1_Ex3.asm -o ex3.o
;   ld ex3.o -o ex3

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

; uint64_t sum3(uint64_t x, uint64_t y, uint64_t z)
; args: RDI, RSI, RDX ; return RAX
sum3:
    push rbx                 ; preserve callee-saved register we will clobber
    mov rbx, rdi             ; temp = x
    add rbx, rsi             ; temp += y
    add rbx, rdx             ; temp += z
    mov rax, rbx
    pop rbx
    ret

_start:
    mov rdi, 10
    mov rsi, 20
    mov rdx, 30
    call sum3                ; rax = 60
    mov edi, eax
    mov eax, 60
    syscall
