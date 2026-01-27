bits 64
default rel

global _start
section .text

; Ex11 (Exercise Solution 1):
; Implement a 3-way dispatch:
;   if x == 0  -> FAR_A
;   if x <  0  -> FAR_B
;   else       -> FAR_C
; Constraints:
; - Decision header uses only short conditional branches.
; - FAR_* blocks are far away (> rel8 range) and reached through trampolines.

_start:
    ; x in EAX (demo: set x = -5)
    mov eax, -5

    ; Header: only short Jcc.
    test eax, eax
    jz  short .to_A_island       ; x==0

    js  short .to_B_island       ; x<0

    jmp short .to_C_island       ; otherwise

.to_A_island:
    jmp near FAR_A

.to_B_island:
    jmp near FAR_B

.to_C_island:
    jmp near FAR_C

    ; Keep header compact; place far blocks far away.
    times 512 nop

FAR_A:
    mov edi, 10
    jmp near .exit

    times 512 nop

FAR_B:
    mov edi, 20
    jmp near .exit

    times 512 nop

FAR_C:
    mov edi, 30

.exit:
    mov eax, 60
    syscall
