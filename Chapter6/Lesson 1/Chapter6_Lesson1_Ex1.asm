; Chapter6_Lesson1_Ex1.asm
; Minimal "procedure" (function) on Linux x86-64 (SysV ABI, NASM).
; Build:
;   nasm -felf64 Chapter6_Lesson1_Ex1.asm -o ex1.o
;   ld ex1.o -o ex1
; Run:
;   ./ex1 ; echo $?  (exit status should be 42)

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

; int foo(void)  -> returns 42 in EAX
foo:
    mov eax, 42
    ret

_start:
    call foo                 ; pushes return address, jumps to foo
    mov edi, eax             ; Linux exit(status) uses RDI
    mov eax, 60              ; __NR_exit
    syscall
