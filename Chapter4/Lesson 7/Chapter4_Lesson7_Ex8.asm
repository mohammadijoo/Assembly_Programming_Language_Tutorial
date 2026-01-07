BITS 64
default rel
global _start

section .text
_start:
    ; Pitfall demo: flags clobbering between CMP/TEST and Jcc.
    ; We'll compare two equal values, then accidentally destroy ZF.

    mov eax, 123
    mov ebx, 123
    cmp eax, ebx              ; ZF=1 (equal)

    ; WRONG: this modifies flags (ZF, SF, OF, CF, ...)
    add ecx, 1                ; ecx was undefined, but that's not the point

    jz .equal_wrong           ; not reliably taken now (ZF likely cleared)

    ; Correct pattern A: keep the branch adjacent to CMP/TEST
    cmp eax, ebx
    jz .equal_right

.not_equal:
    mov eax, 60
    mov edi, 1
    syscall

.equal_wrong:
    ; We should not rely on reaching this.
    mov eax, 60
    mov edi, 2
    syscall

.equal_right:
    ; Correct pattern B (expensive): save/restore flags around flag-clobbering work
    cmp eax, ebx
    pushfq
    add edx, 7                ; any work that clobbers flags
    popfq
    jz .exit_ok               ; now ZF reflects the CMP again

    mov eax, 60
    mov edi, 3
    syscall

.exit_ok:
    mov eax, 60
    xor edi, edi
    syscall
