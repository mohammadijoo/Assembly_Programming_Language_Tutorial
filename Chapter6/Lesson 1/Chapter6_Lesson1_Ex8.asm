; Chapter6_Lesson1_Ex8.asm
; RET imm16 (callee stack cleanup) - a stdcall-like pattern.
; On x86-64 this exists, but it is uncommon under SysV. Still useful conceptually.
;
; We define mul2_stdcall() that expects TWO qword args pushed by caller:
;   push b
;   push a
;   call mul2_stdcall
; Callee returns a*b in RAX and uses 'ret 16' to pop its arguments.
;
; Build:
;   nasm -felf64 Chapter6_Lesson1_Ex8.asm -o ex8.o
;   ld ex8.o -o ex8

BITS 64
DEFAULT REL

GLOBAL _start

SECTION .text

mul2_stdcall:
    push rbp
    mov rbp, rsp

    mov rax, [rbp+16]         ; a
    imul rax, [rbp+24]        ; a*b

    pop rbp
    ret 16                    ; pop return address + add 16 to RSP (args)

_start:
    push qword 9              ; b
    push qword 6              ; a
    call mul2_stdcall         ; callee cleans arguments

    mov edi, eax
    mov eax, 60
    syscall
