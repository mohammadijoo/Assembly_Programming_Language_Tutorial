; SysV AMD64: long add3(long a, long b, long c) -> a+b+c
; a in RDI, b in RSI, c in RDX, return in RAX

global add3_sysv
section .text
add3_sysv:
    lea rax, [rdi + rsi]    ; LEA does not set flags
    add rax, rdx            ; ADD sets flags (irrelevant here)
    ret
