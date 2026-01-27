; Chapter 5 - Lesson 7 (Exercise 1 - Solution)
; Very hard: Generate a 50-way switch (cases 0..49) using *relative offsets* (dd),
; and compute a non-trivial function:
;   f(k) = (k*k + 7*k + 3) mod 2^31
; Return in EAX.
;
; Technique: jump table dispatch + generated handlers via %rep.
; Build:
;   nasm -f elf64 Chapter5_Lesson7_Ex9.asm -o ex9.o

default rel
bits 64

%assign N 50

section .text
global switch_50_rel

; int switch_50_rel(int k)
switch_50_rel:
    mov eax, edi                   ; eax = k
    cmp eax, (N-1)
    ja  .default

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
    ; eax = i*i + 7*i + 3
    mov eax, i
    imul eax, eax                  ; i*i
    lea eax, [eax + 7*i + 3]
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
