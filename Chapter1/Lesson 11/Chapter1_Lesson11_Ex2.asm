; x86-64 partial register write example
mov rax, 0x1122334455667788
mov al,  0xFF
; Now: RAX = 0x11223344556677FF  (upper bits unchanged)
