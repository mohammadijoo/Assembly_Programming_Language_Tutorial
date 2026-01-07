; reg ← imm
mov r10, 123456789
mov eax, 0xDEADBEEF

; reg ← reg
mov rbx, rax

; reg ← [mem]   (loads)
; [mem] ← reg   (stores)
; Note: size must be known from register or explicit size specifier
mov rax, [rdi]             ; load 8 bytes from address in RDI
mov dword [rdi+4], ecx     ; store 4 bytes
