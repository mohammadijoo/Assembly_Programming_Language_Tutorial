; Chapter2_Lesson9_Ex10.asm
; Minimal NASM "header" for Linux x86-64 syscalls and helper macros.
; In real projects, name this .inc and include it via:
;   %include "linux64_syscalls.inc"
; For this course packaging we keep .asm to satisfy file naming constraints.

%define SYS_write  1
%define SYS_exit   60

%define FD_STDIN   0
%define FD_STDOUT  1
%define FD_STDERR  2

%macro exit 1
    mov eax, SYS_exit
    mov edi, %1
    syscall
%endmacro

; write_stdout buf_reg_or_mem, len_imm_or_reg
; clobbers: rax, rdi, rsi, rdx
%macro write_stdout 2
    mov eax, SYS_write
    mov edi, FD_STDOUT
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro
