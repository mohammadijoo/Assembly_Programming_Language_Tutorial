; Immediate:
mov eax, 123
add rax, 0x1000

; Register:
mov rbx, rax
xor ecx, ecx

; Memory (examples of different EA patterns):
mov eax, [rip+0x20]          ; RIP-relative (x86-64)
mov eax, [rbx]               ; base only
mov eax, [rbx+16]            ; base + displacement
mov eax, [rbx+rcx]           ; base + index
mov eax, [rbx+rcx*4]         ; base + index*scale
mov eax, [rbx+rcx*4+16]      ; base + index*scale + displacement
