; Chapter7_Lesson9_Ex12.asm
; Programming Exercise Solution:
; Implement my_calloc(nmemb, size) in NASM on top of malloc + memset-like loop.
; Requirements:
;   - detect overflow of nmemb*size
;   - zero the allocation
; Build:
;   nasm -felf64 Chapter7_Lesson9_Ex12.asm -o ex12.o
;   gcc ex12.o -o ex12
; Run:
;   ./ex12

default rel
global main
extern malloc
extern free
extern printf

section .rodata
fmt: db "calloc ptr=%p total=%llu first_qword=%#llx", 10, 0

section .text
my_calloc:
    ; rdi = nmemb, rsi = size
    ; rax = ptr or 0
    push rbx                      ; keep alignment for malloc call
    mov rbx, rdi                  ; nmemb

    mov rax, rdi
    mul rsi                       ; rdx:rax = nmemb * size
    test rdx, rdx
    jnz .overflow                 ; overflow if high part non-zero

    mov r12, rax                  ; total
    mov rdi, r12
    call malloc
    test rax, rax
    jz .overflow

    ; zero memory: use rep stosq then tail bytes
    mov r13, rax                  ; ptr
    xor eax, eax
    mov rdi, r13                  ; dest
    mov rcx, r12
    shr rcx, 3                    ; qwords
    cld
    rep stosq

    ; remaining bytes
    mov rcx, r12
    and rcx, 7
    rep stosb

    mov rax, r13
    pop rbx
    ret

.overflow:
    xor eax, eax
    pop rbx
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 64

    mov edi, 40                   ; nmemb
    mov esi, 8                    ; size
    call my_calloc
    mov r12, rax

    ; read first qword (should be 0)
    xor r13, r13
    test r12, r12
    jz .print
    mov r13, [r12]

.print:
    lea rdi, [fmt]
    mov rsi, r12
    mov rdx, 320                  ; 40*8
    mov rcx, r13
    xor eax, eax
    call printf

    mov rdi, r12
    call free

    xor eax, eax
    leave
    ret
