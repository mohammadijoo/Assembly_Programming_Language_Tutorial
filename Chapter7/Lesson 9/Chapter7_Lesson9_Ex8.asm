; Chapter7_Lesson9_Ex8.asm
; Fragmentation experiment on the coalescing allocator:
; 1) Allocate many small blocks, free every other one (creates holes).
; 2) Request a larger block and observe whether coalescing can satisfy it.
; Build:
;   nasm -felf64 Chapter7_Lesson9_Ex8.asm -o ex8.o
;   gcc ex8.o -o ex8
; Run:
;   ./ex8

default rel
global main
extern printf

%define POOL_BYTES 8192
%define ALIGN      16
%define HDR_BYTES  8
%define FTR_BYTES  8
%define OVERHEAD   (HDR_BYTES + FTR_BYTES)
%define MIN_BLOCK  32
%define FLAG_ALLOC 1

section .bss
pool: resb POOL_BYTES
ptrs: resq 32

section .rodata
fmt: db "%s", 10, 0
m1: db "Allocated 16 blocks of 128 bytes (payload).", 0
m2: db "Freed every other block (creates holes).", 0
m3: db "Now request a 512-byte payload block.", 0
fmtp: db "big = %p", 10, 0
fmt_blk: db "blk@%p size=%4llu alloc=%llu", 10, 0

section .text
align_up_16:
    lea rax, [rdi + (ALIGN-1)]
    and rax, -ALIGN
    ret

heap_init:
    lea rbx, [pool]
    mov rax, POOL_BYTES
    and rax, -ALIGN
    mov [rbx], rax
    lea rdx, [rbx + rax - FTR_BYTES]
    mov [rdx], rax
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
    mov r12, rax

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

heap_free:
    test rdi, rdi
    jz .ret
    sub rdi, HDR_BYTES

    mov rax, [rdi]
    mov rcx, rax
    and rcx, -ALIGN
    mov [rdi], rcx
    lea r8, [rdi + rcx - FTR_BYTES]
    mov [r8], rcx

    ; coalesce next
    lea r9, [rdi + rcx]
    lea r10, [pool + POOL_BYTES]
    cmp r9, r10
    jae .prev

    mov rax, [r9]
    test rax, FLAG_ALLOC
    jnz .prev
    mov rdx, rax
    and rdx, -ALIGN
    add rcx, rdx
    mov [rdi], rcx
    lea r8, [rdi + rcx - FTR_BYTES]
    mov [r8], rcx

.prev:
    ; coalesce prev
    lea r11, [pool]
    cmp rdi, r11
    jbe .ret

    lea r12, [rdi - FTR_BYTES]
    mov rax, [r12]
    mov rdx, rax
    and rdx, -ALIGN
    test rax, FLAG_ALLOC
    jnz .ret

    sub rdi, rdx
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

    ; Allocate 16 blocks of payload 128
    xor ebx, ebx
.alloc_loop:
    cmp ebx, 16
    jge .after_alloc
    mov edi, 128
    call heap_malloc
    mov [ptrs + rbx*8], rax
    inc ebx
    jmp .alloc_loop

.after_alloc:
    lea rdi, [fmt]
    lea rsi, [m1]
    xor eax, eax
    call printf
    call heap_dump

    ; Free every other block (even indices)
    xor ebx, ebx
.free_loop:
    cmp ebx, 16
    jge .after_free
    test bl, 1
    jnz .skip
    mov rdi, [ptrs + rbx*8]
    call heap_free
.skip:
    inc ebx
    jmp .free_loop

.after_free:
    lea rdi, [fmt]
    lea rsi, [m2]
    xor eax, eax
    call printf
    call heap_dump

    lea rdi, [fmt]
    lea rsi, [m3]
    xor eax, eax
    call printf

    mov edi, 512
    call heap_malloc
    mov r12, rax

    lea rdi, [fmtp]
    mov rsi, r12
    xor eax, eax
    call printf

    xor eax, eax
    leave
    ret
