; Chapter 5 - Lesson 7 (Example 4)
; "Base-offset" range check trick:
;   idx = x - base
;   if (unsigned)idx > (N-1) -> default
; This single unsigned compare handles both x < base and x >= base+N.
; Build:
;   nasm -f elf64 Chapter5_Lesson7_Ex4.asm -o ex4.o

default rel
bits 64

section .text
global switch_base_offset

; int switch_base_offset(int x)
; cases: 10..15
switch_base_offset:
    mov eax, edi
    sub eax, 10                    ; idx = x - 10
    cmp eax, 5                     ; N-1
    ja  .default                   ; unsigned above -> out of range

    lea rdx, [jt]
    jmp qword [rdx + rax*8]

.case10:
    mov eax, 1000
    ret
.case11:
    mov eax, 1100
    ret
.case12:
    mov eax, 1200
    ret
.case13:
    mov eax, 1300
    ret
.case14:
    mov eax, 1400
    ret
.case15:
    mov eax, 1500
    ret

.default:
    mov eax, -1
    ret

section .rodata
align 8
jt:
    dq .case10, .case11, .case12, .case13, .case14, .case15
