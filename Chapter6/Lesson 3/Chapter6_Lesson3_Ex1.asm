; Chapter6_Lesson3_Ex1.asm
; Lesson 3: Passing Parameters to Procedures (Stack and Register Methods)
; Example 1 (SysV AMD64 / Linux): integer arguments passed in registers.
;
; Build (Linux x86-64):
;   nasm -f elf64 Chapter6_Lesson3_Ex1.asm -o ex1.o
;   ld -o ex1 ex1.o
; Run:
;   ./ex1 ; exit code = 60 (10+20+30)

global _start

section .text

; int64 add3(int64 a, int64 b, int64 c)
; SysV AMD64: a=RDI, b=RSI, c=RDX, return=RAX
add3:
    lea     rax, [rdi + rsi]
    add     rax, rdx
    ret

_start:
    mov     edi, 10
    mov     esi, 20
    mov     edx, 30
    call    add3

    ; exit(status = (int)rax)
    mov     edi, eax
    mov     eax, 60          ; SYS_exit
    syscall
