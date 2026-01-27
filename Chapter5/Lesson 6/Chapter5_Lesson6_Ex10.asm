bits 64
default rel

global _start
section .text

; Ex10: Compile-time range checks with NASM expressions.
; When a jump must be rel8, the displacement d is:
;   d = target - (next_ip)
; For a short JMP (2 bytes), next_ip = (address of JMP) + 2.
; This file provides a macro to assert rel8 fit, useful for enforcing layout policies.

%macro ASSERT_REL8 2
    ; %1 = from_label, %2 = to_label
    ; For short unconditional JMP: instruction length is 2 bytes.
    %assign __d (%2 - (%1 + 2))
    %if (__d < -128) || (__d > 127)
        %error rel8 displacement out of range for jump from %1 to %2
    %endif
%endmacro

_start:
    jmp short .L1
.L0:
    nop
    nop
.L1:
    ; The ASSERT checks the displacement *as if* we were to encode a short jump at .L0.
    ASSERT_REL8 .L0, .L1

    ; Now demonstrate a case that would fail if uncommented:
    ;   ASSERT_REL8 .L0, .Far

    jmp near .Done

    times 300 nop
.Far:
    nop

.Done:
    xor edi, edi
    mov eax, 60
    syscall
