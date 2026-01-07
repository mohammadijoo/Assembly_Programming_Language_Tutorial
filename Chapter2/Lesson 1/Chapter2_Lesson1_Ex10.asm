; NASM: load address of a label into RDI using RIP-relative relocation
lea rdi, [rel msg]

; NASM: load qword from label address (RIP-relative)
mov rax, [rel global_qword]
