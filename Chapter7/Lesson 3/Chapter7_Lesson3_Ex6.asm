; Chapter 7 - Lesson 3 - Example 6
; Direct page allocation with mmap/munmap via Linux syscalls (no libc)
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex6.asm -o ex6.o
;   ld -o ex6 ex6.o
;
; Syscalls:
;   mmap   rax=9
;   munmap rax=11
;   write  rax=1
;   exit   rax=60

default rel
global _start

%define SYS_write   1
%define SYS_mmap    9
%define SYS_munmap 11
%define SYS_exit   60

%define PROT_READ   1
%define PROT_WRITE  2
%define MAP_PRIVATE 2
%define MAP_ANON    0x20

section .data
msg db "mmap allocated one page and wrote into it.", 10
msg_len equ $-msg

section .text
_start:
    ; mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0)
    xor  rdi, rdi              ; addr = 0
    mov  rsi, 4096             ; length
    mov  rdx, PROT_READ | PROT_WRITE
    mov  r10, MAP_PRIVATE | MAP_ANON
    mov  r8,  -1               ; fd
    xor  r9,  r9               ; offset
    mov  rax, SYS_mmap
    syscall

    ; On error, Linux returns -errno in RAX (a negative number in [-4095, -1])
    test rax, rax
    js   .die

    ; write(1, msg, msg_len)
    mov  rdi, 1
    lea  rsi, [msg]
    mov  rdx, msg_len
    mov  rax, SYS_write
    syscall

    ; munmap(ptr, 4096)
    mov  rdi, rax              ; ptr returned by mmap
    mov  rsi, 4096
    mov  rax, SYS_munmap
    syscall

    ; exit(0)
    xor  rdi, rdi
    mov  rax, SYS_exit
    syscall

.die:
    mov  rdi, 1
    mov  rax, SYS_exit
    syscall
