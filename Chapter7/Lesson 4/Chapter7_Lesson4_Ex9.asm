; Chapter 7 - Lesson 4 - Exercise Solution 3
; A guarded allocator: mmap + mprotect to create a guard page.
; Returns pointer just after a 16-byte header:
;   header[0]=base, header[8]=total_bytes (for munmap)
; Guard page is placed after the data region to catch overruns.
; Build (Linux x86-64):
;   nasm -felf64 Chapter7_Lesson4_Ex9.asm -o ex9.o
;   gcc -no-pie ex9.o -o ex9

default rel

global main
extern mmap
extern munmap
extern mprotect
extern getpagesize
extern printf
extern exit

%define PROT_NONE   0
%define PROT_READ   1
%define PROT_WRITE  2
%define MAP_PRIVATE 2
%define MAP_ANON    0x20

section .data
fmt_p   db "ptr=%p  data_bytes=%ld  page=%ld", 10, 0
msg_bad db "guarded_alloc failed", 10, 0

section .text

; size_t round_up(size_t x, size_t a)  (a power-of-two)
; rdi=x, rsi=a -> rax
round_up_pow2:
    mov  rax, rdi
    dec  rsi
    add  rax, rsi
    not  rsi
    and  rax, rsi
    ret

; void* guarded_alloc(size_t nbytes)
; rdi = nbytes -> rax = user_ptr or 0
guarded_alloc:
    push rbp
    mov  rbp, rsp
    sub  rsp, 64

    mov  [rbp-8], rdi            ; save nbytes
    call getpagesize
    mov  [rbp-16], rax           ; page

    ; data = round_up(nbytes + 16, page)
    mov  rdi, [rbp-8]
    add  rdi, 16
    mov  rsi, [rbp-16]
    call round_up_pow2
    mov  [rbp-24], rax           ; data_bytes_rounded

    ; total = data + page (guard)
    mov  rdx, [rbp-24]
    add  rdx, [rbp-16]
    mov  [rbp-32], rdx           ; total

    ; mmap(NULL, total, RW, PRIVATE|ANON, -1, 0)
    xor  edi, edi
    mov  rsi, [rbp-32]
    mov  edx, PROT_READ | PROT_WRITE
    mov  ecx, MAP_PRIVATE | MAP_ANON
    mov  r8,  -1
    xor  r9d, r9d
    call mmap
    cmp  rax, -1
    je   .fail
    mov  [rbp-40], rax           ; base

    ; guard_start = base + data_bytes_rounded
    mov  rdi, [rbp-40]
    add  rdi, [rbp-24]
    mov  rsi, [rbp-16]           ; one page
    mov  edx, PROT_NONE
    call mprotect
    test eax, eax
    jnz  .unmap_fail

    ; write header
    mov  rax, [rbp-40]
    mov  rdx, [rbp-32]
    mov  [rax+0], rax            ; base
    mov  [rax+8], rdx            ; total

    lea  rax, [rax+16]           ; user ptr
    leave
    ret

.unmap_fail:
    mov  rdi, [rbp-40]
    mov  rsi, [rbp-32]
    call munmap
.fail:
    xor  eax, eax
    leave
    ret

; void guarded_free(void* user_ptr)
; rdi=user_ptr
guarded_free:
    test rdi, rdi
    jz   .z
    sub  rdi, 16
    mov  rsi, [rdi+8]            ; total
    ; base is at [rdi+0], which equals rdi itself, but keep general:
    mov  rdi, [rdi+0]            ; base
    jmp  munmap
.z:
    ret

main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 64

    mov  edi, 2000
    call guarded_alloc
    test rax, rax
    jz   .bad

    mov  [rbp-8], rax
    call getpagesize
    mov  [rbp-16], rax

    ; print pointer and sizes
    lea  rdi, [fmt_p]
    mov  rsi, [rbp-8]
    mov  rdx, 2000
    mov  rcx, [rbp-16]
    xor  eax, eax
    call printf

    mov  rdi, [rbp-8]
    call guarded_free

    xor  eax, eax
    leave
    ret

.bad:
    lea  rdi, [msg_bad]
    xor  eax, eax
    call printf
    mov  edi, 1
    call exit
