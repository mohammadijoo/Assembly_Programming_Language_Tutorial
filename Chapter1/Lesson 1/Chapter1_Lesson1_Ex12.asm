section .bss
buffer:  resb 256

section .text
; Emit 16 NOPs (assembler repeats)
times 16 nop