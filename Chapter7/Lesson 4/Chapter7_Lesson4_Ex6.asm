; Chapter 7 - Lesson 4 - Example 6
; A tiny arena (bump) allocator backed by mmap.
; The arena supports fast allocate and a single "reset" (no per-block free).
; Build (Linux x86-64):
;   nasm -felf64 Chapter7_Lesson4_Ex6.asm -o ex6.o
;   gcc -no-pie ex6.o -o ex6

default rel

global main
extern mmap
extern munmap
extern printf
extern exit

%define PROT_READ   1
%define PROT_WRITE  2
%define MAP_PRIVATE 2
%define MAP_ANON    0x20

; arena layout (in memory):
;   [0]  base (qword)
;   [8]  size (qword)
;   [16] off  (qword)

section .data
fmt_blk db "alloc(%ld, align=%ld) -> %p", 10, 0
msg_bad db "arena init failed", 10, 0

section .text

; rdi = arena*, rsi = alignment (power-of-two), rdx = bytes
; returns rax = pointer or 0
arena_alloc:
    push rbp
    mov  rbp, rsp
    sub  rsp, 32

    mov  r8,  [rdi+0]       ; base
    mov  r9,  [rdi+8]       ; size
    mov  r10, [rdi+16]      ; off

    ; aligned_off = (off + (align-1)) & ~(align-1)
    mov  r11, rsi
    dec  r11                ; align-1
    mov  rax, r10
    add  rax, r11
    not  r11
    and  rax, r11           ; aligned_off

    ; if aligned_off + bytes > size -> fail
    mov  rcx, rax
    add  rcx, rdx
    cmp  rcx, r9
    ja   .fail

    lea  rax, [r8 + rax]    ; ptr = base + aligned_off
    mov  [rdi+16], rcx      ; off = aligned_off + bytes
    leave
    ret

.fail:
    xor  eax, eax
    leave
    ret

main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 80

    ; arena struct on stack at [rbp-48 .. rbp-25]
    ; mmap 64 KiB for arena backing
    xor  edi, edi
    mov  esi, 65536
    mov  edx, PROT_READ | PROT_WRITE
    mov  ecx, MAP_PRIVATE | MAP_ANON
    mov  r8,  -1
    xor  r9d, r9d
    call mmap
    cmp  rax, -1
    je   .bad

    ; store arena.base, arena.size, arena.off
    lea  rdi, [rbp-48]
    mov  [rdi+0], rax
    mov  qword [rdi+8], 65536
    mov  qword [rdi+16], 0

    ; allocate three blocks with different alignments/sizes
    ; 1) alloc(24, align=16)
    lea  rdi, [rbp-48]
    mov  esi, 16
    mov  edx, 24
    call arena_alloc
    mov  [rbp-8], rax

    lea  rdi, [fmt_blk]
    mov  rsi, 24
    mov  rdx, 16
    mov  rcx, [rbp-8]
    xor  eax, eax
    call printf

    ; 2) alloc(128, align=64)
    lea  rdi, [rbp-48]
    mov  esi, 64
    mov  edx, 128
    call arena_alloc
    mov  [rbp-16], rax

    lea  rdi, [fmt_blk]
    mov  rsi, 128
    mov  rdx, 64
    mov  rcx, [rbp-16]
    xor  eax, eax
    call printf

    ; 3) alloc(7, align=8)
    lea  rdi, [rbp-48]
    mov  esi, 8
    mov  edx, 7
    call arena_alloc
    mov  [rbp-24], rax

    lea  rdi, [fmt_blk]
    mov  rsi, 7
    mov  rdx, 8
    mov  rcx, [rbp-24]
    xor  eax, eax
    call printf

    ; munmap(arena.base, arena.size)
    lea  rdi, [rbp-48]
    mov  rdi, [rdi+0]
    mov  esi, 65536
    call munmap

    xor  eax, eax
    leave
    ret

.bad:
    lea  rdi, [msg_bad]
    xor  eax, eax
    call printf
    mov  edi, 1
    call exit
