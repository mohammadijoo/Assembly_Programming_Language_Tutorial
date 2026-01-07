
; "Hex era" simulation: emit raw bytes, then use a mnemonic
; (Educational only: do NOT write real programs like this.)

BITS 16
org 0x100

start:
  ; mov ax, 0x1234 encoded as: B8 34 12
  db 0xB8, 0x34, 0x12

  ; Equivalent mnemonic (assembler encodes bytes for you)
  mov ax, 0x1234

  ; halt (DOS COM program: just return)
  ret
      