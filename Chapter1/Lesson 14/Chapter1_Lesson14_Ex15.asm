; Template: Windows x64 function that calls another function.
; Rule: reserve 32 bytes of shadow space for callees, maintain 16-byte alignment at call sites.

extern some_win_callee

global win64_template
section .text
win64_template:
    ; Prologue: allocate local stack. Include 32B shadow + alignment padding if needed.
    ; Common pattern: sub rsp, 40h (64) or 20h (32) depending on locals/alignment needs.
    sub rsp, 40h

    ; ... place args in RCX, RDX, R8, R9 as needed ...
    call some_win_callee

    add rsp, 40h
    ret
