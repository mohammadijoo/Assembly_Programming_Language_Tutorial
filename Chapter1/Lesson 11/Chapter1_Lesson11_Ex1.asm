; x86-64 (NASM / Intel syntax)
; Demonstrates: writing EAX zero-extends into RAX

mov rax, 0xFFFFFFFFFFFFFFFF
mov eax, 0x00000001          ; upper 32 bits become 0 automatically
; Now: RAX = 0x0000000000000001
