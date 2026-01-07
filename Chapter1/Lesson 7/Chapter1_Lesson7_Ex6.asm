; Preferred in NASM for position-safe addressing:
lea rsi, [rel msg]

; Equivalent if you set default rel (NASM):
default rel
lea rsi, [msg]

; Anti-pattern in many contexts (absolute address relocation / not PIC-friendly):
; mov rsi, msg
