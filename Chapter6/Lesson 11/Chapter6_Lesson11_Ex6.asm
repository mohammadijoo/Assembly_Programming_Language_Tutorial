; Chapter 6 - Lesson 11, Example 6
; File: Chapter6_Lesson11_Ex6.asm
; Topic: Omit frame pointer (RSP-relative locals), careful with offsets
; Build:
;   nasm -felf64 Chapter6_Lesson11_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o
; Run:
;   ./ex6 ; exit code should be factorial(6)=720 mod 256 = 208

%include "Chapter6_Lesson11_Ex1.asm"

global _start

section .text

; uint64_t factorial_nofp(uint64_t n)
; locals after PROLOGUE_NOFP 16:
;   [rsp+0]  = i
;   [rsp+8]  = acc
factorial_nofp:
    PROLOGUE_NOFP 16

    mov qword [rsp+0], 1      ; i = 1
    mov qword [rsp+8], 1      ; acc = 1

.loop:
    mov rax, [rsp+0]          ; i
    cmp rax, rdi
    ja .done

    mov rax, [rsp+8]          ; acc
    imul rax, [rsp+0]         ; acc *= i
    mov [rsp+8], rax

    inc qword [rsp+0]
    jmp .loop

.done:
    mov rax, [rsp+8]
    EPILOGUE_NOFP 16

_start:
    mov rdi, 6
    call factorial_nofp

    mov edi, eax
    mov eax, 60
    syscall
