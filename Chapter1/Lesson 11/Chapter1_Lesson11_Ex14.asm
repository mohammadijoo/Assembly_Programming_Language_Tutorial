; x86-64 (SysV) alignment-aware call pattern
; Suppose we want to call some_function(a,b) with a in RDI, b in RSI.

global caller_example
extern some_function

caller_example:
    ; On SysV, before CALL, RSP must be aligned to 16 bytes.
    ; A common pattern is to reserve stack space in multiples of 16.
    sub rsp, 8              ; adjust so that after CALL (pushes return addr), alignment holds
    call some_function
    add rsp, 8
    ret
