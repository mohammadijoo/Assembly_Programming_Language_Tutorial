; ARM (A32) example: condition codes and flag-setting.
; This is NOT NASM syntax; it is for ARM assemblers (e.g., GNU as).
; Goal: see how condition suffixes can avoid branches.

    .syntax unified
    .text
    .global _start
_start:
    mov     r0, #5
    mov     r1, #5

    cmp     r0, r1          @ sets flags based on r0 - r1
    moveq   r2, #1          @ executes only if Z==1 (equal)
    movne   r2, #0          @ executes only if Z==0 (not equal)

    @ Linux ARM EABI exit: r7=1, r0=status, svc 0
    mov     r7, #1
    mov     r0, r2
    svc     #0
