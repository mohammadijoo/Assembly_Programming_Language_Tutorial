; reg-reg exchange (fast)
xchg rax, rbx

; reg-mem exchange (implicitly atomic on x86)
; xchg rax, [rdi]         ; expensive; only use when you really want atomic exchange
