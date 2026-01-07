; NASM-like Intel syntax examples:
mov eax, dword [rbx + rcx*4 + 16]
mov byte  [rdi], 0x7F
mov qword [rsp + 8], rax

; Segment override:
mov rax, [fs:0x30]
mov rdx, [gs:rbx]
