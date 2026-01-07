; Key idea: keep target within -128..+127 bytes from the end of the Jcc instruction.
; Also: do not clobber flags between the cmp/test and jz.

global f
section .text

f:
    xor eax, eax            ; set ZF=1 (eax becomes 0)
    jz  target              ; will be short if target is close enough

    ; 100 bytes of padding that does NOT modify flags:
    ; Use NOPs. (Most NOP encodings do not change flags.)
    times 100 nop

target:
    ret
f_end:
