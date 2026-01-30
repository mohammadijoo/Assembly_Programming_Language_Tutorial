; Chapter7_Lesson9_Ex6.asm
; A tiny implicit free-list allocator on a fixed pool (split blocks, but NO coalescing).
; This intentionally shows external fragmentation when frees are scattered.
; Build:
;   nasm -felf64 Chapter7_Lesson9_Ex6.asm -o ex6.o
;   gcc ex6.o -o ex6
; Run:
;   ./ex6

default rel
global main
extern printf

%define POOL_BYTES 4096
%define ALIGN      16
%define HDR_BYTES  8
%define FTR_BYTES  8
%define OVERHEAD   (HDR_BYTES + FTR_BYTES)
%define MIN_BLOCK  32            ; minimum split remainder to form a valid block

%define FLAG_ALLOC 1

section .bss
pool: resb POOL_BYTES

section .rodata
fmt_blk: db "blk@%p size=%4llu alloc=%llu", 10, 0
fmt_msg: db "%s", 10, 0
msg1: db "After allocations:", 0
msg2: db "After frees (no coalesce):", 0
msg3: db "Attempt big alloc (should fail due to fragmentation):", 0
fmt_big: db "big ptr = %p", 10, 0

section .text
align_up_16:
    lea rax, [rdi + (ALIGN-1)]
    and rax, -ALIGN
    ret

; Layout: [header: size|flags][payload ...][footer: size|flags]
; size includes header+payload+footer and is multiple of 16.

heap_init:
    lea rbx, [pool]
    mov rax, POOL_BYTES
    and rax, -ALIGN
    mov rcx, rax
    and rcx, -ALIGN              ; size
    ; free block => alloc flag 0
    mov [rbx], rcx               ; header
    lea rdx, [rbx + rcx - FTR_BYTES]
    mov [rdx], rcx               ; footer
    ret

heap_dump:
    ; Walk blocks and print
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
    and rcx, -ALIGN              ; size
    mov rdx, rax
    and rdx, FLAG_ALLOC          ; alloc flag

    lea rdi, [fmt_blk]
    mov rsi, rbx
    mov r8,  rcx                 ; size
    mov r9,  rdx                 ; alloc
    ; printf wants args: rdi, rsi, rdx, rcx, r8, r9 ...
    ; reorder:
    mov rdx, r8
    mov rcx, r9
    xor eax, eax
    call printf

    add rbx, rcx                 ; advance by size
    jmp .loop

.done:
    leave
    ret

heap_malloc:
    ; rdi = requested payload bytes
    ; rax = payload ptr or 0
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; needed = align_up(req,16) + overhead
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
    and rcx, -ALIGN              ; blk_size
    test rax, FLAG_ALLOC
    jnz .next

    ; free block and big enough?
    cmp rcx, r12
    jb .next

    ; can split?
    mov rdx, rcx
    sub rdx, r12                 ; remainder
    cmp rdx, MIN_BLOCK
    jb .nosplit

    ; allocated block header/footer
    mov rax, r12
    or rax, FLAG_ALLOC
    mov [rbx], rax
    lea r8, [rbx + r12 - FTR_BYTES]
    mov [r8], rax

    ; remainder free block
    lea r9, [rbx + r12]
    mov r10, rdx                 ; rem_size
    and r10, -ALIGN
    mov [r9], r10
    lea r11, [r9 + r10 - FTR_BYTES]
    mov [r11], r10

    lea rax, [rbx + HDR_BYTES]
    leave
    ret

.nosplit:
    ; mark whole block allocated
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

heap_free_nocoalesce:
    ; rdi = payload ptr
    test rdi, rdi
    jz .ret
    sub rdi, HDR_BYTES           ; header ptr
    mov rax, [rdi]
    and rax, -ALIGN              ; size, clear flags
    mov [rdi], rax               ; header as free
    lea rdx, [rdi + rax - FTR_BYTES]
    mov [rdx], rax               ; footer
.ret:
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 96

    call heap_init

    ; a = malloc(512), b = malloc(512), c = malloc(512)
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

    ; free a and c (holes), keep b allocated => cannot form one big block
    mov rdi, [rbp-8]
    call heap_free_nocoalesce
    mov rdi, [rbp-24]
    call heap_free_nocoalesce

    lea rdi, [msg2]
    xor eax, eax
    call printf
    call heap_dump

    lea rdi, [msg3]
    xor eax, eax
    call printf

    ; request a block bigger than either hole alone
    mov edi, 900
    call heap_malloc
    mov [rbp-32], rax

    lea rdi, [fmt_big]
    mov rsi, [rbp-32]
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret
