
; 16-bit DOS COM example (historical style)
BITS 16
org 0x100

start:
  mov dx, msg      ; DS:DX points to "$"-terminated string
  mov ah, 0x09
  int 0x21

  mov ax, 0x4C00   ; terminate process
  int 0x21

msg db "Hello from DOS-era conventions.$"
      