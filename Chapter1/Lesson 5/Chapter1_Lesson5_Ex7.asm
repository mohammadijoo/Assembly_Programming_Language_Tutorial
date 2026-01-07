; Push/pop are shorthand for stack pointer updates + memory access

push    rbx             ; rsp -= 8; [rsp] = rbx
; ... do work ...
pop     rbx             ; rbx = [rsp]; rsp += 8
