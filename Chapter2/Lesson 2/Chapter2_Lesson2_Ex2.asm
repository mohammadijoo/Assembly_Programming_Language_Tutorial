; Real-mode default segment rule demonstration (conceptual):
; [bx] uses DS by default
; [bp] uses SS by default

mov ax, [bx]      ; DS:BX
mov dx, [bp]      ; SS:BP  (often surprises beginners)
