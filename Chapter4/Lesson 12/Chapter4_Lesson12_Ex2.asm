; Chapter 4 - Lesson 12 (Ex2)
; Implicit operands: DIV uses RDX:RAX as numerator and writes quotient to RAX, remainder to RDX.
; Critical pitfall: forgetting to clear/prepare RDX causes wrong results or #DE (divide error).

bits 64
default rel
global _start

section .text
_start:
    ; Compute 1000 / 7 (unsigned) with DIV r/m64
    mov     rax, 1000
    xor     edx, edx            ; MUST: zero high half for unsigned 64-bit numerator
    mov     rcx, 7
    div     rcx                 ; RAX=quot, RDX=rem

    ; Now demonstrate the pitfall: stale RDX makes numerator huge.
    ; Uncommenting the below can crash (#DE) if quotient does not fit 64 bits.
    ; (We keep it disabled so the file assembles and runs safely.)
%if 0
    mov     rax, 1000
    mov     rdx, 0xFFFFFFFFFFFFFFFF
    mov     rcx, 7
    div     rcx                 ; likely #DE: quotient overflow
%endif

    ; Exit with code = remainder (0..6), purely for demonstration.
    mov     eax, 60
    mov     edi, edx
    syscall
