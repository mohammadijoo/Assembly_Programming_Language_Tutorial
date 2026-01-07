
; 64-bit Linux "write then exit" (modern ABI signature)
BITS 64
global _start

section .text
_start:
  ; write(1, buf, len)
  mov eax, 1        ; SYS_write
  mov edi, 1        ; fd = stdout
  lea rsi, [rel buf]
  mov edx, buf_len
  syscall

  ; exit(0)
  mov eax, 60       ; SYS_exit
  xor edi, edi
  syscall

section .rodata
buf db "Hello from modern x86-64 ABI", 10
buf_len equ $ - buf
      