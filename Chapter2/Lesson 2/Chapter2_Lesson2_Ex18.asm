; Input:  AX = seg, BX = off
; Output: AX = seg', BX = off' with off' in [0..15]
; Clobbers: CX, DX

; Compute p = seg*16 + off using shifts/adds (8086-friendly):
; We compute seg*16 by shifting left 4 (i.e., multiply by 16).
; But 8086 has only 16-bit regs; p may overflow 16 bits. Track high bits in DX.

; Step 1: p_low = off
mov cx, bx

; Step 2: compute seg*16 into (DX:BX) by repeated shifts
; We'll shift AX left 4 into DX:BX: start with BX=AX, DX=0, then shift 4 times.
mov bx, ax
xor dx, dx

shl bx, 1
rcl dx, 1
shl bx, 1
rcl dx, 1
shl bx, 1
rcl dx, 1
shl bx, 1
rcl dx, 1

; Now (DX:BX) = seg*16
; Add off (CX) into (DX:BX)
add bx, cx
adc dx, 0

; Now p = (DX:BX). Canonicalization:
; We want off' = p & 0x000F, seg' = p >> 4.
; Compute off' first:
mov cx, bx
and cx, 0x000F          ; CX = off'

; Compute seg' = p >> 4.
; Shift (DX:BX) right by 4 into (DX:BX) (logical)
; 8086 has SHR and RCR.
mov ax, bx              ; We'll return seg' in AX
; Put full p in (DX:AX) for shifting convenience:
; DX already high, AX = low
; Shift right 4:
shr dx, 1
rcr ax, 1
shr dx, 1
rcr ax, 1
shr dx, 1
rcr ax, 1
shr dx, 1
rcr ax, 1

; AX now holds low 16 bits of seg' (sufficient for real-mode segment register)
; CX is off'
mov bx, cx              ; BX = off'
; AX = seg' (canonical)
