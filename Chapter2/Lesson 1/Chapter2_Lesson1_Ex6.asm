; canonical idiom: zero with XOR (breaks dependency chain)
xor eax, eax               ; clears RAX due to 32-bit write rule, typically best

; explicit move also works but may not break dependency chain on some CPUs
mov eax, 0
