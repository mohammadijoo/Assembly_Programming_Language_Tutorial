; Example: MOV EAX, 1
; Encoding (x86): B8 01 00 00 00

bits 64

mov eax, 1          ; assembler emits: B8 01 00 00 00

; Equivalent raw emission (for learning / controlled output):
db 0xB8, 0x01, 0x00, 0x00, 0x00
