; NASM / Intel syntax examples (x86-64)

; Example 1: 32-bit write zero-extends
mov rax, 0x1122334455667788
mov eax, 0xAABBCCDD        ; RAX becomes 0x00000000AABBCCDD

; Example 2: 16-bit write does NOT zero-extend
mov rax, 0x1122334455667788
mov ax,  0xEEFF            ; RAX becomes 0x112233445566EEFF

; Example 3: 8-bit write updates only low byte
mov rax, 0x1122334455667788
mov al,  0x99              ; RAX becomes 0x1122334455667799
