bits 64
default rel

global _start
section .text

; Ex2: Forcing a specific jump size.
; Toggle DEMO_OUT_OF_RANGE to 1 to intentionally trigger:
;   "short jump is out of range"
%define DEMO_OUT_OF_RANGE 0

_start:
%if DEMO_OUT_OF_RANGE
    jmp short .far              ; will FAIL if .far is beyond rel8 range
%else
    jmp near .far               ; always encodable as rel32 (within +/-2GB)
%endif

    ; Put a lot of bytes between jump and target.
    times 400 nop

.far:
    mov eax, 60
    xor edi, edi
    syscall
