; ADD updates arithmetic flags (CF, OF, ZF, SF, PF, AF).
; If later code uses flags for branching, you must not clobber them accidentally.

mov rax, 10
mov rbx, 20
add rax, rbx         ; flags updated here

; If we need the flags from ADD, avoid inserting flag-changing instructions in between.
jz  .was_zero         ; uses ZF computed by ADD
