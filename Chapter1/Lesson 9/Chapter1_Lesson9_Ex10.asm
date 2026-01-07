; badcallee.asm
default rel
global badcallee

section .text
badcallee:
    ; ABI violation: RBX is callee-saved in SysV AMD64,
    ; but we overwrite it and return without restoring.
    mov rbx, 0x1122334455667788
    ret
