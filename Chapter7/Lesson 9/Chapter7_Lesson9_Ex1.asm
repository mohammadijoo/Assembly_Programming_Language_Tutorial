; Chapter7_Lesson9_Ex1.asm
; Minimal malloc/free call from NASM (SysV AMD64, Linux)
; Build:
;   nasm -felf64 Chapter7_Lesson9_Ex1.asm -o ex1.o
;   gcc ex1.o -o ex1
;
; Run:
;   ./ex1

default rel
global main
extern malloc
extern free

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32                 ; keep 16-byte alignment for calls

    mov edi, 64                 ; size_t size = 64
    call malloc                 ; rax = malloc(64)
    test rax, rax
    jz .done

    mov rdi, rax                ; free(ptr)
    call free

.done:
    xor eax, eax
    leave
    ret
