; x86-64: load 1 byte and zero-extend
movzx eax, byte [rdi]

; x86-64: load 4 bytes (endianness affects interpretation)
mov eax, dword [rdi]
