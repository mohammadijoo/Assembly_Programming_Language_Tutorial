bits 64
default rel

global _start
section .text

; Ex15 (Exercise Solution 5):
; A reusable "island table" for multiple far targets.
; Idea: keep a cluster of short Jcc in a compact decision region, each landing on
; a nearby island that performs a near JMP to the far block.

%macro ISLAND 1
%%island_%1:
    jmp near %1
%endmacro

_start:
    ; Demo inputs: pick a branch based on EAX.
    mov eax, 2

    cmp eax, 0
    je  short island_A

    cmp eax, 1
    je  short island_B

    ; default
    jmp short island_C

island_A:
    ISLAND FAR_A
island_B:
    ISLAND FAR_B
island_C:
    ISLAND FAR_C

    ; Move far targets well away.
    times 600 nop

FAR_A:
    mov edi, 11
    jmp near .exit

    times 600 nop

FAR_B:
    mov edi, 22
    jmp near .exit

    times 600 nop

FAR_C:
    mov edi, 33

.exit:
    mov eax, 60
    syscall
