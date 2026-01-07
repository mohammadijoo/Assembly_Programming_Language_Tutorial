; Template: SysV function that calls another function and uses RBX (callee-saved).
extern some_callee

global sysv_template
section .text
sysv_template:
    push rbp
    mov rbp, rsp
    push rbx

    ; Ensure stack is 16-byte aligned before any CALL.
    ; At entry: (RSP+8) mod 16 = 0. After push rbp (8) and push rbx (8), RSP changed by 16, still aligned.
    ; If you push an odd number of 8-byte values, you must adjust.

    mov rbx, 123
    ; ... prepare args per SysV ...
    call some_callee

    pop rbx
    pop rbp
    ret
