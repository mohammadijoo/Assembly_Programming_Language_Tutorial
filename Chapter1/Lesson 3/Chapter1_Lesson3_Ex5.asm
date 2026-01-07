; Conceptual kernel/firmware snippet (x86)
; Write a byte to an I/O port: out dx, al
; Read a byte from an I/O port: in  al, dx

io_example:
  mov dx, 0x3F8        ; COM1 base port (example)
  mov al, 'A'
  out dx, al           ; transmit 'A' (device-specific behavior)
  in  al, dx           ; read status/data (depends on port)
  ret
