; Demonstrates: using labels as anchors and computing relative distances at assembly time.

BITS 64
global _start

SYS_exit equ 60

section .text
_start:
    jmp     near_target

near_target:
    nop
after_target:
    ; distance in bytes between after_target and near_target
dist equ after_target - near_target

    mov     eax, SYS_exit
    mov     edi, dist
    syscall
