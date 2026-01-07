
; --- (1) 16-bit DOS COM ---
BITS 16
org 0x100
start:
  mov ax, 9
  add ax, ax        ; ax = 18
  add ax, 5         ; ax = 23

  mov ah, 0x4C      ; DOS terminate
  mov al, 23        ; return code
  int 0x21
      