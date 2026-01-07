; x86-64 example: FS-based access (TLS / thread data model).
; Exact offsets are OS/ABI-specific; the point here is the addressing mechanism.

mov rax, [fs:0x0]       ; read from address (FS.base + 0x0)
mov rcx, [gs:0x30]      ; read from address (GS.base + 0x30)
