; Chapter 7 - Lesson 3 - Example 8
; A tiny bump allocator inside a static arena (no free)
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex8.asm -o ex8.o
;   gcc -no-pie ex8.o -o ex8
;
; Demonstrates:
;   - Align-up logic
;   - Simple "arena" allocator pattern often used in kernels / embedded / hot paths

default rel
global main
extern printf

%define ARENA_SIZE 4096

section .bss
arena       resb ARENA_SIZE
arena_pos   resq 1             ; current offset (bytes)

section .data
fmt db "allocated %d bytes at %p", 10, 0

section .text
; void* arena_alloc(size_t n, size_t align)
;   RDI = n, RSI = align
; returns RAX = pointer or 0 on OOM
arena_alloc:
    push rbp
    mov  rbp, rsp

    mov  rax, [arena_pos]      ; pos
    ; round_up(pos, align): (pos + (align-1)) & ~(align-1)
    mov  rcx, rsi
    dec  rcx
    add  rax, rcx
    not  rcx
    and  rax, rcx              ; aligned pos

    mov  rdx, rax
    add  rdx, rdi              ; new_pos = aligned_pos + n
    cmp  rdx, ARENA_SIZE
    ja   .oom

    mov  [arena_pos], rdx

    lea  rax, [arena + rax]
    pop  rbp
    ret

.oom:
    xor  rax, rax
    pop  rbp
    ret

main:
    push rbp
    mov  rbp, rsp
    ; allocate 80 bytes with 16-byte alignment
    mov  rdi, 80
    mov  rsi, 16
    call arena_alloc
    test rax, rax
    jz   .fail

    lea  rdi, [fmt]
    mov  esi, 80
    mov  rdx, rax
    xor  eax, eax
    call printf

    xor  eax, eax
    pop  rbp
    ret

.fail:
    mov  eax, 1
    pop  rbp
    ret
