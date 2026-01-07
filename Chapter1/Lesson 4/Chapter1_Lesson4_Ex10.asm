; x86-64: ptr in rdi, val in eax (adds 32-bit)
add dword [rdi], eax

; x86-64: ptr in rdi, val in rax (adds 64-bit)
add qword [rdi], rax
