; Chapter7_Lesson9_Ex11.asm
; Programming Exercise Solution:
; Implement aligned_malloc64 / aligned_free64 on top of malloc/free by over-allocation.
; Technique:
;   raw = malloc(size + 64 + 8)
;   aligned = align_up(raw + 8, 64)
;   store raw at [aligned-8]
;   return aligned
; Build:
;   nasm -felf64 Chapter7_Lesson9_Ex11.asm -o ex11.o
;   gcc ex11.o -o ex11
; Run:
;   ./ex11

default rel
global main
extern malloc
extern free
extern printf

section .rodata
fmt: db "aligned=%p  (aligned & 63)=%llu", 10, 0

section .text
aligned_malloc64:
    ; rdi = size
    push rbx                      ; keep stack 16-aligned for malloc call
    mov rbx, rdi

    add rdi, 64 + 8               ; extra for alignment + hidden raw pointer
    call malloc
    test rax, rax
    jz .fail

    mov rcx, rax                  ; raw
    add rcx, 8
    add rcx, 63
    and rcx, -64                  ; aligned

    mov [rcx-8], rax              ; stash raw pointer
    mov rax, rcx                  ; return aligned

    pop rbx
    ret

.fail:
    xor eax, eax
    pop rbx
    ret

aligned_free64:
    ; rdi = aligned ptr
    test rdi, rdi
    jz .ret

    push rbp                      ; align before calling free
    mov rbp, rsp

    mov rdi, [rdi-8]              ; load raw
    call free

    leave
.ret:
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov edi, 1000
    call aligned_malloc64
    mov r12, rax

    mov r13, r12
    and r13, 63

    lea rdi, [fmt]
    mov rsi, r12
    mov rdx, r13
    xor eax, eax
    call printf

    mov rdi, r12
    call aligned_free64

    xor eax, eax
    leave
    ret
