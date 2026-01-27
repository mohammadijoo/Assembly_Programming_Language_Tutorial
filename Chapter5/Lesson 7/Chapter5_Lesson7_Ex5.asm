; Chapter 5 - Lesson 7 (Example 5)
; Holey switch implemented with a jump table that includes default entries.
; This keeps O(1) dispatch but inflates the table when the range is wide.
; Build:
;   nasm -f elf64 Chapter5_Lesson7_Ex5.asm -o ex5.o

default rel
bits 64

section .text
global switch_holey_table

; int switch_holey_table(int x)
; cases: 0,2,7,9  (range 0..9)
switch_holey_table:
    mov eax, edi
    cmp eax, 9
    ja  .default

    lea rdx, [jt]
    jmp qword [rdx + rax*8]

.case0:  mov eax, 9000  ; case 0
         ret
.case2:  mov eax, 9002  ; case 2
         ret
.case7:  mov eax, 9007  ; case 7
         ret
.case9:  mov eax, 9009  ; case 9
         ret

.default:
    mov eax, -1
    ret

section .rodata
align 8
jt:
    dq .case0        ; 0
    dq .default      ; 1 (hole)
    dq .case2        ; 2
    dq .default      ; 3
    dq .default      ; 4
    dq .default      ; 5
    dq .default      ; 6
    dq .case7        ; 7
    dq .default      ; 8
    dq .case9        ; 9
