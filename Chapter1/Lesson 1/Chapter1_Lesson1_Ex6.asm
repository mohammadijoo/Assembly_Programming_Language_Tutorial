; Intel syntax: effective address = base + index*scale + displacement
; Example reads a 32-bit integer from memory:
mov eax, dword [rbx + rcx*4 + 16]