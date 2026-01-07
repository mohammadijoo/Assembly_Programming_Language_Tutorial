; Caller/callee discipline sketch (not exhaustive):
; - caller-saved: caller must assume these can be clobbered by calls
; - callee-saved: callee must preserve (save/restore) if it uses them

; Example: preserving a callee-saved register (rbx) in a non-leaf function

global  wrapper
wrapper:
    push    rbx
    mov     rbx, rdi           ; keep a value across the call
    call    add7
    add     rax, rbx           ; combine return with preserved value
    pop     rbx
    ret
