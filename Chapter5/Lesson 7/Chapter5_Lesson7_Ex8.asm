; Chapter 5 - Lesson 7 (Example 8)
; NASM preprocessor generates a jump table + case labels via %rep.
; This pattern scales to large tables and keeps the source maintainable.
; Build:
;   nasm -f elf64 Chapter5_Lesson7_Ex8.asm -o ex8.o

default rel
bits 64

%assign NCASES 16                  ; cases 0..15

section .text
global switch_generated

; int switch_generated(int x)
switch_generated:
    mov eax, edi
    cmp eax, (NCASES-1)
    ja  .default

    lea rdx, [jt]
    jmp qword [rdx + rax*8]

.default:
    mov eax, -1
    ret

; Generate case labels that return (10000 + case_id)
%assign i 0
%rep NCASES
.case_%+i:
    mov eax, 10000 + i
    ret
%assign i i+1
%endrep

section .rodata
align 8
jt:
%assign j 0
%rep NCASES
    dq .case_%+j
%assign j j+1
%endrep
