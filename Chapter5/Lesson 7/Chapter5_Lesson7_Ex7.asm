; Chapter 5 - Lesson 7 (Example 7)
; PIC-friendly (RIP-relative) jump table addressing patterns.
; Demonstrates two equivalent ways:
;   A) default rel + lea rdx, [jt]
;   B) explicit rel: lea rdx, [rel jt]
;
; Build:
;   nasm -f elf64 Chapter5_Lesson7_Ex7.asm -o ex7.o

default rel
bits 64

section .text
global switch_pic

; int switch_pic(int x)
; cases: 3..6 (base=3), default=-1
switch_pic:
    mov eax, edi
    sub eax, 3
    cmp eax, 3
    ja  .default

    ; A) default rel makes [jt] RIP-relative
    lea rdx, [jt]
    jmp qword [rdx + rax*8]

.case3:  mov eax, 300
         ret
.case4:  mov eax, 400
         ret
.case5:  mov eax, 500
         ret
.case6:  mov eax, 600
         ret

.default:
    mov eax, -1
    ret

section .rodata
align 8
jt:
    dq .case3, .case4, .case5, .case6
