; Windows x64 calling pattern (conceptual):
; - Allocate 32 bytes shadow space
; - Put args in RCX, RDX, R8, R9
; - Ensure stack alignment for CALL

extern target_func
global win64_call_example

win64_call_example:
    sub rsp, 40         ; 32 shadow + 8 for alignment (typical pattern)
    mov rcx, 5          ; arg1
    mov rdx, 7          ; arg2
    call target_func
    add rsp, 40
    ret
