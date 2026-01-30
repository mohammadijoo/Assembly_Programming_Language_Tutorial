; Chapter 7 - Lesson 4 - Exercise Solution 2
; A small slab allocator for fixed-size 64-byte objects.
; Uses mmap to get one 4KiB page, then threads a free list through blocks.
; Build (Linux x86-64):
;   nasm -felf64 Chapter7_Lesson4_Ex8.asm -o ex8.o
;   gcc -no-pie ex8.o -o ex8

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

%define PAGE_SZ     4096
%define OBJ_SZ      64
%define HEADER_SZ   16      ; [0]=base, [8]=free_head

section .data
fmt_p   db "alloc -> %p", 10, 0
fmt_f   db "free  -> %p", 10, 0
msg_bad db "slab init failed", 10, 0

section .text

; void* slab_alloc(slab* s)
; slab struct: [0]=base, [8]=free_head
; rdi = slab*
slab_alloc:
    mov  rax, [rdi+8]        ; free_head
    test rax, rax
    jz   .none
    mov  rdx, [rax]          ; next = *(qword*)block
    mov  [rdi+8], rdx
    ret
.none:
    xor  eax, eax
    ret

; void slab_free(slab* s, void* p)
; rdi=slab*, rsi=ptr
slab_free:
    mov  rdx, [rdi+8]
    mov  [rsi], rdx          ; *(qword*)p = old head
    mov  [rdi+8], rsi
    ret

main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 128

    ; slab struct at [rbp-32 .. rbp-17]
    lea  rdi, [rbp-32]

    ; mmap one page
    xor  edi, edi
    mov  esi, PAGE_SZ
    mov  edx, PROT_READ | PROT_WRITE
    mov  ecx, MAP_PRIVATE | MAP_ANON
    mov  r8,  -1
    xor  r9d, r9d
    call mmap
    cmp  rax, -1
    je   .bad

    ; store base
    lea  rdi, [rbp-32]
    mov  [rdi+0], rax

    ; build free list starting at base + HEADER_SZ
    mov  r10, rax
    add  r10, HEADER_SZ       ; first object
    mov  [rdi+8], r10         ; free_head

    ; number of objects = (PAGE_SZ - HEADER_SZ)/OBJ_SZ
    mov  ecx, (PAGE_SZ - HEADER_SZ) / OBJ_SZ
    dec  ecx                  ; link ecx times (last points to NULL)

.link_loop:
    test ecx, ecx
    jz   .terminate

    lea  r11, [r10 + OBJ_SZ]  ; next = cur + OBJ_SZ
    mov  [r10], r11           ; *(qword*)cur = next
    mov  r10, r11
    dec  ecx
    jmp  .link_loop

.terminate:
    mov  qword [r10], 0        ; last.next = NULL

    ; allocate 3 objects
    lea  rdi, [rbp-32]
    call slab_alloc
    mov  [rbp-64], rax
    lea  rdi, [fmt_p]
    mov  rsi, rax
    xor  eax, eax
    call printf

    lea  rdi, [rbp-32]
    call slab_alloc
    mov  [rbp-72], rax
    lea  rdi, [fmt_p]
    mov  rsi, rax
    xor  eax, eax
    call printf

    lea  rdi, [rbp-32]
    call slab_alloc
    mov  [rbp-80], rax
    lea  rdi, [fmt_p]
    mov  rsi, rax
    xor  eax, eax
    call printf

    ; free the middle object
    lea  rdi, [rbp-32]
    mov  rsi, [rbp-72]
    call slab_free
    lea  rdi, [fmt_f]
    mov  rsi, [rbp-72]
    xor  eax, eax
    call printf

    ; allocate again: should reuse freed block
    lea  rdi, [rbp-32]
    call slab_alloc
    lea  rdi, [fmt_p]
    mov  rsi, rax
    xor  eax, eax
    call printf

    ; munmap(base, PAGE_SZ)
    lea  rdi, [rbp-32]
    mov  rdi, [rdi+0]
    mov  esi, PAGE_SZ
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
