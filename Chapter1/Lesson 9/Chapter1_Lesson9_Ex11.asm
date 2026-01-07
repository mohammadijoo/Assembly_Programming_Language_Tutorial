; driver.asm
default rel
global _start
extern badcallee
extern sys_exit

section .text
_start:
    mov rbx, 123               ; caller expects RBX preserved
    call badcallee
    ; If RBX changed, the next computation changes
    cmp rbx, 123
    jne .fail

.ok:
    xor edi, edi
    jmp sys_exit

.fail:
    mov edi, 1
    jmp sys_exit
