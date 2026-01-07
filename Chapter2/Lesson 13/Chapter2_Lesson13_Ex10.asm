; ARM (A32) example: ADDS updates flags, ADD does not (unless suffixed with S).
; Not NASM syntax.

    .syntax unified
    .text
    .global _start
_start:
    mov     r0, #1
    mov     r1, #1

    adds    r2, r0, r1      @ r2=2 and flags updated
    add     r3, r2, #0      @ r3=2 but flags not updated here

    @ Example conditional branch using flags from ADDS (if Z==1, branch)
    beq     equal_label

equal_label:
    mov     r7, #1
    mov     r0, #0
    svc     #0
