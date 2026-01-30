; Chapter 7 - Lesson 3 - Example 13 (Exercise Solution 3)
; A "safe_free" wrapper pattern: free(ptr) and then store NULL back through pointer-to-pointer
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex13.asm -o ex13.o
;   gcc -no-pie ex13.o -o ex13
;
; safe_free(&p):
;   - if p != NULL: free(p)
;   - set p = NULL (prevents accidental double-free / UAF via stale pointer)

default rel
global main
extern malloc
extern free
extern printf

section .data
fmt db "after safe_free: p=%p", 10, 0

section .text
; void safe_free(void **pp)
; RDI = pp
safe_free:
    push rbp
    mov  rbp, rsp

    mov  rsi, rdi              ; save pp
    mov  rax, [rsi]            ; p = *pp
    test rax, rax
    jz   .set_null

    mov  rdi, rax
    call free                  ; stack is 16-byte aligned because of push rbp

.set_null:
    mov  qword [rsi], 0         ; *pp = NULL
    pop  rbp
    ret

main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 32               ; local space, keeps alignment
    ; [rbp-8] = p

    mov  edi, 128
    call malloc
    mov  [rbp-8], rax

    lea  rdi, [rbp-8]
    call safe_free

    lea  rdi, [fmt]
    mov  rsi, [rbp-8]
    xor  eax, eax
    call printf

    xor  eax, eax
    add  rsp, 32
    pop  rbp
    ret
