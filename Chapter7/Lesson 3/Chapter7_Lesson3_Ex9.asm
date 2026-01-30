; Chapter 7 - Lesson 3 - Example 9
; Fixed-size block allocator (free-list) in assembly
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex9.asm -o ex9.o
;   gcc -no-pie ex9.o -o ex9
;
; Model:
;   - pool of N blocks, each block has a next pointer in first 8 bytes
;   - alloc pops from free list
;   - free pushes back
; Practical use:
;   - fast allocation for uniform objects (like slab/pool allocators)

default rel
global main
extern printf

%define BLOCK_SIZE  64
%define BLOCK_COUNT 32
%define POOL_SIZE   (BLOCK_SIZE*BLOCK_COUNT)

section .bss
pool       resb POOL_SIZE
free_head  resq 1

section .data
fmt_init db "pool initialized, free_head=%p", 10, 0
fmt_alloc db "alloc returned %p", 10, 0
fmt_free  db "freed %p, free_head=%p", 10, 0

section .text
; void pool_init()
pool_init:
    push rbp
    mov  rbp, rsp

    lea  rax, [pool]
    mov  [free_head], rax

    ; link blocks: block[i].next = &block[i+1]
    xor  ecx, ecx
.link:
    cmp  ecx, (BLOCK_COUNT-1)
    jge  .last

    lea  rdx, [pool + rcx*BLOCK_SIZE]
    lea  r8,  [pool + (rcx+1)*BLOCK_SIZE]
    mov  [rdx], r8
    inc  ecx
    jmp  .link

.last:
    lea  rdx, [pool + (BLOCK_COUNT-1)*BLOCK_SIZE]
    mov  qword [rdx], 0         ; last.next = NULL
    pop  rbp
    ret

; void* pool_alloc()
pool_alloc:
    mov  rax, [free_head]
    test rax, rax
    jz   .empty
    mov  rdx, [rax]             ; next
    mov  [free_head], rdx
    ret
.empty:
    xor  rax, rax
    ret

; void pool_free(void* p)
pool_free:
    ; p in RDI
    mov  rax, [free_head]
    mov  [rdi], rax             ; p->next = free_head
    mov  [free_head], rdi
    ret

main:
    push rbp
    mov  rbp, rsp
    push rbx
    sub  rsp, 8                 ; align

    call pool_init

    lea  rdi, [fmt_init]
    mov  rsi, [free_head]
    xor  eax, eax
    call printf

    call pool_alloc
    mov  rbx, rax

    lea  rdi, [fmt_alloc]
    mov  rsi, rbx
    xor  eax, eax
    call printf

    mov  rdi, rbx
    call pool_free

    lea  rdi, [fmt_free]
    mov  rsi, rbx
    mov  rdx, [free_head]
    xor  eax, eax
    call printf

    xor  eax, eax
    add  rsp, 8
    pop  rbx
    pop  rbp
    ret
