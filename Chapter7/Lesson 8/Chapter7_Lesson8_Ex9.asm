; Chapter7_Lesson8_Ex9.asm
; linux64 syscall + constants header (NASM, Linux x86-64)
; Use: %include "Chapter7_Lesson8_Ex9.asm"
;
; Build (example):
;   nasm -felf64 Chapter7_Lesson8_Ex1.asm -o ex1.o && ld -o ex1 ex1.o
;
; Notes:
; - Syscall ABI (Linux x86-64): rax=syscall#, rdi,rsi,rdx,r10,r8,r9 = args
; - Errors: rax is negative (-errno)

%ifndef CH7_L8_LINUX64_INC
%define CH7_L8_LINUX64_INC

; -----------------------
; Syscall numbers (x86-64)
; -----------------------
%define SYS_read            0
%define SYS_write           1
%define SYS_open            2
%define SYS_close           3
%define SYS_mmap            9
%define SYS_mprotect       10
%define SYS_munmap         11
%define SYS_rt_sigaction   13
%define SYS_exit           60

; ---------------
; Open flags
; ---------------
%define O_RDONLY            0

; ---------------
; mmap / mprotect
; ---------------
%define PROT_NONE           0
%define PROT_READ           1
%define PROT_WRITE          2
%define PROT_EXEC           4

%define MAP_PRIVATE         2
%define MAP_ANONYMOUS       0x20

; ---------------
; Signals
; ---------------
%define SIGSEGV            11
%define SA_RESTORER        0x04000000

; -----------------------
; Syscall helper macros
; -----------------------
%macro syscall0 1
    mov rax, %1
    syscall
%endmacro

%macro syscall1 2
    mov rax, %1
    mov rdi, %2
    syscall
%endmacro

%macro syscall2 3
    mov rax, %1
    mov rdi, %2
    mov rsi, %3
    syscall
%endmacro

%macro syscall3 4
    mov rax, %1
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    syscall
%endmacro

%macro syscall4 5
    mov rax, %1
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov r10, %5
    syscall
%endmacro

%macro syscall5 6
    mov rax, %1
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov r10, %5
    mov r8,  %6
    syscall
%endmacro

%macro syscall6 7
    mov rax, %1
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov r10, %5
    mov r8,  %6
    mov r9,  %7
    syscall
%endmacro

%endif ; CH7_L8_LINUX64_INC
