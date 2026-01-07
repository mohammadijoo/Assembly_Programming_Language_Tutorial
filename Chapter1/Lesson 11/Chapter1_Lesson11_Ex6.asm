; x86-64 bug pattern: truncation
; Suppose RDI contains a 64-bit pointer.
mov eax, edi          ; BAD if you intended to preserve the full pointer
; RAX now holds zero-extended lower 32 bits of the pointer, upper bits lost.
