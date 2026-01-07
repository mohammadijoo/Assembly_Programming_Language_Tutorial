; Chapter2_Lesson9_Ex15.asm
; Programming Exercise Solution 4: rotate three qwords in memory with minimal temporaries.
; Goal: (a,b,c) -> (c,a,b)
; Method: rax holds a, then xchg with b, then xchg with c, then store to a.
;
; Build:
;   nasm -felf64 Chapter2_Lesson9_Ex15.asm -o ex15.o
;   ld -o ex15 ex15.o
;
; Expected run result (exit status): 3

default rel
global _start

section .data
a dq 1
b dq 2
c dq 3

section .text
rotate3:
    ; rdi=&a, rsi=&b, rdx=&c
    mov rax, [rdi]       ; rax = a
    xchg rax, [rsi]      ; rax = b, [b] = a
    xchg rax, [rdx]      ; rax = c, [c] = b
    mov [rdi], rax       ; [a] = c
    ret

_start:
    lea rdi, [a]
    lea rsi, [b]
    lea rdx, [c]
    call rotate3

    ; Exit with new a (expected 3).
    mov eax, 60
    mov edi, dword [a]
    syscall
