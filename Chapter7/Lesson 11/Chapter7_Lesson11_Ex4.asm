; Chapter 7 - Lesson 11 - Example 4
; Topic: Guard pages via mmap + mprotect (conceptual overflow-to-fault detector)
; Platform: Linux x86-64, NASM syntax (syscalls)
;
; Build:
;   nasm -felf64 Chapter7_Lesson11_Ex4.asm -o ex4.o
;   ld -o ex4 ex4.o
;
; Run:
;   ./ex4
;
; Expected behavior:
;   - Allocates 2 pages (8192 bytes).
;   - Marks the second page PROT_NONE.
;   - Writes 5000 bytes starting at the base; this crosses into the guard page
;     and should SIGSEGV (crash). Use a debugger to see the faulting address.
;
; This is purely a defensive diagnostic demonstration.

default rel
global _start

%define SYS_write     1
%define SYS_exit      60
%define SYS_mmap      9
%define SYS_mprotect  10

%define PROT_READ     1
%define PROT_WRITE    2
%define PROT_NONE     0

%define MAP_PRIVATE   2
%define MAP_ANON      32

section .data
msg0      db "== Guard page demo ==", 10
msg0_len  equ $-msg0

msg1      db "Allocated 2 pages; second page is PROT_NONE. Next: write crosses boundary and faults.", 10
msg1_len  equ $-msg1

section .bss
base_ptr  resq 1

section .text

write1:
    mov eax, SYS_write
    mov edi, 1
    syscall
    ret

_start:
    lea rsi, [rel msg0]
    mov edx, msg0_len
    call write1

    ; mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0)
    xor edi, edi                ; addr = 0
    mov esi, 8192               ; len
    mov edx, PROT_READ | PROT_WRITE
    mov r10d, MAP_PRIVATE | MAP_ANON
    mov r8d, -1                 ; fd = -1
    xor r9d, r9d                ; off = 0
    mov eax, SYS_mmap
    syscall
    test rax, rax
    js .fail
    mov [base_ptr], rax

    ; mprotect(base+4096, 4096, PROT_NONE)
    mov rdi, rax
    add rdi, 4096
    mov esi, 4096
    mov edx, PROT_NONE
    mov eax, SYS_mprotect
    syscall

    lea rsi, [rel msg1]
    mov edx, msg1_len
    call write1

    ; write 5000 bytes of 0xAA starting from base (crosses into guard page)
    mov rdi, [base_ptr]
    mov ecx, 5000
    mov al, 0xAA
    rep stosb

    ; If we got here, something is wrong (should not).
    mov eax, SYS_exit
    mov edi, 0
    syscall

.fail:
    mov eax, SYS_exit
    mov edi, 1
    syscall
