; Chapter 5 - Lesson 7 (Exercise 5 - Solution)
; Very hard: Defensive computed branch with:
;   - unsigned base-offset range check
;   - optional speculation barrier before indirect jump
;   - indirect branch via relative-offset table (compact)
;
; This pattern addresses both correctness and a class of speculative-execution concerns
; (not a universal fix; used here as an engineering illustration).
;
; Build:
;   nasm -f elf64 Chapter5_Lesson7_Ex13.asm -o ex13.o

default rel
bits 64

%define BASE 20
%define N    8                       ; cases 20..27

section .text
global switch_defensive

; int switch_defensive(int x)
switch_defensive:
    mov eax, edi
    sub eax, BASE                    ; idx = x - BASE
    cmp eax, (N-1)
    ja  .default

%ifdef USE_LFENCE
    lfence                           ; optional barrier (microarch-dependent)
%endif

    lea rdx, [jt_base]
    mov ecx, eax
    movsxd rax, dword [rdx + rcx*4]
    add rax, rdx
    jmp rax

.default:
    mov eax, -1
    ret

%assign i 0
%rep N
.case_%+i:
    mov eax, 20000 + (BASE + i)
    ret
%assign i i+1
%endrep

section .rodata
align 4
jt_base:
%assign j 0
%rep N
    dd .case_%+j - jt_base
%assign j j+1
%endrep
