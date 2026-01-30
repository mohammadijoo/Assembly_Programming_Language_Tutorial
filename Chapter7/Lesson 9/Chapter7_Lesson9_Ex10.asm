; Chapter7_Lesson9_Ex10.asm
; mmap-backed arena + bump allocator (syscall interface).
; Demonstrates page granularity and why large allocations often come from mmap.
; Build:
;   nasm -felf64 Chapter7_Lesson9_Ex10.asm -o ex10.o
;   gcc ex10.o -o ex10
; Run:
;   ./ex10

default rel
global main
extern printf

%define SYS_mmap    9
%define SYS_munmap 11

%define PROT_READ   1
%define PROT_WRITE  2
%define MAP_PRIVATE 2
%define MAP_ANON    0x20

%define ARENA_BYTES 65536
%define ALIGN       16

section .bss
arena_base: resq 1
arena_ptr:  resq 1
arena_end:  resq 1

section .rodata
fmt1: db "mmap arena base=%p size=%llu", 10, 0
fmt2: db "alloc(%llu) -> %p", 10, 0
sizes: dq 1, 200, 4096, 17, 8192, 64
n_sizes: equ 6

section .text
align_up_16:
    lea rax, [rdi + (ALIGN-1)]
    and rax, -ALIGN
    ret

arena_alloc:
    ; rdi = size
    ; rax = ptr or 0
    push rbp
    mov rbp, rsp

    call align_up_16
    mov r12, rax

    mov rax, [arena_ptr]
    mov rdx, rax
    add rdx, r12
    cmp rdx, [arena_end]
    ja .oom

    mov [arena_ptr], rdx
    leave
    ret
.oom:
    xor eax, eax
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 96

    ; rax = mmap(NULL, ARENA_BYTES, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0)
    xor rdi, rdi
    mov rsi, ARENA_BYTES
    mov rdx, PROT_READ | PROT_WRITE
    mov r10, MAP_PRIVATE | MAP_ANON
    mov r8, -1
    xor r9, r9
    mov eax, SYS_mmap
    syscall

    ; check error: Linux returns -errno in rax
    test rax, rax
    js .fail

    mov [arena_base], rax
    mov [arena_ptr],  rax
    lea rdx, [rax + ARENA_BYTES]
    mov [arena_end], rdx

    lea rdi, [fmt1]
    mov rsi, [arena_base]
    mov rdx, ARENA_BYTES
    xor eax, eax
    call printf

    xor ebx, ebx
.loop:
    cmp ebx, n_sizes
    jge .cleanup

    mov rdi, [sizes + rbx*8]
    mov r12, rdi
    call arena_alloc
    mov r13, rax

    lea rdi, [fmt2]
    mov rsi, r12
    mov rdx, r13
    xor eax, eax
    call printf

    inc ebx
    jmp .loop

.cleanup:
    mov rdi, [arena_base]
    mov rsi, ARENA_BYTES
    mov eax, SYS_munmap
    syscall

    xor eax, eax
    leave
    ret

.fail:
    mov eax, 1
    leave
    ret
