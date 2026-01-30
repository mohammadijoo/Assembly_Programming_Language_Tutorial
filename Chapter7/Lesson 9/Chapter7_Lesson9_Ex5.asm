; Chapter7_Lesson9_Ex5.asm
; A bump allocator on a fixed buffer (no free). Demonstrates why allocators align.
; Build:
;   nasm -felf64 Chapter7_Lesson9_Ex5.asm -o ex5.o
;   gcc ex5.o -o ex5
; Run:
;   ./ex5

default rel
global main
extern printf

%define POOL_BYTES 4096
%define ALIGN      16

section .bss
pool:     resb POOL_BYTES
bump_ptr: resq 1
bump_end: resq 1

section .rodata
fmt: db "alloc(%3llu) -> %p", 10, 0
sizes: dq 1, 24, 7, 200, 17, 511, 1024
n_sizes: equ 7

section .text
align_up:
    ; rdi = x
    ; rax = align_up(x, 16) = (x + 15) & -16
    lea rax, [rdi + (ALIGN-1)]
    and rax, -ALIGN
    ret

bump_init:
    lea rax, [pool]
    mov [bump_ptr], rax
    lea rax, [pool + POOL_BYTES]
    mov [bump_end], rax
    ret

bump_alloc:
    ; rdi = size
    ; rax = ptr or 0
    push rbp
    mov rbp, rsp

    ; aligned = align_up(size, 16)
    call align_up
    mov r12, rax                 ; aligned size

    mov rax, [bump_ptr]
    mov rdx, rax                 ; candidate ptr
    add rdx, r12                 ; candidate end

    cmp rdx, [bump_end]
    ja .oom

    mov [bump_ptr], rdx
    ; return ptr in rax (already)
    leave
    ret

.oom:
    xor eax, eax
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 64

    call bump_init

    xor ebx, ebx
.loop:
    cmp ebx, n_sizes
    jge .done

    mov rdi, [sizes + rbx*8]
    mov r12, rdi
    call bump_alloc               ; rax = ptr
    mov r13, rax

    lea rdi, [fmt]
    mov rsi, r12
    mov rdx, r13
    xor eax, eax
    call printf

    inc ebx
    jmp .loop

.done:
    xor eax, eax
    leave
    ret
