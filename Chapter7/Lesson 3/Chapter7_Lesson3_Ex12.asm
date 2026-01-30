; Chapter 7 - Lesson 3 - Example 12 (Exercise Solution 2)
; mmap-based allocator that returns 64-byte aligned payload and stores a small header
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex12.asm -o ex12.o
;   ld -o ex12 ex12.o
;
; Contract:
;   aligned_alloc64(size) -> RAX = aligned payload pointer, or 0 on failure
;   aligned_free64(ptr)   -> unmaps the region using header stored just before ptr
;
; Header layout (16 bytes, stored immediately before aligned payload):
;   [ptr-16] = mapping_base (original mmap return)
;   [ptr-8 ] = mapping_len  (length passed to munmap)

default rel
global _start

%define SYS_mmap    9
%define SYS_munmap 11
%define SYS_write   1
%define SYS_exit   60

%define PROT_READ   1
%define PROT_WRITE  2
%define MAP_PRIVATE 2
%define MAP_ANON    0x20

section .data
ok  db "aligned mmap alloc/free completed.", 10
ok_len equ $-ok
bad db "allocation failed.", 10
bad_len equ $-bad

section .text
; uint64_t round_up64(uint64_t x, uint64_t a)
round_up64:
    ; RDI=x, RSI=a
    mov  rax, rdi
    mov  rcx, rsi
    dec  rcx
    add  rax, rcx
    not  rcx
    and  rax, rcx
    ret

; void* aligned_alloc64(size_t size)
; RDI=size
aligned_alloc64:
    push rbp
    mov  rbp, rsp
    push rbx
    push r12

    mov  r12, rdi              ; requested size

    ; total = size + header(16) + slack(63)
    lea  r11, [r12 + 16 + 63]  ; total length

    ; mmap(NULL, total, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0)
    xor  rdi, rdi              ; addr = 0
    mov  rsi, r11              ; length
    mov  rdx, PROT_READ | PROT_WRITE
    mov  r10, MAP_PRIVATE | MAP_ANON
    mov  r8,  -1
    xor  r9,  r9
    mov  rax, SYS_mmap
    syscall
    test rax, rax
    js   .fail

    mov  rbx, rax              ; base = mmap return

    ; payload = round_up(base + 16, 64)
    lea  rdi, [rbx + 16]
    mov  rsi, 64
    call round_up64
    mov  rcx, rax              ; payload

    ; header at payload-16:
    lea  rdx, [rcx - 16]
    mov  [rdx], rbx            ; base
    mov  [rdx+8], r11          ; len

    mov  rax, rcx              ; return payload
    pop  r12
    pop  rbx
    pop  rbp
    ret

.fail:

    xor  rax, rax
    add  rsp, 8
    pop  rbx
    pop  rbp
    ret

; void aligned_free64(void* p)
; RDI = payload pointer
aligned_free64:
    mov  rax, rdi
    sub  rax, 16
    mov  rdi, [rax]             ; base
    mov  rsi, [rax+8]           ; len
    mov  rax, SYS_munmap
    syscall
    ret

_start:
    ; allocate 1024
    mov  rdi, 1024
    call aligned_alloc64
    test rax, rax
    jz   .fail

    ; free it
    mov  rdi, rax
    call aligned_free64

    ; report ok
    mov  rdi, 1
    lea  rsi, [ok]
    mov  rdx, ok_len
    mov  rax, SYS_write
    syscall

    xor  rdi, rdi
    mov  rax, SYS_exit
    syscall

.fail:
    mov  rdi, 1
    lea  rsi, [bad]
    mov  rdx, bad_len
    mov  rax, SYS_write
    syscall
    mov  rdi, 1
    mov  rax, SYS_exit
    syscall
