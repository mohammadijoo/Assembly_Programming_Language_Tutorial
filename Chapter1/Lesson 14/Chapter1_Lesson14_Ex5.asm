; Microsoft x64: long add3(long a, long b, long c) -> a+b+c
; a in RCX, b in RDX, c in R8, return in RAX
; Caller provides 32-byte shadow space. Callee may use it.

global add3_win64
section .text
add3_win64:
    lea rax, [rcx + rdx]
    add rax, r8
    ret
