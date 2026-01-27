bits 64
default rel

global _start
section .text

; Ex13 (Exercise Solution 3):
; SMART_LOOP macro: use LOOP if the target fits rel8, otherwise use DEC/ JNZ near.
; This is valuable when you want LOOP semantics for compactness, but need correctness
; for large bodies.

%macro SMART_LOOP 1
    ; Compute rel8 displacement from the LOOP instruction (2 bytes) to the label.
    %assign __d (%1 - ($ + 2))
    %if (__d >= -128) && (__d <= 127)
        loop %1
    %else
        dec rcx
        jnz near %1
    %endif
%endmacro

_start:
    mov rcx, 5

.loop_top:
    ; Deliberately make body big so LOOP likely doesn't fit.
    times 300 nop

    SMART_LOOP .loop_top

    xor edi, edi
    mov eax, 60
    syscall
