; Common single-byte NOP:
nop                     ; 0x90

; Multi-byte NOP patterns often used for alignment (assembler-dependent):
; (These are examples; the exact bytes may vary by assembler choice.)
db 0x66, 0x90            ; 2-byte NOP variant (historical)
db 0x0F, 0x1F, 0x00       ; 3-byte NOP variant
