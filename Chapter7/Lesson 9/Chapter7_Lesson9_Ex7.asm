; Chapter7_Lesson9_Ex7.asm
; Same tiny allocator as Ex6, but with boundary-tag coalescing on free.
; Demonstrates how coalescing fights external fragmentation.
; Build:
;   nasm -felf64 Chapter7_Lesson9_Ex7.asm -o ex7.o
;   gcc ex7.o -o ex7
; Run:
;   ./ex7

default rel
global main
extern printf

%define POOL_BYTES 4096
%define ALIGN      16
%define HDR_BYTES  8
%define FTR_BYTES  8
%define OVERHEAD   (HDR_BYTES + FTR_BYTES)
%define MIN_BLOCK  32

%define FLAG_ALLOC 1

section .bss
pool: resb POOL_BYTES

section .rodata
fmt_blk: db "blk@%p size=%4llu alloc=%llu", 10, 0
fmt_msg: db "%s", 10, 0
msg1: db "After allocations:", 0
msg2: db "After frees (with coalesce):", 0
msg3: db "Attempt big alloc (should succeed after coalescing):", 0
fmt_big: db "big ptr = %p", 10, 0

section .text
align_up_16:
    lea rax, [rdi + (ALIGN-1)]
    and rax, -ALIGN
    ret

heap_init:
    lea rbx, [pool]
    mov rax, POOL_BYTES
    and rax, -ALIGN
    mov rcx, rax
    mov [rbx], rcx
    lea rdx, [rbx + rcx - FTR_BYTES]
    mov [rdx], rcx
    ret

heap_dump:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    lea rbx, [pool]
    lea r14, [pool + POOL_BYTES]
.loop:
    cmp rbx, r14
    jae .done

    mov rax, [rbx]
    mov rcx, rax
    and rcx, -ALIGN
    mov rdx, rax
    and rdx, FLAG_ALLOC

    lea rdi, [fmt_blk]
    mov rsi, rbx
    mov r8,  rcx
    mov r9,  rdx
    mov rdx, r8
    mov rcx, r9
    xor eax, eax
    call printf

    add rbx, rcx
    jmp .loop
.done:
    leave
    ret

heap_malloc:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    call align_up_16
    add rax, OVERHEAD
    mov r12, rax                 ; needed

    lea rbx, [pool]
    lea r14, [pool + POOL_BYTES]
.scan:
    cmp rbx, r14
    jae .oom

    mov rax, [rbx]
    mov rcx, rax
    and rcx, -ALIGN
    test rax, FLAG_ALLOC
    jnz .next

    cmp rcx, r12
    jb .next

    mov rdx, rcx
    sub rdx, r12
    cmp rdx, MIN_BLOCK
    jb .nosplit

    mov rax, r12
    or rax, FLAG_ALLOC
    mov [rbx], rax
    lea r8, [rbx + r12 - FTR_BYTES]
    mov [r8], rax

    lea r9, [rbx + r12]
    mov r10, rdx
    and r10, -ALIGN
    mov [r9], r10
    lea r11, [r9 + r10 - FTR_BYTES]
    mov [r11], r10

    lea rax, [rbx + HDR_BYTES]
    leave
    ret

.nosplit:
    mov rax, rcx
    or rax, FLAG_ALLOC
    mov [rbx], rax
    lea r8, [rbx + rcx - FTR_BYTES]
    mov [r8], rax
    lea rax, [rbx + HDR_BYTES]
    leave
    ret

.next:
    add rbx, rcx
    jmp .scan

.oom:
    xor eax, eax
    leave
    ret

heap_free_coalesce:
    ; rdi = payload ptr
    test rdi, rdi
    jz .ret
    sub rdi, HDR_BYTES           ; hdr ptr in rdi

    ; mark current block free
    mov rax, [rdi]
    mov rcx, rax
    and rcx, -ALIGN              ; cur_size
    mov [rdi], rcx
    lea r8, [rdi + rcx - FTR_BYTES]
    mov [r8], rcx

    ; try coalesce with NEXT block
    lea r9, [rdi + rcx]          ; next_hdr
    lea r10, [pool + POOL_BYTES]
    cmp r9, r10
    jae .prev

    mov rax, [r9]
    test rax, FLAG_ALLOC
    jnz .prev
    mov rdx, rax
    and rdx, -ALIGN              ; next_size

    ; merge: cur_size += next_size
    add rcx, rdx
    mov [rdi], rcx
    lea r8, [rdi + rcx - FTR_BYTES]
    mov [r8], rcx

.prev:
    ; try coalesce with PREV block using footer
    lea r11, [pool]
    cmp rdi, r11
    jbe .ret                     ; at start, no previous

    lea r12, [rdi - FTR_BYTES]   ; prev_footer
    mov rax, [r12]
    mov rdx, rax
    and rdx, -ALIGN              ; prev_size
    test rax, FLAG_ALLOC
    jnz .ret

    ; prev_hdr = cur_hdr - prev_size
    sub rdi, rdx
    ; new_size = prev_size + cur_size (rcx already includes possible next-merge)
    add rcx, rdx
    mov [rdi], rcx
    lea r8, [rdi + rcx - FTR_BYTES]
    mov [r8], rcx

.ret:
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 96

    call heap_init

    mov edi, 512
    call heap_malloc
    mov [rbp-8], rax

    mov edi, 512
    call heap_malloc
    mov [rbp-16], rax

    mov edi, 512
    call heap_malloc
    mov [rbp-24], rax

    lea rdi, [msg1]
    xor eax, eax
    call printf
    call heap_dump

    ; free a and c, then free b (middle) and coalesce will merge into one block
    mov rdi, [rbp-8]
    call heap_free_coalesce
    mov rdi, [rbp-24]
    call heap_free_coalesce
    mov rdi, [rbp-16]
    call heap_free_coalesce

    lea rdi, [msg2]
    xor eax, eax
    call printf
    call heap_dump

    lea rdi, [msg3]
    xor eax, eax
    call printf

    mov edi, 1500
    call heap_malloc
    mov [rbp-32], rax

    lea rdi, [fmt_big]
    mov rsi, [rbp-32]
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret
