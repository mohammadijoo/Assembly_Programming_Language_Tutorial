; Chapter 5 - Lesson 7 (Exercise 2 - Solution)
; Very hard: Two-level jump table to reduce table size for a wide range.
;
; Problem idea:
;   input x in [0..999]; default for out-of-range.
;   We dispatch by group = x / 100  (0..9), then within group by r = x % 100 (0..99)
;   and return 1000 + x for in-range.
;
; Purpose:
;   - show multi-stage computed branching
;   - keep the second-stage tables small (10 tables of 100 entries each)
;   - illustrate the arithmetic vs table-size tradeoff
;
; Build:
;   nasm -f elf64 Chapter5_Lesson7_Ex10.asm -o ex10.o

default rel
bits 64

section .text
global switch_0_999_twolevel

; int switch_0_999_twolevel(int x)
switch_0_999_twolevel:
    mov eax, edi
    cmp eax, 999
    ja  .default

    ; group = x / 100, rem = x % 100
    xor edx, edx
    mov ecx, 100
    div ecx                        ; EAX=quotient(group), EDX=remainder(rem)

    ; stage 1 dispatch on group (0..9)
    lea r8, [jt_groups]
    mov ecx, eax
    movsxd rax, dword [r8 + rcx*4]
    add rax, r8
    jmp rax

.g0:  lea r9, [jt_0]  ; select table for group 0
      jmp .stage2
.g1:  lea r9, [jt_1]
      jmp .stage2
.g2:  lea r9, [jt_2]
      jmp .stage2
.g3:  lea r9, [jt_3]
      jmp .stage2
.g4:  lea r9, [jt_4]
      jmp .stage2
.g5:  lea r9, [jt_5]
      jmp .stage2
.g6:  lea r9, [jt_6]
      jmp .stage2
.g7:  lea r9, [jt_7]
      jmp .stage2
.g8:  lea r9, [jt_8]
      jmp .stage2
.g9:  lea r9, [jt_9]
      jmp .stage2

.stage2:
    ; rem is in EDX (0..99)
    mov ecx, edx
    jmp qword [r9 + rcx*8]

.default:
    mov eax, -1
    ret

; Common handler: return 1000 + x
.ret_1000_plus_x:
    mov eax, edi
    add eax, 1000
    ret

section .rodata
align 4
jt_groups:
    dd .g0 - jt_groups
    dd .g1 - jt_groups
    dd .g2 - jt_groups
    dd .g3 - jt_groups
    dd .g4 - jt_groups
    dd .g5 - jt_groups
    dd .g6 - jt_groups
    dd .g7 - jt_groups
    dd .g8 - jt_groups
    dd .g9 - jt_groups

; 10 second-stage tables. Each has 100 entries, all pointing to the same handler.
; This is intentionally "table heavy" to emphasize layout mechanics.
align 8
%macro FILL100 0
%assign k 0
%rep 100
    dq .ret_1000_plus_x
%assign k k+1
%endrep
%endmacro

jt_0: FILL100
jt_1: FILL100
jt_2: FILL100
jt_3: FILL100
jt_4: FILL100
jt_5: FILL100
jt_6: FILL100
jt_7: FILL100
jt_8: FILL100
jt_9: FILL100
