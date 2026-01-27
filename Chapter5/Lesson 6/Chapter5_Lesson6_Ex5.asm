bits 64
default rel

global _start
section .text

; Ex5: LOOP-family instructions have a hard encoding constraint:
; LOOP / LOOPE(Z) / LOOPNE(NZ) are always rel8 (signed 8-bit displacement).
; If your loop body is large, you must rewrite as DEC/INC + Jcc (rel32 capable).
;
; Toggle BIG_BODY to 1 to demonstrate why LOOP doesn't scale.
%define BIG_BODY 0

_start:
    mov ecx, 10

.loop_top:
%if BIG_BODY
    ; 400 bytes => LOOP target likely out of range
    times 400 nop
%else
    ; small body
    nop
    nop
%endif

    ; This encodes as rel8 only.
    loop .loop_top

    ; If BIG_BODY=1, fix by using:
    ;   dec rcx
    ;   jnz near .loop_top

    xor edi, edi
    mov eax, 60
    syscall
