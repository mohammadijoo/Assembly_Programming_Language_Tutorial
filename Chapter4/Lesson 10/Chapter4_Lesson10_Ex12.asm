bits 64
default rel

; Exercise 3 (solution):
; Given a struct size 24 and field offset 8, compute &arr[i].field without IMUL.
; 24*i = (3*i)*8.

global _start

struc REC
    .a      resq 1   ; offset 0
    .b      resq 1   ; offset 8   <-- field of interest
    .c      resq 1   ; offset 16
endstruc

section .data
recs:
    dq 1,  10, 100
    dq 2,  20, 200
    dq 3,  30, 300
    dq 4,  40, 400

section .text
addr_of_b:
    ; rdi = base
    ; esi = i (32-bit index)
    ; returns rax = &base[i].b
    lea eax, [esi + esi*2]         ; 3*i
    lea rax, [rdi + rax*8 + REC.b] ; base + (3*i)*8 + offset(b)
    ret

_start:
    lea rdi, [rel recs]
    mov esi, 3                      ; i = 3 (fourth record)
    call addr_of_b
    mov rbx, rax
    mov rax, [rbx]                  ; should load 40

    mov eax, 60
    mov edi, 40
    syscall
