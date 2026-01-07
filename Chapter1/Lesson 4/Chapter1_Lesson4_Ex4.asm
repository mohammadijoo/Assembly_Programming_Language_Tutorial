; x86-64: load address of a symbol using RIP-relative LEA (conceptual)
; rdi = &global_var
lea rdi, [rel global_var]

; load value from global_var
mov eax, dword [rel global_var]

; NOTE: exact syntax varies (NASM uses "rel", GAS uses different forms).
