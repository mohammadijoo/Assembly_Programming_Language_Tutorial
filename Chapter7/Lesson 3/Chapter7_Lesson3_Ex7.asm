; Chapter 7 - Lesson 3 - Example 7
; Using sys_brk as a bump allocator (educational; not recommended for production user-space)
; Build:
;   nasm -felf64 Chapter7_Lesson3_Ex7.asm -o ex7.o
;   ld -o ex7 ex7.o
;
; Syscalls:
;   brk  rax=12
;   write rax=1
;   exit rax=60

default rel
global _start

%define SYS_write 1
%define SYS_brk  12
%define SYS_exit 60

section .data
ok  db "brk extended heap break successfully.", 10
ok_len  equ $-ok
bad db "brk failed to extend heap break.", 10
bad_len equ $-bad

section .text
_start:
    ; brk(0) -> current program break (current end of heap)
    xor  rdi, rdi
    mov  rax, SYS_brk
    syscall
    mov  rbx, rax              ; old break

    ; request new break = old + 8192
    lea  rdi, [rbx + 8192]
    mov  rax, SYS_brk
    syscall

    ; Linux returns the new break on success; on failure returns the current break (unchanged)
    cmp  rax, rdi
    jne  .fail

    ; report success
    mov  rdi, 1
    lea  rsi, [ok]
    mov  rdx, ok_len
    mov  rax, SYS_write
    syscall

    xor  rdi, rdi
    mov  rax, SYS_exit
    syscall

.fail:
    mov  rdi, 1
    lea  rsi, [bad]
    mov  rdx, bad_len
    mov  rax, SYS_write
    syscall

    mov  rdi, 1
    mov  rax, SYS_exit
    syscall
