; Minimal function shape (SysV AMD64 conceptually)
; - caller passes first argument in rdi
; - callee returns value in rax

global  add7
add7:
    ; rdi = input
    lea     rax, [rdi + 7]
    ret
