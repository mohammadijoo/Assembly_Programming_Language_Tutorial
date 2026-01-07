; Example pattern (conceptual): load a value from TLS-like location.
; Exact offsets are OS/runtime specific; do not hardcode without ABI docs.

; mov rax, qword [fs:0x28]   ; typical pattern seen in some toolchains (offset example)
; mov rbx, qword [gs:0x30]   ; another pattern (platform-dependent)
