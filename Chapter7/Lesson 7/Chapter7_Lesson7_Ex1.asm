; Chapter7_Lesson7_Ex1.asm
; Demonstrate stack alignment at the kernel-provided entry point (_start).
;
; Build (Linux x86-64):
;   nasm -felf64 Chapter7_Lesson7_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
; Run:
;   ./ex1 ; echo $?
; The exit status is (RSP mod 16) at _start.

global _start
section .text

_start:
    mov     rax, rsp
    and     rax, 15            ; rax = rsp mod 16

    ; exit(status = rax)
    mov     rdi, rax
    mov     eax, 60            ; SYS_exit
    syscall
