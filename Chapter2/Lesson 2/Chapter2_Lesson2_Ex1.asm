; Real-mode style example (conceptual):
; physical = (segment << 4) + offset

; Suppose:
;   DS = 0x1000
;   BX = 0x0010
; Then DS:BX = 0x1000:0x0010 -> 0x10010 physical

; A load using DS:BX (default segment DS):
mov ax, [bx]      ; reads from physical 0x10010 (in real-mode model)
