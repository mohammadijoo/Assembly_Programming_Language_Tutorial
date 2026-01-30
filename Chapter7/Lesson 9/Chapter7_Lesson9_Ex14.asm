; Chapter7_Lesson9_Ex14.asm
; Programming Exercise Solution:
; A fixed-size pool allocator (slab-like) to avoid fragmentation for small objects.
; - Objects are 32 bytes each
; - Pool contains 128 objects
; - Free list stored as indices (byte) in the first byte of each free object
; Build:
;   nasm -felf64 Chapter7_Lesson9_Ex14.asm -o ex14.o
;   gcc ex14.o -o ex14
; Run:
;   ./ex14

default rel
global main
extern printf

%define OBJ_SIZE  32
%define OBJ_COUNT 128

section .bss
pool:     resb OBJ_SIZE * OBJ_COUNT
free_head: resb 1

section .rodata
fmt1: db "alloc -> %p", 10, 0
fmt2: db "free  -> %p", 10, 0
fmt3: db "after reuse alloc -> %p", 10, 0

section .text
pool_init:
    ; Initialize free list: object i stores next index in first byte.
    ; free_head = 0
    mov byte [free_head], 0
    xor ecx, ecx
.loop:
    cmp ecx, OBJ_COUNT-1
    jge .last
    ; pool[i].next = i+1
    lea rbx, [pool + rcx*OBJ_SIZE]
    mov al, cl
    inc al
    mov [rbx], al
    inc ecx
    jmp .loop
.last:
    lea rbx, [pool + (OBJ_COUNT-1)*OBJ_SIZE]
    mov byte [rbx], 0xFF         ; end marker
    ret

pool_alloc:
    ; rax = ptr or 0
    movzx eax, byte [free_head]
    cmp al, 0xFF
    je .oom

    ; ptr = &pool[index]
    movzx ecx, al
    lea rax, [pool + rcx*OBJ_SIZE]

    ; free_head = pool[index].next
    mov bl, [rax]
    mov [free_head], bl

    ret
.oom:
    xor eax, eax
    ret

pool_free:
    ; rdi = ptr
    test rdi, rdi
    jz .ret

    ; compute index = (ptr - pool) / OBJ_SIZE
    lea rbx, [pool]
    mov rax, rdi
    sub rax, rbx
    xor rdx, rdx
    mov rcx, OBJ_SIZE
    div rcx                       ; rax = index

    ; store current free_head into object[ index ].next
    mov bl, [free_head]
    mov [rdi], bl

    ; free_head = index
    mov [free_head], al
.ret:
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 64

    call pool_init

    call pool_alloc
    mov r12, rax
    lea rdi, [fmt1]
    mov rsi, r12
    xor eax, eax
    call printf

    call pool_alloc
    mov r13, rax
    lea rdi, [fmt1]
    mov rsi, r13
    xor eax, eax
    call printf

    ; free first, then allocate again and observe reuse (LIFO-ish)
    mov rdi, r12
    lea rdi, [rdi]                ; keep rdi
    lea rdi, [r12]
    call pool_free

    lea rdi, [fmt2]
    mov rsi, r12
    xor eax, eax
    call printf

    call pool_alloc
    mov r14, rax
    lea rdi, [fmt3]
    mov rsi, r14
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret
